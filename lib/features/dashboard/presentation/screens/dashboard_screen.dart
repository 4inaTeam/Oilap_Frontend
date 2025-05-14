import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_layout.dart';

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
            _SummaryCard(
              title: 'Clients',
              value: '781',
              change: '+11.01%',
              color: AppColors.backgroundLight,
              width: summaryCardWidth,
            ),
            _SummaryCard(
              title: 'Quantité',
              value: '1219 T',
              change: '-0.03%',
              color: AppColors.accentYellow,
              width: summaryCardWidth,
            ),
            _SummaryCard(
              title: 'Revenu',
              value: '695 DT',
              change: '+15.03%',
              color: AppColors.backgroundLight,
              width: summaryCardWidth,
            ),
            _SummaryCard(
              title: 'Dépenses',
              value: '305 DT',
              change: '+6.08%',
              color: AppColors.accentGreen,
              width: summaryCardWidth,
            ),
            _QuantityDetailsCard(width: summaryCardWidth),
          ];
          final chartCards = [const _LineChartCard(), const _PieChartCard()];
          final tableCards = [
            const _DataTableCard(),
            const _EmployeeTableCard(),
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    const SizedBox(width: 8),
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Recherche',

                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.notifications_none),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Summary grid
                Wrap(spacing: 16, runSpacing: 16, children: summaryCards),
                const SizedBox(height: 24),

                // Charts grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isDesktop ? 2 : 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isDesktop ? 1.5 : 1,
                  children: chartCards,
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

class _SummaryCard extends StatelessWidget {
  final String title, value, change;
  final Color color;
  final double width;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.change,
    required this.color,
    required this.width,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: AppColors.textColor)),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          Text(change, style: TextStyle(color: AppColors.textColor)),
        ],
      ),
    );
  }
}

class _QuantityDetailsCard extends StatelessWidget {
  final double width;
  const _QuantityDetailsCard({required this.width, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.accentGreen),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          Text(
            'Détails des quantités',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          _DetailRow(label: "Quantité d'olives", value: '72 Kg'),
          _DetailRow(label: 'Huile produite', value: '39 L'),
          _DetailRow(label: 'Déchets vendus', value: '25 Kg'),
          _DetailRow(label: 'Déchets finaux', value: '61 Kg'),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow({required this.label, required this.value, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _LineChartCard extends StatelessWidget {
  const _LineChartCard({Key? key}) : super(key: key);

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
                  // TODO: set data
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PieChartCard extends StatelessWidget {
  const _PieChartCard({Key? key}) : super(key: key);

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
              child: PieChart(
                PieChartData(
                  // TODO: set data
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataTableCard extends StatelessWidget {
  const _DataTableCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Clients récents',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 32,
                  headingRowHeight: 40,
                  dataRowHeight: 36,
                  columns: const [
                    DataColumn(label: Text('Nom de client')),
                    DataColumn(label: Text('Quantité')),
                    DataColumn(label: Text('Temps restant')),
                  ],
                  rows: List.generate(
                    5,
                    (_) => const DataRow(
                      cells: [
                        DataCell(Text('Moez')),
                        DataCell(Text('700 Kg')),
                        DataCell(Text('01:30:20')),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeTableCard extends StatelessWidget {
  const _EmployeeTableCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Employés',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  headingRowHeight: 40,
                  dataRowHeight: 36,
                  columns: const [
                    DataColumn(label: Text("Nom de l'employé")),
                    DataColumn(label: Text('Numéro de téléphone')),
                    DataColumn(label: Text('État')),
                  ],
                  rows: List.generate(
                    5,
                    (_) => const DataRow(
                      cells: [
                        DataCell(Text('Moez')),
                        DataCell(Text('23954782')),
                        DataCell(Text('Occupé')),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
