import 'package:flutter/material.dart';
import 'package:run_walk_buddy/screens/splash_screen.dart';

import 'screens/run_walk_screen.dart';
import 'services/notification_service.dart';
import 'services/foreground_timer_service.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ForegroundTimerService.initializeCommunicationPort();
  await ForegroundTimerService.initialize();
  await NotificationService.initialize();

  runApp(const RunWalkBuddyApp());
}

class RunWalkBuddyApp extends StatelessWidget {
  const RunWalkBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RunWalk Buddy',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,

        colorScheme: const ColorScheme.dark(
          primary: AppColors.run,
          secondary: AppColors.walk,
          surface: AppColors.sheet,
          onSurface: AppColors.text,
          onPrimary: Color(0xFF1F2A10),
          onSecondary: Color(0xFF05343C),
        ),

        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: AppColors.text,
          ),
          bodySmall: TextStyle(
            color: AppColors.muted,
          ),
        ),

        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.button,
            foregroundColor: AppColors.onButton,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.muted,
            side: const BorderSide(
              color: AppColors.border,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      home: const SplashScreen(
  next: RunWalkHomePage(),
),
    );
  }
}