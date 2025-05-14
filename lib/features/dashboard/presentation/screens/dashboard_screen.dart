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
          final isDesktop = width >= 800;
          final isTablet = width >= 600 && width < 800;
          final summaryColumns =
              isDesktop
                  ? 4
                  : isTablet
                  ? 2
                  : 1;
          final summaryCardWidth =
              (width - (summaryColumns - 1) * 16) / summaryColumns;

          // Summary cards and other sections
          final summaryCards = [
            SummaryCard(
              title: 'Clients',
              value: '781',
              change: '+11.01%',
              color: AppColors.backgroundLight,
              width: summaryCardWidth,
            ),
            SummaryCard(
              title: 'Quantité',
              value: '1219 T',
              change: '-0.03%',
              color: AppColors.accentYellow,
              width: summaryCardWidth,
            ),
            SummaryCard(
              title: 'Revenu',
              value: '695 DT',
              change: '+15.03%',
              color: AppColors.backgroundLight,
              width: summaryCardWidth,
            ),
            SummaryCard(
              title: 'Dépenses',
              value: '305 DT',
              change: '+6.08%',
              color: AppColors.accentGreen,
              width: summaryCardWidth,
            ),
            QuantityDetailsCard(width: summaryCardWidth),
          ];
          final chartCards = [const LineChartCard(), const PieChartCard()];
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
                      > 1200 => 300.0, // Desktop
                      > 800 => 250.0, // Tablet
                      > 600 => 200.0, // Small tablet
                      _ => 150.0, // Mobile
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

                // Summary section with three columns layout
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left side - Summary Cards
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          // First row of summary cards
                          Row(
                            children: [
                              Expanded(
                                child: SummaryCard(
                                  title: 'Clients',
                                  value: '781',
                                  change: '+11.01%',
                                  color: AppColors.greenLight,
                                  width: width * 0.2,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: SummaryCard(
                                  title: 'Quantité',
                                  value: '1219 T',
                                  change: '-0.03%',
                                  color: AppColors.yellowDark,
                                  width: width * 0.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Second row of summary cards
                          Row(
                            children: [
                              Expanded(
                                child: SummaryCard(
                                  title: 'Revenu',
                                  value: '695 DT',
                                  change: '+15.03%',
                                  color: AppColors.yellowLight,
                                  width: width * 0.2,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: SummaryCard(
                                  title: 'Dépenses',
                                  value: '305 DT',
                                  change: '+6.08%',
                                  color: AppColors.greenDark,
                                  width: width * 0.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (width >= 800) ...[
                      // Middle - Quantity Details Card
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 2,
                        child: QuantityDetailsCard(width: width * 0.2),
                      ),

                      // Right side - Pie Chart
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 400, // Increased height for pie chart
                          child: const PieChartCard(),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 24),

                // Line Chart placed directly under the cards
                const SizedBox(height: 300, child: LineChartCard()),

                const SizedBox(height: 24),

                if (width < 800) ...[
                  QuantityDetailsCard(width: width),
                  const SizedBox(height: 24),
                  const SizedBox(
                    height: 400, // Increased height for pie chart
                    child: PieChartCard(),
                  ),
                  const SizedBox(height: 24),
                ],

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
