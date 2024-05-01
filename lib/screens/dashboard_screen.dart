import 'dart:async';

import 'package:flutter/material.dart';
import 'package:health_companion_app/providers/emotional_detector_provider.dart';
import 'package:health_companion_app/providers/sleep_monitor_provider.dart';
import 'package:health_companion_app/providers/step_counter_provider.dart';
import 'package:health_companion_app/utils/utils.dart';
import 'package:light/light.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _luxString = 'Unknown';
  double _luxValue = 0;
  Light? _light;
  StreamSubscription? _subscription;

  void onData(int luxValue) async {
    // debugPrint("Lux value: $luxValue $_luxString");
    setState(() {
      _luxString = getLightCondition(luxValue.toDouble());
      _luxValue = luxValue.toDouble();
    });
  }

  void stopListening() {
    _subscription?.cancel();
  }

  void startListening() {
    _light = Light();
    try {
      _subscription = _light?.lightSensorStream.listen(onData);
    } on LightException catch (exception) {
      debugPrint(exception.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    startListening();
  }

  // dispose method to cancel the subscription
  @override
  void dispose() {
    super.dispose();
    stopListening();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Dashboard',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'images/healthcare.png', // Path to your logo asset
                  height: 100, // Adjust the height of the logo as needed
                ),
                const SizedBox(height: 20),
                Card(
                  surfaceTintColor: Colors.white,
                  elevation: 5,
                  child: SizedBox(
                    height: 100,
                    child: Center(
                      child: ListTile(
                        title: const Text('Step Counter'),
                        subtitle: Text(
                            "Today's total Steps: ${Provider.of<StepCounterProvider>(context, listen: true).todaySteps}"),
                        trailing: const Icon(
                          Icons.directions_walk,
                          color: Colors.orange,
                          size: 40,
                        ),
                        onTap: () =>
                            Navigator.pushNamed(context, '/step_counter'),
                      ),
                    ),
                  ),
                ),
                // Card for Sleep Monitor
                const SizedBox(height: 10),
                Card(
                  surfaceTintColor: Colors.white,
                  elevation: 5,
                  child: SizedBox(
                    height: 100,
                    child: Center(
                      child: ListTile(
                        title: const Text('Sleep Monitor'),
                        subtitle: Text(
                          "Last total Sleep: ${(Provider.of<SleepMonitorProvider>(context, listen: true).todaysSleepDurationFormatted)}",
                        ),
                        trailing: const Icon(
                          Icons.local_hotel,
                          color: Colors.orange,
                          size: 40,
                        ),
                        onTap: () =>
                            Navigator.pushNamed(context, '/sleep_monitor'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  surfaceTintColor: Colors.white,
                  elevation: 5,
                  child: SizedBox(
                    height: 100,
                    child: Center(
                      child: ListTile(
                        title: const Text('Emotional Detector'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Last Test Result: ${Provider.of<EmotionalDetectorProvider>(context, listen: true).getLatestMood()}'),
                            Text(
                              'You last test was on ${Provider.of<EmotionalDetectorProvider>(context, listen: true).getLatestTestDate()} \nScore was ${Provider.of<EmotionalDetectorProvider>(context, listen: true).getLatestTestScore().toStringAsFixed(1)} %',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Provider.of<EmotionalDetectorProvider>(
                                        context,
                                        listen: true)
                                    .getLatestTestScore() <
                                50
                            ? const Icon(
                                Icons.sentiment_very_dissatisfied,
                                color: Colors.redAccent,
                                size: 40,
                              )
                            : Provider.of<EmotionalDetectorProvider>(context,
                                            listen: true)
                                        .getLatestTestScore() <
                                    70
                                ? const Icon(
                                    Icons.sentiment_neutral,
                                    color: Colors.orange,
                                    size: 40,
                                  )
                                : const Icon(
                                    Icons.sentiment_very_satisfied,
                                    color: Colors.green,
                                    size: 40,
                                  ),
                        onTap: () =>
                            Navigator.pushNamed(context, '/emotional_detector'),
                      ),
                    ),
                  ),
                ),
                // lux meter card
                const SizedBox(height: 10),
                Card(
                  surfaceTintColor: Colors.white,
                  elevation: 5,
                  child: SizedBox(
                    height: 120,
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Light Condition'),

                          // subtitle: Text(
                          //     '${Provider.of<SleepMonitorProvider>(context, listen: true).lightCondition}: ${Provider.of<SleepMonitorProvider>(context, listen: true).luxValue.toInt()} lux'),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),
                              Text(
                                '$_luxString : $_luxValue lux\n',
                                style: TextStyle(
                                  color: _luxValue < 20
                                      ? Colors.redAccent
                                      : _luxValue < 100
                                          ? Colors.orange
                                          : Colors.green,
                                ),
                              ),
                              Text(
                                  // good condition, bad condition
                                  _luxValue < 20
                                      ? 'Very poor Light'
                                      : _luxValue < 100
                                          ? 'Poor Light'
                                          : 'Good Light',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _luxValue < 20
                                        ? Colors.redAccent
                                        : _luxValue < 100
                                            ? Colors.orange
                                            : Colors.green,
                                  )),
                            ],
                          ),
                          trailing: Icon(
                            Icons.lightbulb,
                            color: _luxValue < 20
                                ? Colors.redAccent
                                : Colors.green,
                            size: 40,
                          ),
                          // below the method are check the _lux light and insert text Low light, Medium light, High light
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // bottomNavigationBar: const BottomNavBar(),
    );
  }
}
