import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/shared/widgets/app_layout.dart';
import 'package:oilab_frontend/features/factures/presentation/bloc/facture_bloc.dart';
import 'package:oilab_frontend/features/factures/presentation/bloc/facture_event.dart';
import 'package:oilab_frontend/features/factures/presentation/bloc/facture_state.dart';
import 'package:oilab_frontend/features/bills/presentation/bloc/bill_statistics_bloc.dart';
import 'package:oilab_frontend/features/bills/presentation/bloc/bill_statistics_event.dart';
import 'package:oilab_frontend/features/bills/presentation/bloc/bill_statistics_state.dart';
import 'package:oilab_frontend/features/bills/presentation/bloc/bill_bloc.dart';
import 'package:oilab_frontend/features/bills/presentation/bloc/bill_event.dart';
import 'package:oilab_frontend/features/bills/presentation/bloc/bill_state.dart';
import 'package:oilab_frontend/core/models/facture_model.dart';
import 'package:oilab_frontend/core/models/bill_model.dart';

class AccountantScreen extends StatefulWidget {
  const AccountantScreen({super.key});

  @override
  State<AccountantScreen> createState() => _AccountantScreenState();
}

class _AccountantScreenState extends State<AccountantScreen> {
  @override
  void initState() {
    super.initState();
    // Load all dashboard data when the screen initializes
    context.read<FactureBloc>().add(LoadDashboardData());
    context.read<BillStatisticsBloc>().add(LoadBillStatistics());
    context.read<BillBloc>().add(
      LoadDashboardBills(limit: 3),
    ); // Already set to 3
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: "/comptableDashboard",
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 768;

          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
            child: BlocBuilder<FactureBloc, FactureState>(
              builder: (context, factureState) {
                return BlocBuilder<BillStatisticsBloc, BillStatisticsState>(
                  builder: (context, statisticsState) {
                    return BlocBuilder<BillBloc, BillState>(
                      builder: (context, billState) {
                        return isMobile
                            ? _buildMobileLayout(
                              factureState,
                              statisticsState,
                              billState,
                            )
                            : _buildDesktopLayout(
                              factureState,
                              statisticsState,
                              billState,
                            );
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(
    FactureState factureState,
    BillStatisticsState statisticsState,
    BillState billState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Revenue Section
        _buildRevenueCard(factureState),
        const SizedBox(height: 16),
        _buildRevenueTable(factureState),
        const SizedBox(height: 24),

        // Expenses Section
        _buildExpensesCard(statisticsState),
        const SizedBox(height: 16),
        _buildExpensesTable(billState),
        const SizedBox(height: 24),

        // Charts - Stacked Vertically for Mobile
        _buildExpenseDistributionChart(statisticsState),
        const SizedBox(height: 16),
        _buildFinancialAnalysisChart(statisticsState),
        const SizedBox(height: 16),
        _buildPaymentStatusChart(statisticsState),
      ],
    );
  }

  Widget _buildDesktopLayout(
    FactureState factureState,
    BillStatisticsState statisticsState,
    BillState billState,
  ) {
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
                  _buildRevenueCard(factureState),
                  const SizedBox(height: 16),
                  _buildRevenueTable(factureState),
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
                  _buildExpensesCard(statisticsState),
                  const SizedBox(height: 16),
                  _buildExpensesTable(billState),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Bottom Row - Charts
        Row(
          children: [
            Expanded(child: _buildExpenseDistributionChart(statisticsState)),
            const SizedBox(width: 24),
            Expanded(child: _buildPaymentStatusChart(statisticsState)),
            const SizedBox(width: 24),
            Expanded(child: _buildFinancialAnalysisChart(statisticsState)),
          ],
        ),
      ],
    );
  }

  Widget _buildRevenueCard(FactureState state) {
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
              if (state is TotalRevenueLoaded)
                Text(
                  '${state.totalRevenue.toStringAsFixed(2)} DT',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                )
              else if (state is DashboardDataLoaded)
                Text(
                  '${state.totalRevenue.toStringAsFixed(2)} DT',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                )
              else if (state is FactureLoading)
                const SizedBox(
                  width: 100,
                  height: 32,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                const Text(
                  '--- DT',
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

  Widget _buildRevenueTable(FactureState state) {
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
                'Client',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          if (state is FactureLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state is FactureLoaded && state.factures.isNotEmpty)
            ...state.factures
                .take(3)
                .map((facture) => RevenueTableRow(facture: facture))
                .toList()
          else if (state is DashboardDataLoaded &&
              state.recentFactures.isNotEmpty)
            ...state.recentFactures
                .map((facture) => RevenueTableRow(facture: facture))
                .toList()
          else if (state is FactureError)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Erreur: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed:
                        () => context.read<FactureBloc>().add(
                          LoadDashboardData(),
                        ),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('Aucune facture trouvée'),
            ),
        ],
      ),
    );
  }

  Widget _buildExpensesCard(BillStatisticsState state) {
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
              if (state is BillStatisticsLoaded)
                Text(
                  '${state.statistics.totalExpenses.toStringAsFixed(2)} DT',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                )
              else if (state is BillStatisticsLoading)
                const SizedBox(
                  width: 100,
                  height: 32,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                const Text(
                  '--- DT',
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
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_downward,
                      color: Colors.red,
                      size: 14,
                    ),
                    Text(
                      state is BillStatisticsLoaded
                          ? '${state.statistics.expensesPercentage.toStringAsFixed(1)}%'
                          : '---%',
                      style: const TextStyle(
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

  Widget _buildExpensesTable(BillState state) {
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
          if (state is BillLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state is BillLoadSuccess && state.bills.isNotEmpty)
            ...state.bills
                .take(3) // Ensure only 3 bills are displayed
                .map((bill) => ExpensesTableRow(bill: bill))
                .toList()
          else if (state is BillOperationFailure)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Erreur: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed:
                        () => context.read<BillBloc>().add(
                          LoadDashboardBills(limit: 3),
                        ),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('Aucune dépense trouvée'),
            ),
        ],
      ),
    );
  }

  Widget _buildExpenseDistributionChart(BillStatisticsState state) {
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
                  child:
                      state is BillStatisticsLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Stack(
                            children: [
                              Container(
                                width: chartSize,
                                height: chartSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        Colors
                                            .lightGreen, // Light green for expenses chart
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
                                    color:
                                        Colors
                                            .green[300]!, // Light green for utilities
                                    width: borderWidth,
                                  ),
                                ),
                              ),
                            ],
                          ),
                ),
              ),
              const SizedBox(height: 20),
              if (state is BillStatisticsLoaded) ...[
                if (state.statistics.summary.purchases.totalAmount > 0)
                  ChartLegendItem(
                    color: Colors.lightGreen, // Light green for purchases
                    label: 'Achats',
                    percentage:
                        '${state.statistics.summary.purchases.percentage.toStringAsFixed(1)}%',
                  ),
                if (state.statistics.summary.utilities.totalAmount > 0)
                  ChartLegendItem(
                    color: Colors.green[300]!, // Light green for utilities
                    label: 'Services publics',
                    percentage:
                        '${state.statistics.summary.utilities.percentage.toStringAsFixed(1)}%',
                  ),
              ] else ...[
                const ChartLegendItem(
                  color: Colors.lightGreen,
                  label: 'Achats',
                  percentage: '---%',
                ),
                ChartLegendItem(
                  color: Colors.green[300]!,
                  label: 'Services publics',
                  percentage: '---%',
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentStatusChart(BillStatisticsState state) {
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
                'Activité financière',
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
                  child:
                      state is BillStatisticsLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Stack(
                            children: [
                              Container(
                                width: chartSize,
                                height: chartSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.green, // Green for revenue
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
                                    color:
                                        Colors
                                            .lightGreen, // Light green for expenses
                                    width: borderWidth,
                                  ),
                                ),
                              ),
                            ],
                          ),
                ),
              ),
              const SizedBox(height: 20),
              if (state is BillStatisticsLoaded) ...[
                ChartLegendItem(
                  color: Colors.green, // Green for revenue
                  label: 'Revenus',
                  percentage:
                      '${state.statistics.revenuePercentage.toStringAsFixed(1)}%',
                ),
                ChartLegendItem(
                  color: Colors.lightGreen, // Light green for expenses
                  label: 'Dépenses',
                  percentage:
                      '${state.statistics.expensesPercentage.toStringAsFixed(1)}%',
                ),
              ] else ...[
                const ChartLegendItem(
                  color: Colors.green,
                  label: 'Revenus',
                  percentage: '---%',
                ),
                const ChartLegendItem(
                  color: Colors.lightGreen,
                  label: 'Dépenses',
                  percentage: '---%',
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFinancialAnalysisChart(BillStatisticsState state) {
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
            'Résultat net',
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
              child:
                  state is BillStatisticsLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    state is BillStatisticsLoaded &&
                                            state.statistics.netResultType ==
                                                'profit'
                                        ? Colors.green
                                        : Colors.red,
                                width: 8,
                              ),
                            ),
                          ),
                          if (state is BillStatisticsLoaded)
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${state.statistics.netResult.toStringAsFixed(0)} DT',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          state.statistics.netResultType ==
                                                  'profit'
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  ),
                                  Text(
                                    state.statistics.netResultType == 'profit'
                                        ? 'Bénéfice'
                                        : 'Perte',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
            ),
          ),
          const SizedBox(height: 20),
          if (state is BillStatisticsLoaded) ...[
            ChartLegendItem(
              color: Colors.green, // Green for total revenue
              label: 'Revenu total',
              percentage:
                  '${state.statistics.totalRevenue.toStringAsFixed(0)} DT',
            ),
            ChartLegendItem(
              color: Colors.lightGreen, // Light green for total expenses
              label: 'Dépenses totales',
              percentage:
                  '${state.statistics.totalExpenses.toStringAsFixed(0)} DT',
            ),
          ] else ...[
            const ChartLegendItem(
              color: Colors.green,
              label: 'Revenu total',
              percentage: '--- DT',
            ),
            const ChartLegendItem(
              color: Colors.lightGreen,
              label: 'Dépenses totales',
              percentage: '--- DT',
            ),
          ],
        ],
      ),
    );
  }
}

