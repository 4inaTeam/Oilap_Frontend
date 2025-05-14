import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import 'legend_item.dart';

class PieChartCard extends StatelessWidget {
  const PieChartCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Principales régions fournissant des olives',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: 38.58,
                            color: AppColors.accentGreen,
                            title: '38.58%',
                            radius: 80,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          PieChartSectionData(
                            value: 14.94,
                            color: Colors.lightGreen.shade200,
                            title: '14.94%',
                            radius: 80,
                            titleStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                          PieChartSectionData(
                            value: 14.94,
                            color: AppColors.accentYellow,
                            title: '14.94%',
                            radius: 80,
                            titleStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                          PieChartSectionData(
                            value: 14.94,
                            color: Colors.lightGreen.shade400,
                            title: '14.94%',
                            radius: 80,
                            titleStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        sectionsSpace: 0,
                        centerSpaceRadius: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LegendItem(
                        color: AppColors.accentGreen,
                        label: 'Region A',
                      ),
                      const SizedBox(height: 24),
                      LegendItem(
                        color: Colors.lightGreen.shade200,
                        label: 'Region B',
                      ),
                      const SizedBox(height: 24),
                      LegendItem(
                        color: AppColors.accentYellow,
                        label: 'Region C',
                      ),
                      const SizedBox(height: 24),
                      LegendItem(
                        color: Colors.lightGreen.shade400,
                        label: 'Others',
                      ),
                    ],
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
