import 'package:flutter/material.dart';
import 'package:health_companion_app/providers/sleep_monitor_provider.dart';
import 'package:health_companion_app/providers/step_counter_provider.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Dashboard',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'images/healthcare.png', // Path to your logo asset
                  height: 100, // Adjust the height of the logo as needed
                ),
                const SizedBox(height: 20),
                Card(
                  surfaceTintColor: Colors.white,
                  elevation: 5,
                  child: SizedBox(
                    height: 100,
                    child: Center(
                      child: ListTile(
                        title: const Text('Step Counter'),
                        subtitle: Text(
                            "Today's total Steps: ${Provider.of<StepCounterProvider>(context, listen: true).todaySteps}"),
                        trailing: const Icon(
                          Icons.directions_walk,
                          color: Colors.orange,
                          size: 40,
                        ),
                        onTap: () =>
                            Navigator.pushNamed(context, '/step_counter'),
                      ),
                    ),
                  ),
                ),
                // Card for Sleep Monitor
                const SizedBox(height: 20),
                Card(
                  surfaceTintColor: Colors.white,
                  elevation: 5,
                  child: SizedBox(
                    height: 100,
                    child: Center(
                      child: ListTile(
                        title: const Text('Sleep Monitor'),
                        subtitle: Text(
                          "Last total Sleep: ${(Provider.of<SleepMonitorProvider>(context, listen: true).todaysSleepDurationFormatted)}",
                        ),
                        trailing: const Icon(
                          Icons.local_hotel,
                          color: Colors.orange,
                          size: 40,
                        ),
                        onTap: () =>
                            Navigator.pushNamed(context, '/sleep_monitor'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  surfaceTintColor: Colors.white,
                  elevation: 5,
                  child: SizedBox(
                    height: 100,
                    child: Center(
                      child: ListTile(
                        title: const Text('Emotional Detector'),
                        subtitle: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Last Test Result: Happy'),
                            Text(
                              'You last test was on 12/12 : score was 80%',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.sentiment_very_satisfied,
                          color: Colors.orange,
                          size: 40,
                        ),
                        onTap: () =>
                            Navigator.pushNamed(context, '/emotional_detector'),
                      ),
                    ),
                  ),
                ),
                // lux meter card
                const SizedBox(height: 20),
                Card(
                  surfaceTintColor: Colors.white,
                  elevation: 5,
                  child: SizedBox(
                    height: 100,
                    child: Center(
                      child: ListTile(
                        title: const Text('Light Condition'),
                        subtitle: Text(
                            '${Provider.of<SleepMonitorProvider>(context, listen: true).lightCondition}: ${Provider.of<SleepMonitorProvider>(context, listen: true).luxValue.toInt()} lux'),
                        trailing: const Icon(
                          Icons.lightbulb_outline_rounded,
                          color: Colors.orange,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // bottomNavigationBar: const BottomNavBar(),
    );
  }
}
