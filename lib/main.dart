import 'package:flutter/material.dart';
import 'package:health_companion_app/providers/emotional_detector_provider.dart';
import 'package:health_companion_app/providers/sleep_monitor_provider.dart';
import 'package:health_companion_app/providers/step_counter_provider.dart';
// Import other provider files if available

import 'package:health_companion_app/screens/dashboard_screen.dart';
import 'package:health_companion_app/screens/emotional_detector_screen.dart';
import 'package:health_companion_app/screens/home_screen.dart';
import 'package:health_companion_app/screens/sleep_monitor_screen.dart';
import 'package:health_companion_app/screens/step_counter_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => StepCounterProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => SleepMonitorProvider(),
        ),
        ChangeNotifierProvider(
            create: (context) => EmotionalDetectorProvider()),
      ],
      child: MaterialApp(
        title: 'ActiveAware',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/dashboard': (context) => const DashboardScreen(),
          '/step_counter': (context) => const StepCounterScreen(),
          '/sleep_monitor': (context) => const SleepMonitorScreen(),
          '/emotional_detector': (context) => const EmotionalDetectorScreen(),
        },
      ),
    );
  }
}
