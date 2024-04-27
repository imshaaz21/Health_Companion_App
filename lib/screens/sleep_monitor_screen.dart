import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'dart:async';
import 'package:light/light.dart';
import 'package:proximity_sensor/proximity_sensor.dart';

class SleepMonitorScreen extends StatefulWidget {
  const SleepMonitorScreen({super.key});

  @override
  State<SleepMonitorScreen> createState() => _SleepMonitorScreenState();
}

class _SleepMonitorScreenState extends State<SleepMonitorScreen> {
  bool _isNear = false;
  double _proximity = 0.0;
  late StreamSubscription<dynamic> _streamSubscription;
  DateTime? _sleepStartTime;
  int _sleepDuration = 0; // in seconds

  String _luxString = 'Unknown';
  Light? _light;
  StreamSubscription? _subscription;

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
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
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
        _isNear = (event > 0) ? true : false;
        _proximity = event.toDouble();

        if (_isNear) {
          // Start sleep timer if not already sleeping
          _sleepStartTime ??= DateTime.now();
        } else {
          // Reset sleep timer if person moves away
          _sleepStartTime = null;
          _sleepDuration = 0;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final minimumSleepDuration = Duration(minutes: 10); // Minimum sleep time

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
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
