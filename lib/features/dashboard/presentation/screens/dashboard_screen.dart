import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_layout.dart';
import '../widgets/index.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isDesktop = width >= 600;

          final tableCards = [const DataTableCard(), const EmployeeTableCard()];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;
                    // Calculate search bar width based on screen size
                    final searchBarWidth = switch (screenWidth) {
                      > 1200 => 300.0,
                      > 800 => 250.0,
                      > 600 => 200.0,
                      _ => 150.0,
                    };

                    return Row(
                      children: [
                        const SizedBox(width: 8),
                        if (screenWidth > 600) ...[
                          const Text(
                            'Dashboard',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                        ],
                        Container(
                          width: searchBarWidth,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: screenWidth > 600 ? 'Recherche...' : '',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: screenWidth > 800 ? 14 : 12,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                size: screenWidth > 800 ? 20 : 18,
                                color: Colors.grey[400],
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: screenWidth > 800 ? 16 : 12,
                                vertical: screenWidth > 800 ? 12 : 8,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth > 800 ? 16 : 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            constraints: BoxConstraints(
                              minWidth: screenWidth > 800 ? 40 : 32,
                              minHeight: screenWidth > 800 ? 40 : 32,
                            ),
                            icon: Icon(
                              Icons.notifications_none,
                              color: Colors.grey[600],
                              size: screenWidth > 800 ? 20 : 18,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Responsive main row: summary, quantity, line chart, regions card
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 1000;
                    final isTablet =
                        constraints.maxWidth >= 700 &&
                        constraints.maxWidth < 1000;

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: SummaryCard(
                                                  title: 'Clients',
                                                  value: '781',
                                                  change: '+11.01%',
                                                  color: AppColors.greenLight,
                                                  width:
                                                      constraints.maxWidth *
                                                      0.2,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: SummaryCard(
                                                  title: 'Quantité',
                                                  value: '1219 T',
                                                  change: '-0.03%',
                                                  color: AppColors.yellowDark,
                                                  width:
                                                      constraints.maxWidth *
                                                      0.2,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: SummaryCard(
                                                  title: 'Revenu',
                                                  value: '695 DT',
                                                  change: '+15.03%',
                                                  color: AppColors.yellowLight,
                                                  width:
                                                      constraints.maxWidth *
                                                      0.2,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: SummaryCard(
                                                  title: 'Dépenses',
                                                  value: '305 DT',
                                                  change: '+6.08%',
                                                  color: AppColors.greenDark,
                                                  width:
                                                      constraints.maxWidth *
                                                      0.2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    // Quantity details card
                                    Expanded(
                                      flex: 2,
                                      child: QuantityDetailsCard(
                                        width: constraints.maxWidth * 0.25,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Line chart
                                const SizedBox(
                                  height: 300,
                                  child: LineChartCard(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Right side: regions card (PieChartCard)
                          Expanded(
                            flex: 4,
                            child: SizedBox(height: 600, child: PieChartCard()),
                          ),
                        ],
                      );
                    } else if (isTablet) {
                      // Tablet layout: summary+quantity+regions stacked, line chart below
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SummaryCard(
                                            title: 'Clients',
                                            value: '781',
                                            change: '+11.01%',
                                            color: AppColors.greenLight,
                                            width: constraints.maxWidth * 0.3,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: SummaryCard(
                                            title: 'Quantité',
                                            value: '1219 T',
                                            change: '-0.03%',
                                            color: AppColors.yellowDark,
                                            width: constraints.maxWidth * 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SummaryCard(
                                            title: 'Revenu',
                                            value: '695 DT',
                                            change: '+15.03%',
                                            color: AppColors.yellowLight,
                                            width: constraints.maxWidth * 0.3,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: SummaryCard(
                                            title: 'Dépenses',
                                            value: '305 DT',
                                            change: '+6.08%',
                                            color: AppColors.greenDark,
                                            width: constraints.maxWidth * 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: QuantityDetailsCard(
                                  width: constraints.maxWidth * 0.3,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(height: 350, child: PieChartCard()),
                          const SizedBox(height: 16),
                          const SizedBox(height: 250, child: LineChartCard()),
                        ],
                      );
                    } else {
                      // Mobile layout: everything stacked
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SummaryCard(
                            title: 'Clients',
                            value: '781',
                            change: '+11.01%',
                            color: AppColors.greenLight,
                            width: constraints.maxWidth,
                          ),
                          const SizedBox(height: 12),
                          SummaryCard(
                            title: 'Quantité',
                            value: '1219 T',
                            change: '-0.03%',
                            color: AppColors.yellowDark,
                            width: constraints.maxWidth,
                          ),
                          const SizedBox(height: 12),
                          SummaryCard(
                            title: 'Revenu',
                            value: '695 DT',
                            change: '+15.03%',
                            color: AppColors.yellowLight,
                            width: constraints.maxWidth,
                          ),
                          const SizedBox(height: 12),
                          SummaryCard(
                            title: 'Dépenses',
                            value: '305 DT',
                            change: '+6.08%',
                            color: AppColors.greenDark,
                            width: constraints.maxWidth,
                          ),
                          const SizedBox(height: 12),
                          QuantityDetailsCard(width: constraints.maxWidth),
                          const SizedBox(height: 16),
                          SizedBox(height: 250, child: LineChartCard()),
                          const SizedBox(height: 16),
                          SizedBox(height: 350, child: PieChartCard()),
                        ],
                      );
                    }
                  },
                ),

                const SizedBox(height: 24),

                // Tables grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isDesktop ? 2 : 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isDesktop ? 1.2 : 1,
                  children: tableCards,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
