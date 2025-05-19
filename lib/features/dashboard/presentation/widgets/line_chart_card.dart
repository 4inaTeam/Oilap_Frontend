import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';

class LineChartCard extends StatefulWidget {
  const LineChartCard({Key? key}) : super(key: key);

  @override
  State<LineChartCard> createState() => _LineChartCardState();
}

class _LineChartCardState extends State<LineChartCard> {
  String _selectedMonth = 'Janvier';
  final List<String> _months = [
    'Janvier',
    'Février',
    'Mars',
    'Avril',
    'Mai',
    'Juin',
    'Juillet',
    'Août',
    'Septembre',
    'Octobre',
    'Novembre',
    'Décembre',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Activités',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedMonth,
                      icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                      isDense: true,
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: 14,
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedMonth = newValue;
                          });
                        }
                      },
                      items:
                          _months.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ],
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
                        getTitlesWidget: (value, meta) {
                          if (value == 5 ||
                              value == 10 ||
                              value == 15 ||
                              value == 20) {
                            return Text(value.toInt().toString());
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          const titles = ['0', 'w1', 'w2', 'w3', 'w4'];
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
                        FlSpot(0, 17),
                        FlSpot(1, 15),
                        FlSpot(2, 13),
                        FlSpot(3, 14),
                        FlSpot(4, 11),
                      ],
                      isCurved: true,
                      color: AppColors.accentGreen,
                      barWidth: 2,
                      dotData: FlDotData(show: true),
                    ),
                    // Second line (yellow)
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 9),
                        FlSpot(1, 10),
                        FlSpot(2, 8),
                        FlSpot(3, 12),
                        FlSpot(4, 13),
                      ],
                      isCurved: true,
                      color: AppColors.accentYellow,
                      barWidth: 2,
                      dotData: FlDotData(show: true),
                    ),
                    // Third line (light green)
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 8),
                        FlSpot(1, 5),
                        FlSpot(2, 7),
                        FlSpot(3, 6),
                        FlSpot(4, 9),
                      ],
                      isCurved: true,
                      color: Colors.lightGreen,
                      barWidth: 2,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                  minX: 0,
                  maxX: 4,
                  minY: 3,
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
