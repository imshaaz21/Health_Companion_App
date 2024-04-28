import 'package:flutter/material.dart';

class StepsCard extends StatefulWidget {
  final String currentSteps;
  final String status;
  const StepsCard({
    super.key,
    required this.currentSteps,
    required this.status,
  });

  @override
  State<StepsCard> createState() => _StepsCardState();
}

class _StepsCardState extends State<StepsCard> {
  @override
  Widget build(BuildContext context) {
    int currentSteps = 10000;
    int totalSteps = 20000;

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
                      value: int.parse(widget.currentSteps) / totalSteps,
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
                            : Icons.numbers,
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
                '${widget.currentSteps} / $totalSteps',
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
