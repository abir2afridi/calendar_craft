import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/models/holiday.dart';
import 'hive_service.dart';

class HolidayService {
  static final HolidayService _instance = HolidayService._internal();
  factory HolidayService() => _instance;
  HolidayService._internal();

  static const String _baseUrl = 'https://calendarific.com/api/v2/holidays';

  Future<List<Holiday>> fetchHolidays(String countryCode, int year) async {
    final apiKey = dotenv.env['CALENDARIFIC_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('🚨 HolidayService Error: API key not found in .env');
      return [];
    }

    final url = '$_baseUrl?api_key=$apiKey&country=$countryCode&year=$year';
    debugPrint(
      '🌐 HolidayService: Requesting holidays for $countryCode in $year',
    );

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      debugPrint('📡 HolidayService: Response status ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['meta']?['code'] == 200) {
          final List<dynamic> holidaysJson =
              data['response']?['holidays'] ?? [];
          debugPrint(
            '📊 HolidayService: Received ${holidaysJson.length} holidays',
          );

          final holidays = holidaysJson
              .map((item) {
                try {
                  return Holiday.fromJson(item as Map<String, dynamic>);
                } catch (e) {
                  debugPrint('⚠️ HolidayService: Parsing error: $e');
                  return null;
                }
              })
              .whereType<Holiday>()
              .toList();

          if (holidays.isNotEmpty) {
            await HiveService.addHolidays(holidays);
            debugPrint(
              '💾 HolidayService: Saved ${holidays.length} holidays to local storage',
            );
          }
          return holidays;
        } else {
          final errorMsg = data['meta']?['error_detail'] ?? 'Unknown API error';
          debugPrint('❌ HolidayService API Error Message: $errorMsg');
          throw Exception('Calendarific API Error: $errorMsg');
        }
      } else {
        debugPrint(
          '❌ HolidayService HTTP Error: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Failed to load holidays: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🚨 HolidayService Exception: $e');

      // Fallback to local cache if available when API fails
      final cached = await HiveService.getAllHolidays();
      final filtered = cached
          .where(
            (h) =>
                h.countryCode.toUpperCase() == countryCode.toUpperCase() &&
                h.date.year == year,
          )
          .toList();

      if (filtered.isNotEmpty) {
        debugPrint(
          '🔄 HolidayService: API failed, falling back to ${filtered.length} cached holidays',
        );
        return filtered;
      }
      rethrow;
    }
  }

  Future<List<Holiday>> getLocalHolidays() async {
    return await HiveService.getAllHolidays();
  }
}
