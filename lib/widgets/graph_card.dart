import 'package:flutter/material.dart';
import 'package:health_companion_app/models/health_data.dart';
import 'package:health_companion_app/providers/step_counter_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HealthChart extends StatefulWidget {
  final List<StepCountData> stepCounts;

  const HealthChart({super.key, required this.stepCounts});

  @override
  State<HealthChart> createState() => _HealthChartState();
}

class _HealthChartState extends State<HealthChart> {
  final List<String> _days = [];

  @override
  void initState() {
    super.initState();

    debugPrint(Provider.of<StepCounterProvider>(context, listen: false)
        .stepsMap
        .toString());

    // Calculate day labels for the past 5 days (assuming today is Sunday)
    for (int i = 0; i < 5; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      _days.add(DateFormat('E').format(date)); // Use DateFormat for day labels
    }
    debugPrint('Days: $_days');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      surfaceTintColor: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Text(
                "Step Count Graph for the past 5 days",
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SfCartesianChart(
                  primaryXAxis: const CategoryAxis(),
                  series: <CartesianSeries>[
                    ColumnSeries<StepCountData, int>(
                      dataSource: _days.map((day) {
                        final dayIndex = _days.indexOf(day);
                        final stepCount = widget.stepCounts.firstWhere(
                            (data) => data.dayIndex == dayIndex,
                            orElse: () => StepCountData(dayIndex, 0));
                        return stepCount;
                      }).toList(),
                      xValueMapper: (StepCountData data, _) => data.dayIndex,
                      yValueMapper: (StepCountData data, _) => data.stepCount,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      // isVisibleInLegend: true,
                      color: Colors.orange,
                    )
                  ]),
            ],
          ),
        ),
      ),
    );
  }
}