class RevenueTableRow extends StatelessWidget {
  final Facture facture;

  const RevenueTableRow({super.key, required this.facture});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              facture.id.toString(),
              style: const TextStyle(fontSize: 14, color: Color(0xFF2D3436)),
            ),
          ),
          Expanded(
            child: Text(
              '${facture.finalTotal} DT',
              style: const TextStyle(fontSize: 14, color: Color(0xFF2D3436)),
            ),
          ),
          Expanded(
            child: Text(
              _formatDate(facture.createdAt),
              style: const TextStyle(fontSize: 14, color: Color(0xFF2D3436)),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              facture.clientName,
              style: const TextStyle(fontSize: 12, color: Color(0xFF2D3436)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class ExpensesTableRow extends StatelessWidget {
  final Bill bill;

  const ExpensesTableRow({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              bill.id?.toString() ?? 'N/A',
              style: const TextStyle(fontSize: 14, color: Color(0xFF2D3436)),
            ),
          ),
          Expanded(
            child: Text(
              '${bill.amount.toStringAsFixed(2)} DT',
              style: const TextStyle(fontSize: 14, color: Color(0xFF2D3436)),
            ),
          ),
          Expanded(
            child: Text(
              bill.paymentDate != null ? _formatDate(bill.paymentDate!) : 'N/A',
              style: const TextStyle(fontSize: 14, color: Color(0xFF2D3436)),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              bill.owner,
              style: const TextStyle(fontSize: 12, color: Color(0xFF2D3436)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
