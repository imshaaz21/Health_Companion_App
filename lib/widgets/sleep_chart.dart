import 'package:flutter/material.dart';
import 'package:health_companion_app/models/sleep_data.dart';
import 'package:health_companion_app/providers/sleep_monitor_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SleepChart extends StatefulWidget {
  const SleepChart({super.key});

  @override
  State<SleepChart> createState() => _SleepChartState();
}

class _SleepChartState extends State<SleepChart> {
  late List<SleepData> data;
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    data = [
      SleepData('Wed', 5),
      SleepData('Thu', 7),
      SleepData('Fri', 6.5),
      SleepData('Sat', 6.4),
      SleepData('Sun', 3)
    ];
    _tooltip = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final sleepMonitorProvider =
        Provider.of<SleepMonitorProvider>(context, listen: true);

    debugPrint("Sleep map ${sleepMonitorProvider.sleepHistory}");
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 5),
          Text(
            'Sleep Chart for last 5 days',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          SfCartesianChart(
            primaryXAxis: const CategoryAxis(
              title: AxisTitle(text: 'Days'),
            ),
            primaryYAxis: const NumericAxis(
              title: AxisTitle(text: 'Hours'),
            ),

            // primaryYAxis:
            //     const NumericAxis(minimum: 0, maximum: 10, interval: 10),
            tooltipBehavior: _tooltip,
            series: <CartesianSeries<SleepData, String>>[
              ColumnSeries<SleepData, String>(
                dataSource: sleepMonitorProvider.sleepHistory.entries
                    .map((entry) => SleepData(entry.key, entry.value))
                    .toList(),
                xValueMapper: (SleepData sleep, _) => sleep.x,
                yValueMapper: (SleepData sleep, _) => sleep.y / 3600,
                name: 'Sleep hours',
                // dataLabelSettings: const DataLabelSettings(
                //   isVisible: true,
                // ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                // isVisibleInLegend: true,
                color: Colors.orange,
              )
            ],
          )
        ],
      ),
    );
  }
}
