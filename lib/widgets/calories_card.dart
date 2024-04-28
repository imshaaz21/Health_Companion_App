import 'package:flutter/material.dart';

class CaloriesCard extends StatelessWidget {
  const CaloriesCard({super.key});

  @override
  Widget build(BuildContext context) {
    int caloriesBurned = 300;
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
              'Calories',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 15),
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.whatshot,
                    color: Colors.orange,
                    size: 60,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$caloriesBurned kcal',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
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
