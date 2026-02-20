import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

enum VisualTheme {
  monthly, // Theme 1
  bento, // Theme 2
  cyber; // Theme 3

  String get displayName {
    switch (this) {
      case VisualTheme.monthly:
        return 'Monthly Classic';
      case VisualTheme.bento:
        return 'Bento Modern';
      case VisualTheme.cyber:
        return 'Cyber Glow';
    }
  }
}

class ThemeState {
  final AppTheme appTheme;
  final VisualTheme visualTheme;

  ThemeState({required this.appTheme, required this.visualTheme});

  ThemeState copyWith({AppTheme? appTheme, VisualTheme? visualTheme}) {
    return ThemeState(
      appTheme: appTheme ?? this.appTheme,
      visualTheme: visualTheme ?? this.visualTheme,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier()
    : super(
        ThemeState(appTheme: AppTheme.system, visualTheme: VisualTheme.monthly),
      ) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final savedTheme = await HiveService.getSetting<String>(
        AppConstants.themeKey,
      );
      final savedVisual = await HiveService.getSetting<String>(
        AppConstants.visualThemeKey,
      );

      AppTheme appTheme = AppTheme.system;
      VisualTheme visualTheme = VisualTheme.monthly;

      if (savedTheme != null) {
        appTheme = AppTheme.values.firstWhere(
          (theme) => theme.name == savedTheme,
          orElse: () => AppTheme.system,
        );
      }

      if (savedVisual != null) {
        visualTheme = VisualTheme.values.firstWhere(
          (v) => v.name == savedVisual,
          orElse: () => VisualTheme.monthly,
        );
      }

      state = ThemeState(appTheme: appTheme, visualTheme: visualTheme);
    } catch (e) {
      debugPrint('Failed to load theme: $e');
    }
  }

  Future<void> setTheme(AppTheme theme) async {
    try {
      state = state.copyWith(appTheme: theme);
      await HiveService.saveSetting(AppConstants.themeKey, theme.name);
    } catch (e) {
      debugPrint('Failed to save theme: $e');
    }
  }

  Future<void> setVisualTheme(VisualTheme visualTheme) async {
    try {
      state = state.copyWith(visualTheme: visualTheme);
      await HiveService.saveSetting(
        AppConstants.visualThemeKey,
        visualTheme.name,
      );
    } catch (e) {
      debugPrint('Failed to save visual theme: $e');
    }
  }
}

// Providers
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((
  ref,
) {
  return ThemeNotifier();
});

final themeProvider = Provider<AppTheme>((ref) {
  return ref.watch(themeNotifierProvider).appTheme;
});

final visualThemeProvider = Provider<VisualTheme>((ref) {
  return ref.watch(themeNotifierProvider).visualTheme;
});

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

// Theme Data Factories
ThemeData getThemeData(bool isDark, VisualTheme style) {
  final seedColor = style == VisualTheme.cyber
      ? const Color(0xFF00F2FF)
      : style == VisualTheme.bento
      ? const Color(0xFF6200EE)
      : const Color(0xFF137FEC);

  final baseTheme = ThemeData(
    useMaterial3: true,
    brightness: isDark ? Brightness.dark : Brightness.light,
    colorSchemeSeed: seedColor,
    fontFamily: style == VisualTheme.cyber ? 'Orbitron' : 'Inter',
  );

  if (style == VisualTheme.cyber) {
    return baseTheme.copyWith(
      scaffoldBackgroundColor: isDark ? const Color(0xFF050505) : Colors.white,
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF101010) : Colors.grey[100],
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: seedColor.withValues(alpha: 0.5), width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: seedColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }

  if (style == VisualTheme.bento) {
    return baseTheme.copyWith(
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
    );
  }

  // Monthly/Classic
  return baseTheme.copyWith(
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
