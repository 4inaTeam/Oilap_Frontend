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
                      // Mobile layout - Summary cards and quantity details in same row
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Main row with summary cards and quantity details
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 2x2 Grid for Summary Cards (left side)
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: Column(
                                    children: [
                                      // First row
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
                                          const SizedBox(width: 6),
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
                                      const SizedBox(height: 6),
                                      // Second row
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
                                          const SizedBox(width: 6),
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
                              ),
                              const SizedBox(width: 8),

                              // Quantity Details Card (right side)
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height:
                                      150, // Match approximately the height of 2x2 grid
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.accentGreen,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'Détails des quantités',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              12, // Smaller font for mobile
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _buildCompactDetailRow(
                                              context,
                                              "Quantité d'olives",
                                              '72 Kg',
                                            ),
                                            _buildCompactDetailRow(
                                              context,
                                              'Huile produite',
                                              '39 L',
                                            ),
                                            _buildCompactDetailRow(
                                              context,
                                              'Déchets vendus',
                                              '25 Kg',
                                            ),
                                            _buildCompactDetailRow(
                                              context,
                                              'Déchets finaux',
                                              '61 Kg',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Pie Chart Card
                          SizedBox(height: 350, child: PieChartCard()),
                          const SizedBox(height: 12),

                          // Line Chart Card
                          SizedBox(height: 250, child: LineChartCard()),
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

  // Helper method for compact detail rows
  Widget _buildCompactDetailRow(
    BuildContext context,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
