import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:health_companion_app/providers/sleep_monitor_provider.dart';
import 'package:health_companion_app/utils/utils.dart';
import 'package:health_companion_app/widgets/sleep_chart.dart';
import 'dart:async';
// import 'package:light/light.dart';
import 'package:provider/provider.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SleepMonitorScreen extends StatefulWidget {
  const SleepMonitorScreen({super.key});

  @override
  State<SleepMonitorScreen> createState() => Accelerometer();
}

class Accelerometer extends State<SleepMonitorScreen> {
  bool _isNear = false;
  double _proximity = 0.0;
  late StreamSubscription<dynamic> _streamSubscription;
  DateTime? _sleepStartTime;
  bool _isSleeping = false;
  int _sleepDuration = 0; // in seconds
  // String _luxString = 'Unknown';
  // Light? _light;
  StreamSubscription? _subscription;
  double _activityThreshold = 0.5;
  Duration _activity_last_slept_time = const Duration(seconds: 0);

  // Accelerometer  subscription
  List<AccelerometerEvent> _accelerometerValues = [];
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;

  // void onData(int luxValue) async {
  //   // debugPrint("Lux value: $luxValue");
  //   Provider.of<SleepMonitorProvider>(context, listen: false)
  //       .updateLuxValue(luxValue.toDouble());
  //   setState(() {
  //     _luxString = "$luxValue";
  //   });
  // }

  // void stopListening() {
  //   _subscription?.cancel();
  // }

  // void startListeningLight() {
  //   _light = Light();
  //   try {
  //     _subscription = _light?.lightSensorStream.listen(onData);
  //   } on LightException catch (exception) {
  //     debugPrint(exception.toString());
  //   }
  // }

  @override
  void initState() {
    super.initState();
    listenSensor();
    // startListeningLight();

    _accelerometerSubscription =
        accelerometerEventStream().listen((AccelerometerEvent event) {
      double totalAcceleration = event.y.abs();
      if (totalAcceleration > _activityThreshold) {
        // Movement detected, potentially not sleeping
        if (_isSleeping) {
          // Person was sleeping, but now moving
          // Reset sleep tracking
          setState(() {
            _isSleeping = false;
            _sleepStartTime = null;
            if (_sleepDuration > 10) {
              _activity_last_slept_time = Duration(seconds: _sleepDuration);
              Provider.of<SleepMonitorProvider>(context, listen: false)
                  .addSleepData(_sleepDuration.toDouble());
              Provider.of<SleepMonitorProvider>(context, listen: false)
                  .updateSleepDuration(
                      formatDuration(_activity_last_slept_time));
            }
            _sleepDuration = 0;
          });
        }
      } else {
        // No significant movement, potentially sleeping
        if (!_isSleeping) {
          // Start sleep tracking
          _sleepStartTime = DateTime.now();
          _isSleeping = true;
        } else {
          // Check if sleep duration is more than one hour
          if (_sleepStartTime != null &&
              DateTime.now().difference(_sleepStartTime!) >=
                  const Duration(seconds: 10)) {
            // Person is sleeping for more than one hour
            // Consider it as sleeping
            Duration sleepDuration =
                DateTime.now().difference(_sleepStartTime!);
            debugPrint(
                'Person is sleeping for more than 1/2 hour: $sleepDuration');
            setState(() {
              _sleepDuration = sleepDuration.inSeconds;
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
    _accelerometerSubscription.cancel();
    _subscription?.cancel();
  }

  Future<void> listenSensor() async {
    debugPrint('listening to sensor...');
    FlutterError.onError = (FlutterErrorDetails details) {
      if (foundation.kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      }
    };

    _streamSubscription = ProximitySensor.events.listen((int event) {
      debugPrint('Proximity: $event');
      //   setState(() {
      //     _proximity = event.toDouble();
      //     _isNear = (_proximity > 0);
      //     if (_isNear) {
      //       // Proximity sensor is near, potentially sleeping
      //       if (!_isSleeping) {
      //         // Start sleep tracking
      //         _sleepStartTime = DateTime.now();
      //         _isSleeping = true;
      //       } else {
      //         // Check if sleep duration is more than one hour
      //         if (_sleepStartTime != null &&
      //             DateTime.now().difference(_sleepStartTime!) >=
      //                 const Duration(seconds: 10)) {
      //           // Person is sleeping for more than one hour
      //           // Consider it as sleeping
      //           // Perform your logic here, for example, show sleep duration
      //           Duration sleepDuration =
      //               DateTime.now().difference(_sleepStartTime!);
      //           debugPrint(
      //               'Person is sleeping for more than one hour: $sleepDuration');
      //           setState(() {
      //             _sleepDuration = sleepDuration.inSeconds;
      //           });
      //           // You can perform any action here, such as showing sleep duration
      //         }
      //       }
      //     } else {
      //       // Proximity sensor is not near, waking up
      //       _isSleeping = false;
      //       _sleepStartTime = null; // Reset sleep start time
      //     }
      //   });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Minimum sleep time
    debugPrint(_accelerometerValues.toString());

    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text(
          'Sleep Monitor',
          style: TextStyle(fontWeight: FontWeight.w600),
        )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  elevation: 5,
                  surfaceTintColor:
                      _sleepDuration > 10 ? Colors.black : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // First Row: Sleeping Icon and Sleeping Duration
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              _sleepDuration > 10
                                  ? Icons.bedtime // Sleeping icon
                                  : Icons.wb_sunny, // Not sleeping icon
                              size: 60,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 10),
                            // Column for Sleeping Duration
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _sleepDuration > 10
                                      ? 'Sleeping Duration:'
                                      : 'Not Sleeping',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _sleepDuration > 10
                                      ? formatDuration(
                                          Duration(seconds: _sleepDuration))
                                      : '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // // Second Row: Sleeping Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Sleeping Status:',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _sleepDuration > 10 ? 'Sleeping' : 'Not Sleeping',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // // Last sleep Time
                        Text(
                          'Last sleep Time: ${Provider.of<SleepMonitorProvider>(context, listen: true).sleepDuration}',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Card(
                elevation: 5,
                surfaceTintColor: Colors.white,
                child: SleepChart(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
