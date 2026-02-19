import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:calendar_craft/core/services/hive_service.dart';
import 'package:calendar_craft/core/services/notification_service.dart';
import 'package:calendar_craft/presentation/providers/theme_provider.dart';
import 'package:calendar_craft/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await Firebase.initializeApp();
  await HiveService.init();
  await NotificationService().init();

  runApp(const ProviderScope(child: CalendarCraftApp()));
}

class CalendarCraftApp extends ConsumerWidget {
  const CalendarCraftApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final visualTheme = ref.watch(visualThemeProvider);

    return MaterialApp(
      title: 'Calendar Craft',
      debugShowCheckedModeBanner: false,
      theme: getThemeData(false, visualTheme),
      darkTheme: getThemeData(true, visualTheme),
      themeMode: themeMode,
      home: const HomePage(),
    );
  }
}
