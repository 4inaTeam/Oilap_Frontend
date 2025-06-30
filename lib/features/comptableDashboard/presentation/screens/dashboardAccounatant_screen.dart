import 'package:flutter/material.dart';
import 'package:oilab_frontend/shared/widgets/app_layout.dart';

class AccountantScreen extends StatelessWidget {
  const AccountantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: "/comptableDashboard",
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 768;

          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
            child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Revenue Section
        const RevenueCard(),
        const SizedBox(height: 16),
        const RevenueTable(),
        const SizedBox(height: 24),

        // Expenses Section
        const ExpensesCard(),
        const SizedBox(height: 16),
        const ExpensesTable(),
        const SizedBox(height: 24),

        // Charts - Stacked Vertically for Mobile
        const ExpenseDistributionChart(),
        const SizedBox(height: 16),
        const FinancialAnalysisChart(),
        const SizedBox(height: 16),
        const PaymentStatusChart(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Row - Revenue, Credit Card, Expenses
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue Section
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  const RevenueCard(),
                  const SizedBox(height: 16),
                  const RevenueTable(),
                ],
              ),
            ),
            const SizedBox(width: 24),

            // Credit Card
            const Expanded(flex: 1, child: CreditCardWidget()),
            const SizedBox(width: 24),

            // Expenses Section
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  const ExpensesCard(),
                  const SizedBox(height: 16),
                  const ExpensesTable(),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Bottom Row - Charts
        const Row(
          children: [
            Expanded(child: ExpenseDistributionChart()),
            SizedBox(width: 24),
            Expanded(child: PaymentStatusChart()),
            SizedBox(width: 24),
            Expanded(child: FinancialAnalysisChart()),
          ],
        ),
      ],
    );
  }
}

class RevenueCard extends StatelessWidget {
  const RevenueCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenu',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                '695 DT',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_upward, color: Colors.green, size: 14),
                    Text(
                      '+5.03%',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ExpensesCard extends StatelessWidget {
  const ExpensesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dépenses',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                '305 DT',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_downward, color: Colors.red, size: 14),
                    Text(
                      '+1.08%',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CreditCardWidget extends StatelessWidget {
  const CreditCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset('assets/images/Card.png', fit: BoxFit.cover),
      ),
    );
  }
}

class RevenueTable extends StatelessWidget {
  const RevenueTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Référence',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Montant',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Date',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'Propriétaire',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...List.generate(3, (index) => const RevenueTableRow()),
        ],
      ),
    );
  }
}

class RevenueTableRow extends StatelessWidget {
  const RevenueTableRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '2395478',
              style: TextStyle(fontSize: 14, color: Color(0xFF2D3436)),
            ),
          ),
          const Expanded(
            child: Text(
              '800 DT',
              style: TextStyle(fontSize: 14, color: Color(0xFF2D3436)),
            ),
          ),
          const Expanded(
            child: Text(
              '12/02/2024',
              style: TextStyle(fontSize: 14, color: Color(0xFF2D3436)),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Moez',
              style: TextStyle(fontSize: 12, color: Color(0xFF2D3436)),
            ),
          ),
        ],
      ),
    );
  }
}

class ExpensesTable extends StatelessWidget {
  const ExpensesTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Référence',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Montant',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Date',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'Propriétaire',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...List.generate(3, (index) => const ExpensesTableRow()),
        ],
      ),
    );
  }
}

class ExpensesTableRow extends StatelessWidget {
  const ExpensesTableRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '2395478',
              style: TextStyle(fontSize: 14, color: Color(0xFF2D3436)),
            ),
          ),
          const Expanded(
            child: Text(
              '800 DT',
              style: TextStyle(fontSize: 14, color: Color(0xFF2D3436)),
            ),
          ),
          const Expanded(
            child: Text(
              '12/02/2024',
              style: TextStyle(fontSize: 14, color: Color(0xFF2D3436)),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Moez',
              style: TextStyle(fontSize: 12, color: Color(0xFF2D3436)),
            ),
          ),
        ],
      ),
    );
  }
}

class ExpenseDistributionChart extends StatelessWidget {
  const ExpenseDistributionChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 300;
        double chartSize = isMobile ? 100 : 120;
        double borderWidth = isMobile ? 6 : 8;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Répartition des dépenses',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: chartSize,
                  height: chartSize,
                  child: Stack(
                    children: [
                      Container(
                        width: chartSize,
                        height: chartSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.green,
                            width: borderWidth,
                          ),
                        ),
                      ),
                      Container(
                        width: chartSize,
                        height: chartSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: borderWidth,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const ChartLegendItem(
                color: Colors.green,
                label: 'Achats',
                percentage: '46%',
              ),
              const ChartLegendItem(
                color: Colors.blue,
                label: 'Clientèle',
                percentage: '24%',
              ),
              const ChartLegendItem(
                color: Colors.grey,
                label: 'Électricité, eau',
                percentage: '15%',
              ),
            ],
          ),
        );
      },
    );
  }
}

class PaymentStatusChart extends StatelessWidget {
  const PaymentStatusChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 300;
        double chartSize = isMobile ? 100 : 120;
        double borderWidth = isMobile ? 6 : 8;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Statut des paiements',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: chartSize,
                  height: chartSize,
                  child: Stack(
                    children: [
                      Container(
                        width: chartSize,
                        height: chartSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.green,
                            width: borderWidth,
                          ),
                        ),
                      ),
                      Container(
                        width: chartSize,
                        height: chartSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: borderWidth,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const ChartLegendItem(
                color: Colors.green,
                label: 'Payé',
                percentage: '68%',
              ),
              const ChartLegendItem(
                color: Colors.grey,
                label: 'Non payé',
                percentage: '24%',
              ),
            ],
          ),
        );
      },
    );
  }
}

class FinancialAnalysisChart extends StatelessWidget {
  const FinancialAnalysisChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analyse financière',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green, width: 8),
                    ),
                  ),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!, width: 8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const ChartLegendItem(
            color: Colors.green,
            label: 'Revenu',
            percentage: '45%',
          ),
          const ChartLegendItem(
            color: Colors.grey,
            label: 'Dépenses',
            percentage: '24%',
          ),
        ],
      ),
    );
  }
}

class ChartLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String percentage;

  const ChartLegendItem({
    super.key,
    required this.color,
    required this.label,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          Text(
            percentage,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3436),
            ),
          ),
        ],
      ),
    );
  }
}
