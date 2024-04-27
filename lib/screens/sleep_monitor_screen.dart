import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'dart:async';
import 'package:proximity_sensor/proximity_sensor.dart';

class SleepMonitorScreen extends StatefulWidget {
  const SleepMonitorScreen({super.key});

  @override
  State<SleepMonitorScreen> createState() => _SleepMonitorScreenState();
}

class _SleepMonitorScreenState extends State<SleepMonitorScreen> {
  bool _isNear = false;
  double _proximity = 0;
  late StreamSubscription<dynamic> _streamSubscription;

  @override
  void initState() {
    super.initState();
    listenSensor();
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

    // --------------------------------------------------------------------
    // You only need to make this call if you want to turn off the screen.
    await ProximitySensor.setProximityScreenOff(true)
        .onError((error, stackTrace) {
      debugPrint("could not enable screen off functionality");
      return null;
    });

    _streamSubscription = ProximitySensor.events.listen((int event) {
      debugPrint('Proximity: $event');
      setState(() {
        _isNear = (event > 0) ? true : false;
        _proximity = event.toDouble();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
                ],
              ),
            ),
          )
        ],
      ),
      // bottomNavigationBar: const BottomNavBar(),
    );
  }
}
