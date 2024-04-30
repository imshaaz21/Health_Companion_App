import 'package:flutter/material.dart';
import 'package:health_companion_app/providers/step_counter_provider.dart';
import 'package:provider/provider.dart';

class StepsCard extends StatefulWidget {
  final String status;
  const StepsCard({
    super.key,
    required this.status,
  });

  @override
  State<StepsCard> createState() => _StepsCardState();
}

class _StepsCardState extends State<StepsCard> {
  @override
  Widget build(BuildContext context) {
    int totalSteps = 10000;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      surfaceTintColor: Colors.white,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Steps',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 10),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: CircularProgressIndicator(
                      value: Provider.of<StepCounterProvider>(context,
                                  listen: true)
                              .todaySteps /
                          totalSteps,
                      backgroundColor: Colors.grey[300]!,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                  ),
                  Icon(
                    widget.status == 'walking'
                        ? Icons.directions_walk
                        : widget.status == 'stopped'
                            ? Icons.accessibility_new
                            : Icons.accessibility_new,
                    size: 60,
                    color: Colors.orange,
                  ),
                  // print status
                ],
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                widget.status,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Text(
                '${Provider.of<StepCounterProvider>(context, listen: true).todaySteps} / $totalSteps',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 5),
            const Expanded(
              child: Center(
                child: Text(
                  'Today',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
