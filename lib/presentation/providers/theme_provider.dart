import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:calendar_craft/core/services/hive_service.dart';
import 'package:calendar_craft/core/constants/app_constants.dart';

enum AppTheme {
  light,
  dark,
  system;

  String get displayName {
    switch (this) {
      case AppTheme.light:
        return 'Light';
      case AppTheme.dark:
        return 'Dark';
      case AppTheme.system:
        return 'System';
    }
  }
}

class ThemeNotifier extends StateNotifier<AppTheme> {
  ThemeNotifier() : super(AppTheme.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final savedTheme = await HiveService.getSetting<String>(
        AppConstants.themeKey,
      );
      if (savedTheme != null) {
        state = AppTheme.values.firstWhere(
          (theme) => theme.name == savedTheme,
          orElse: () => AppTheme.system,
        );
      }
    } catch (e) {
      debugPrint('Failed to load theme: $e');
    }
  }

  Future<void> setTheme(AppTheme theme) async {
    try {
      state = theme;
      await HiveService.saveSetting(AppConstants.themeKey, theme.name);
    } catch (e) {
      debugPrint('Failed to save theme: $e');
    }
  }
}

// Providers
final themeProvider = StateNotifierProvider<ThemeNotifier, AppTheme>((ref) {
  return ThemeNotifier();
});

final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF2196F3),
    brightness: Brightness.light,
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 0,
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.black87,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  cardTheme: const CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    elevation: 4,
    shape: CircleBorder(),
  ),
);

final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF2196F3),
    brightness: Brightness.dark,
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 0,
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  cardTheme: const CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    elevation: 4,
    shape: CircleBorder(),
  ),
);

final themeModeProvider = Provider<ThemeMode>((ref) {
  final appTheme = ref.watch(themeProvider);

  switch (appTheme) {
    case AppTheme.light:
      return ThemeMode.light;
    case AppTheme.dark:
      return ThemeMode.dark;
    case AppTheme.system:
      return ThemeMode.system;
  }
});
