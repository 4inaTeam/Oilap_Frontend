import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';

class LineChartCard extends StatelessWidget {
  const LineChartCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activités',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        reservedSize: 30,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          const titles = ['w1', 'w2', 'w3', 'w4'];
                          if (value.toInt() < 0 ||
                              value.toInt() >= titles.length) {
                            return const Text('');
                          }
                          return Text(titles[value.toInt()]);
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    // First line (green)
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 15),
                        FlSpot(1, 12),
                        FlSpot(2, 14),
                        FlSpot(3, 11),
                      ],
                      isCurved: true,
                      color: AppColors.accentGreen,
                      barWidth: 2,
                      dotData: FlDotData(show: true),
                    ),
                    // Second line (yellow)
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 10),
                        FlSpot(1, 8),
                        FlSpot(2, 12),
                        FlSpot(3, 13),
                      ],
                      isCurved: true,
                      color: AppColors.accentYellow,
                      barWidth: 2,
                      dotData: FlDotData(show: true),
                    ),
                    // Third line (light green)
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 5),
                        FlSpot(1, 7),
                        FlSpot(2, 6),
                        FlSpot(3, 9),
                      ],
                      isCurved: true,
                      color: Colors.lightGreen,
                      barWidth: 2,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                  minX: 0,
                  maxX: 3,
                  minY: 0,
                  maxY: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
