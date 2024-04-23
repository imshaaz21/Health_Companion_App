import 'package:flutter/material.dart';
import 'package:health_companion_app/common/bottom_nav.dart';

class EmotionalDetectorScreen extends StatelessWidget {
  const EmotionalDetectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emotional Detector'),
      ),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Center(
              child: Text('Emotional Detector Screen'),
            ),
          )
        ],
      ),
      // bottomNavigationBar: const BottomNavBar(),
    );
  }
}
