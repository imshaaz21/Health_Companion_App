import 'package:flutter/material.dart';
import 'package:health_companion_app/screens/dashboard_screen.dart';
import 'package:health_companion_app/screens/emotional_detector_screen.dart';
import 'package:health_companion_app/screens/home_screen.dart';
import 'package:health_companion_app/screens/sleep_monitor_screen.dart';
import 'package:health_companion_app/screens/step_counter_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ActiveAware',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/', // Set the initial route
      routes: {
        '/': (context) => const HomePage(), // Home page
        '/dashboard': (context) => const DashboardScreen(), // Dashboard screen
        '/step_counter': (context) =>
            const StepCounterScreen(), // Step Counter screen
        '/sleep_monitor': (context) =>
            const SleepMonitorScreen(), // Sleep Monitor screen
        '/emotional_detector': (context) =>
            const EmotionalDetectorScreen(), // Emotional Detector screen
      },
    );
  }
}
