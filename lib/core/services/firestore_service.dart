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

  CollectionReference<Map<String, dynamic>> get _eventsRef =>
      _firestore.collection('users').doc(uid).collection('events');

  Future<void> saveEvent(Event event) async {
    try {
      if (uid == null) await signInAnonymously();
      if (uid == null) return;

      final data = event.toJson();
      // Convert DateTime to Timestamp for better Firestore integration
      data['date'] = Timestamp.fromDate(event.date);
      if (event.startTime != null) {
        data['startTime'] = Timestamp.fromDate(event.startTime!);
      }
      if (event.endTime != null) {
        data['endTime'] = Timestamp.fromDate(event.endTime!);
      }
      data['createdAt'] = Timestamp.fromDate(event.createdAt);
      data['updatedAt'] = Timestamp.fromDate(event.updatedAt);

      if (data['reminderTimes'] != null) {
        data['reminderTimes'] = (data['reminderTimes'] as List)
            .map((e) => Timestamp.fromDate(e as DateTime))
            .toList();
      }

      await _eventsRef.doc(event.id).set(data);
      debugPrint('Event saved to Firestore: ${event.title}');
    } catch (e) {
      debugPrint('Failed to save event to Firestore: $e');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      if (uid == null) return;
      await _eventsRef.doc(eventId).delete();
      debugPrint('Event deleted from Firestore: $eventId');
    } catch (e) {
      debugPrint('Failed to delete event from Firestore: $e');
    }
  }

  Future<List<Event>> getEvents() async {
    try {
      if (uid == null) await signInAnonymously();
      if (uid == null) return [];

      final snapshot = await _eventsRef.get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Convert Timestamp back to DateTime
        data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
        if (data['startTime'] != null) {
          data['startTime'] = (data['startTime'] as Timestamp)
              .toDate()
              .toIso8601String();
        }
        if (data['endTime'] != null) {
          data['endTime'] = (data['endTime'] as Timestamp)
              .toDate()
              .toIso8601String();
        }
        data['createdAt'] = (data['createdAt'] as Timestamp)
            .toDate()
            .toIso8601String();
        data['updatedAt'] = (data['updatedAt'] as Timestamp)
            .toDate()
            .toIso8601String();

        if (data['reminderTimes'] != null) {
          data['reminderTimes'] = (data['reminderTimes'] as List)
              .map((e) => (e as Timestamp).toDate().toIso8601String())
              .toList();
        }

        return Event.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Failed to get events from Firestore: $e');
      return [];
    }
  }

  Future<void> syncLocalWithCloud(List<Event> localEvents) async {
    try {
      if (uid == null) await signInAnonymously();
      if (uid == null) return;

      // Simple one-way sync: local to cloud
      for (final event in localEvents) {
        await saveEvent(event);
      }
      debugPrint('Local events synced to Firestore');
    } catch (e) {
      debugPrint('Failed to sync events: $e');
    }
  }
}
