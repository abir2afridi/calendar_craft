import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/event.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  String? get uid => _auth.currentUser?.uid;

  Future<void> signInAnonymously() async {
    try {
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
        debugPrint('Signed in anonymously: $uid');
      }
    } catch (e) {
      debugPrint('Failed to sign in anonymously: $e');
    }
  }

  CollectionReference<Map<String, dynamic>> get _settingsRef =>
      _firestore.collection('users').doc(uid).collection('settings');

  CollectionReference<Map<String, dynamic>> get _eventsRef =>
      _firestore.collection('users').doc(uid).collection('events');

  Future<void> saveSetting(String key, dynamic value) async {
    try {
      if (uid == null) return;
      await _settingsRef.doc(key).set({
        'value': value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Setting synced to Firestore: $key');
    } catch (e) {
      debugPrint('Failed to sync setting to Firestore: $key | $e');
    }
  }

  Future<Map<String, dynamic>> getAllSettings() async {
    try {
      if (uid == null) return {};
      final snapshot = await _settingsRef.get();
      return {for (var doc in snapshot.docs) doc.id: doc.data()['value']};
    } catch (e) {
      debugPrint('Failed to fetch settings from Firestore: $e');
      return {};
    }
  }

  Future<void> saveEvent(Event event) async {
    try {
      if (uid == null) {
        debugPrint('Skip Firestore save: User not authenticated');
        return;
      }

      final data = event.toJson();

      // Convert all possible DateTime fields to Timestamps for Firestore
      data['date'] = Timestamp.fromDate(event.date);
      if (event.startTime != null) {
        data['startTime'] = Timestamp.fromDate(event.startTime!);
      }
      if (event.endTime != null) {
        data['endTime'] = Timestamp.fromDate(event.endTime!);
      }
      data['createdAt'] = Timestamp.fromDate(event.createdAt);
      data['updatedAt'] = Timestamp.fromDate(event.updatedAt);

      if (event.reminderTimes.isNotEmpty) {
        data['reminderTimes'] = event.reminderTimes
            .map((e) => Timestamp.fromDate(e))
            .toList();
      }

      // Sync metadata
      data['isSyncPending'] = false;
      data['lastSyncedAt'] = FieldValue.serverTimestamp();

      // Explicitly set the ID as string
      final String docId = event.id.toString();
      data['id'] = docId;

      await _eventsRef.doc(docId).set(data);
      debugPrint('Event saved to Firestore: ${event.title} (ID: $docId)');
    } catch (e) {
      debugPrint('🚨 Failed to save event to Firestore: $e');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      if (uid == null) return;
      await _eventsRef.doc(eventId).delete();
      debugPrint('Event deleted from Firestore: $eventId');
    } catch (e) {
      debugPrint('🚨 Failed to delete event from Firestore: $e');
    }
  }

  Future<List<Event>> getEvents() async {
    try {
      if (uid == null) return [];

      final snapshot = await _eventsRef.get();
      debugPrint(
        '☁️ Firestore: Fetched ${snapshot.docs.length} events for user $uid',
      );

      return snapshot.docs.map((doc) {
        final data = doc.data();

        // Safe conversion helper for Firestore Timestamps, Strings, etc.
        String formatToIso(dynamic val) {
          if (val == null) return '';
          if (val is Timestamp) return val.toDate().toIso8601String();
          if (val is String) return val;
          if (val is int) {
            return DateTime.fromMillisecondsSinceEpoch(val).toIso8601String();
          }
          return DateTime.now().toIso8601String();
        }

        // Robust ID handling (ensure it's a string)
        data['id'] = (data['id'] ?? doc.id).toString();

        // Convert all DateTime fields to ISO 8601 strings for Event.fromJson
        data['date'] = formatToIso(data['date']);

        if (data['startTime'] != null) {
          data['startTime'] = formatToIso(data['startTime']);
        }
        if (data['endTime'] != null) {
          data['endTime'] = formatToIso(data['endTime']);
        }

        data['createdAt'] = formatToIso(data['createdAt']);
        data['updatedAt'] = formatToIso(data['updatedAt']);

        if (data['lastSyncedAt'] != null) {
          data['lastSyncedAt'] = formatToIso(data['lastSyncedAt']);
        }

        if (data['reminderTimes'] != null && data['reminderTimes'] is List) {
          data['reminderTimes'] = (data['reminderTimes'] as List)
              .map((e) => formatToIso(e))
              .toList();
        }

        // Ensure default values for boolean fields if missing
        data['isSyncPending'] = data['isSyncPending'] ?? false;
        data['isCompleted'] = data['isCompleted'] ?? false;

        return Event.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('🚨 Failed to get events from Firestore: $e');
      return [];
    }
  }

  Future<void> syncLocalWithCloud(List<Event> localEvents) async {
    try {
      if (uid == null) return;
      debugPrint('🔄 CloudSync: Bulk pushing available local events...');

      // Batch writes would be better but keeping it simple for now
      for (final event in localEvents) {
        await saveEvent(event);
      }
      debugPrint('✅ CloudSync: Sync complete');
    } catch (e) {
      debugPrint('🚨 CloudSync Error: $e');
    }
  }
}
