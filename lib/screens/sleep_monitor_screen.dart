import 'package:flutter/material.dart';

class SleepMonitorScreen extends StatelessWidget {
  const SleepMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Monitor'),
      ),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Center(
              child: Text('Sleep Monitor Screen'),
            ),
          )
        ],
      ),
      // bottomNavigationBar: const BottomNavBar(),
    );
  }
}
