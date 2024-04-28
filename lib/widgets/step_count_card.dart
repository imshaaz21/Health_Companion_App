import 'package:flutter/material.dart';

class StepCountCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int value;
  final int total;

  const StepCountCard(
      {super.key,
      required this.title,
      required this.icon,
      required this.value,
      required this.total});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Status: ${value < total ? 'Walking' : 'Stopped'}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Icon(icon),
              ],
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: value / total,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 10),
            Text(
              '${value.toString()} / ${total.toString()} steps',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
