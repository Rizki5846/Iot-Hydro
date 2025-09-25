import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SensorChart extends StatelessWidget {
  final List<double> data;
  final Color color;
  final String label;

  const SensorChart({
    super.key,
    required this.data,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final chartData = data
        .asMap()
        .entries
        .map((e) => _ChartData(x: e.key.toString(), y: e.value))
        .toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 180,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(),
                series: <LineSeries<_ChartData, String>>[
                  LineSeries<_ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (_ChartData d, _) => d.x,
                    yValueMapper: (_ChartData d, _) => d.y,
                    color: color,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartData {
  final String x;
  final double y;
  _ChartData({required this.x, required this.y});
}
