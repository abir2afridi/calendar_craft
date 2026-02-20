import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/services/holiday_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/hive_service.dart';
import '../../domain/models/holiday.dart';

class HolidayState extends Equatable {
  final List<Holiday> holidays;
  final String? countryCode;
  final String? countryName;
  final bool isLoading;
  final bool useDeviceLocation;
  final String? error;

  const HolidayState({
    this.holidays = const [],
    this.countryCode,
    this.countryName,
    this.isLoading = false,
    this.useDeviceLocation = true,
    this.error,
  });

  HolidayState copyWith({
    List<Holiday>? holidays,
    String? countryCode,
    String? countryName,
    bool? isLoading,
    bool? useDeviceLocation,
    String? error,
  }) {
    return HolidayState(
      holidays: holidays ?? this.holidays,
      countryCode: countryCode ?? this.countryCode,
      countryName: countryName ?? this.countryName,
      isLoading: isLoading ?? this.isLoading,
      useDeviceLocation: useDeviceLocation ?? this.useDeviceLocation,
      error: error, // Can be null to clear error
    );
  }

  @override
  List<Object?> get props => [
    holidays,
    countryCode,
    countryName,
    isLoading,
    useDeviceLocation,
    error,
  ];
}

class HolidayNotifier extends StateNotifier<HolidayState> {
  HolidayNotifier() : super(const HolidayState()) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    state = state.copyWith(isLoading: true);
    debugPrint('🎬 HolidayNotifier: Loading initial state...');

    try {
      // 1. Load settings
      final useLocation =
          await HiveService.getSetting<bool>('use_device_location', true) ??
          true;
      final savedCode = await HiveService.getSetting<String>(
        'selected_country_code',
      );
      final savedName = await HiveService.getSetting<String>(
        'selected_country_name',
      );

      // 2. Load cached holidays
      final cachedHolidays = await HiveService.getAllHolidays();
      debugPrint(
        '📂 HolidayNotifier: Found ${cachedHolidays.length} cached holidays',
      );

      state = state.copyWith(
        holidays: cachedHolidays,
        useDeviceLocation: useLocation,
        countryCode: savedCode,
        countryName: savedName,
        isLoading: false,
      );

      // 3. Trigger Refresh
      if (useLocation) {
        await detectAndFetchHolidays();
      } else if (savedCode != null) {
        await fetchHolidays(savedCode, savedName ?? savedCode);
      }
    } catch (e) {
      debugPrint('🚨 HolidayNotifier Load Error: $e');
      state = state.copyWith(isLoading: false, error: 'Initialization error');
    }
  }

  Future<void> detectAndFetchHolidays() async {
    debugPrint('📍 HolidayNotifier: Detecting location...');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final position = await LocationService().getCurrentPosition();
      if (position != null) {
        final code = await LocationService().getCountryCode(position);
        final name = await LocationService().getCountryName(position);

        if (code != null) {
          debugPrint('🌍 HolidayNotifier: Detected $code ($name)');
          await fetchHolidays(code.toUpperCase(), name ?? code);
        } else {
          debugPrint('⚠️ HolidayNotifier: Country code not resolved');
          state = state.copyWith(
            isLoading: false,
            error: 'Country not detected',
          );
        }
      } else {
        debugPrint('⚠️ HolidayNotifier: Location position is null');
        state = state.copyWith(isLoading: false, error: 'Location unavailable');
      }
    } catch (e) {
      debugPrint('🚨 HolidayNotifier Detection Error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchHolidays(
    String countryCode,
    String countryName, {
    int? year,
  }) async {
    final code = countryCode.toUpperCase();
    final targetYear = year ?? DateTime.now().year;

    debugPrint('🚀 HolidayNotifier: Fetching $code around $targetYear');
    state = state.copyWith(isLoading: true, error: null);

    try {
      // If country changed, clear previous from UI
      if (state.countryCode != code) {
        state = state.copyWith(holidays: []);
      }

      // Fetch multiple years for better coverage (current, previous, next)
      final yearsToFetch = [targetYear - 1, targetYear, targetYear + 1];

      List<Holiday> allHolidays = [];
      for (final y in yearsToFetch) {
        try {
          final yearHolidays = await HolidayService().fetchHolidays(code, y);
          allHolidays.addAll(yearHolidays);
        } catch (e) {
          debugPrint('⚠️ Skip year $y for $code: $e');
        }
      }

      // Remove duplicates and sort
      final uniqueHolidays = {
        for (var h in allHolidays) h.id: h,
      }.values.toList();
      uniqueHolidays.sort((a, b) => a.date.compareTo(b.date));

      state = state.copyWith(
        holidays: uniqueHolidays,
        countryCode: code,
        countryName: countryName,
        isLoading: false,
      );

      // Persist settings
      await HiveService.saveSetting('selected_country_code', code);
      await HiveService.saveSetting('selected_country_name', countryName);
    } catch (e) {
      debugPrint('🚨 HolidayNotifier Sync Error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Fetch failed: ${e.toString().split('Exception: ').last}',
      );
    }
  }

  Future<void> setUseDeviceLocation(bool value) async {
    state = state.copyWith(useDeviceLocation: value);
    await HiveService.saveSetting('use_device_location', value);
    if (value) {
      await detectAndFetchHolidays();
    }
  }

  Future<void> refresh() async {
    if (state.useDeviceLocation) {
      await detectAndFetchHolidays();
    } else if (state.countryCode != null) {
      await fetchHolidays(
        state.countryCode!,
        state.countryName ?? state.countryCode!,
      );
    }
  }
}

// Providers
final holidayProvider = StateNotifierProvider<HolidayNotifier, HolidayState>((
  ref,
) {
  return HolidayNotifier();
});

// Optimized provider for filtering holidays by month
// Includes a small buffer for "outside days" (prev/next month edges)
final holidaysForMonthProvider = Provider.family<List<Holiday>, DateTime>((
  ref,
  month,
) {
  final allHolidays = ref.watch(holidayProvider).holidays;

  // Create a range that covers the current month plus 7 days buffer both sides
  final start = DateTime(
    month.year,
    month.month,
    1,
  ).subtract(const Duration(days: 7));
  final end = DateTime(
    month.year,
    month.month + 1,
    1,
  ).add(const Duration(days: 7));

  return allHolidays.where((h) {
    return h.date.isAfter(start) && h.date.isBefore(end);
  }).toList();
});

final holidaysForDateProvider = Provider.family<List<Holiday>, DateTime>((
  ref,
  date,
) {
  final allHolidays = ref.watch(holidayProvider).holidays;
  return allHolidays.where((h) => isSameDay(h.date, date)).toList();
});
