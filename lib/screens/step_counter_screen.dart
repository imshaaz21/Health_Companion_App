import 'package:flutter/material.dart';
import 'package:health_companion_app/models/health_data.dart';
import 'package:health_companion_app/providers/step_counter_provider.dart';
import 'dart:async';
import 'package:health_companion_app/services/pedometer.dart';
import 'package:health_companion_app/utils/utils.dart';
import 'package:health_companion_app/widgets/calories_card.dart';
import 'package:health_companion_app/widgets/graph_card.dart';
import 'package:health_companion_app/widgets/steps_card.dart';
import 'package:provider/provider.dart';

class StepCounterScreen extends StatefulWidget {
  const StepCounterScreen({super.key});

  @override
  State<StepCounterScreen> createState() => _StepCounterScreenState();
}

String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}

class _StepCounterScreenState extends State<StepCounterScreen> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = 'stopped', _steps = '0';

  @override
  void initState() {
    super.initState();
    debugPrint('StepCounterScreenState: initState');
    initPlatformState();
  }

  void onStepCount(StepCount event) {
    debugPrint('"Event" : $event');
    Provider.of<StepCounterProvider>(context, listen: false).addSteps(
      formatDateForProvider(DateTime.now()),
      int.parse(event.steps.toString()),
    );
    setState(() {
      _steps = event.steps.toString();
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    debugPrint(event.toString());
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    debugPrint(error.toString());
    setState(() {
      _status = 'Pedestrian Status not available';
    });
  }

  void onStepCountError(error) {
    debugPrint('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width / 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step Counter'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 10),
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: cardWidth + 50,
                            width: cardWidth,
                            child: StepsCard(
                              status: _status,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: cardWidth + 50,
                            width: cardWidth,
                            child: const CaloriesCard(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: HealthChart(stepCounts: [
                      StepCountData(0, 1000),
                      StepCountData(1, 2000),
                      StepCountData(2, 3000),
                      StepCountData(3, 4000),
                      StepCountData(4, 5000),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
