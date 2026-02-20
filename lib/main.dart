import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:calendar_craft/core/services/hive_service.dart';
import 'package:calendar_craft/core/services/firestore_service.dart';
import 'package:calendar_craft/core/services/notification_service.dart';
import 'package:calendar_craft/presentation/providers/theme_provider.dart';
import 'package:calendar_craft/presentation/pages/main_navigation_page.dart';
import 'package:calendar_craft/presentation/pages/onboarding_page.dart';
import 'package:calendar_craft/presentation/providers/onboarding_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize services
  await Firebase.initializeApp();
  await FirestoreService().signInAnonymously();
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
    final onboardingComplete = ref.watch(onboardingProvider);

    return MaterialApp(
      title: 'Calendar Craft',
      debugShowCheckedModeBanner: false,
      theme: getThemeData(false, visualTheme),
      darkTheme: getThemeData(true, visualTheme),
      themeMode: themeMode,
      home: onboardingComplete
          ? const MainNavigationPage()
          : const OnboardingPage(),
    );
  }
}
