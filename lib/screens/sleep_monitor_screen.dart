import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'dart:async';
import 'package:light/light.dart';
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
  String _luxString = 'Unknown';
  Light? _light;
  StreamSubscription? _subscription;

  // Accelerometer  subscription
  List<AccelerometerEvent> _accelerometerValues = [];
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;

  void onData(int luxValue) async {
    debugPrint("Lux value: $luxValue");
    setState(() {
      _luxString = "$luxValue";
    });
  }

  void stopListening() {
    _subscription?.cancel();
  }

  void startListeningLight() {
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
    listenSensor();
    startListeningLight();

    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      setState(() {
        // Update the _accelerometerValues list with the latest event
        _accelerometerValues = [event];
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
    _accelerometerSubscription.cancel();
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
      setState(() {
        _proximity = event.toDouble();
        _isNear = (_proximity > 0);
        if (_isNear) {
          // Proximity sensor is near, potentially sleeping
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
              // Perform your logic here, for example, show sleep duration
              Duration sleepDuration =
                  DateTime.now().difference(_sleepStartTime!);
              debugPrint(
                  'Person is sleeping for more than one hour: $sleepDuration');
              setState(() {
                _sleepDuration = sleepDuration.inSeconds;
              });
              // You can perform any action here, such as showing sleep duration
            }
          }
        } else {
          // Proximity sensor is not near, waking up
          _isSleeping = false;
          _sleepStartTime = null; // Reset sleep start time
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Minimum sleep time
    debugPrint(_accelerometerValues.toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Monitor'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Proximity: $_proximity',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Is Near: $_isNear',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Sleep Duration: ${_sleepDuration > 0 ? Duration(seconds: _sleepDuration) : 'Not Sleeping'}',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Lux: $_luxString',
                    style: const TextStyle(fontSize: 24),
                  ),
                  Card(
                      color: Colors.white,
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Builder(builder: (context) {
                          if (_accelerometerValues.isNotEmpty) {
                            final AccelerometerEvent event =
                                _accelerometerValues.first;
                            return Column(
                              children: <Widget>[
                                const Text('Accelerometer:'),
                                Text('X: ${event.x}'),
                                Text('Y: ${event.y}'),
                                Text('Z: ${event.z}'),
                              ],
                            );
                          } else {
                            return const Text('No data');
                          }
                        }),
                      ))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
