import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/revenuBloc.dart';
import '../bloc/revenuEvent.dart';
import '../bloc/revenuState.dart';

class RevenueSummaryCard extends StatelessWidget {
  final double width;
  final int? clientId;
  final String? dateFrom;
  final String? dateTo;

  const RevenueSummaryCard({
    Key? key,
    required this.width,
    this.clientId,
    this.dateFrom,
    this.dateTo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RevenueBloc, RevenueState>(
      builder: (context, state) {
        if (state is RevenueLoading) {
          return _buildLoadingCard();
        } else if (state is RevenueError) {
          return _buildErrorCard(context, state.message);
        } else if (state is RevenueLoaded) {
          return _buildRevenueCard(
            state.totalRevenue,
            state.totalAmountBeforeTax,
          );
        }

        // initial or other states
        return _buildDefaultCard(context);
      },
    );
  }

  Widget _buildRevenueCard(double totalRevenue, double totalHT) {
    final change = _calculatePercentageChange(totalRevenue);
    final arrowUp = change.startsWith('+');

    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.yellowLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.yellowLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Revenu Total',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              Icon(Icons.trending_up, color: AppColors.yellowLight, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${totalRevenue.toStringAsFixed(2)} DT',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                arrowUp ? Icons.arrow_upward : Icons.arrow_downward,
                color: arrowUp ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: arrowUp ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Text(
            'HT: ${totalHT.toStringAsFixed(2)} DT',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() => Container(
    width: width,
    height: 120,
    decoration: BoxDecoration(
      color: AppColors.yellowLight.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.yellowLight),
    ),
    child: const Center(child: CircularProgressIndicator()),
  );

  Widget _buildErrorCard(BuildContext ctx, String msg) => Container(
    width: width,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.red.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.red),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Erreur: ${msg.split(':').last}',
          style: const TextStyle(color: Colors.red),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed:
              () => ctx.read<RevenueBloc>().add(
                LoadRevenue(
                  // CHANGED: Use LoadRevenue instead of LoadTotalRevenue
                  clientId: clientId,
                  dateFrom: dateFrom,
                  dateTo: dateTo,
                ),
              ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
          ),
          child: const Text('Réessayer'),
        ),
      ],
    ),
  );

  Widget _buildDefaultCard(BuildContext context) => Container(
    width: width,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.yellowLight.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.yellowLight),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Revenu Total',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '0.00 DT',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),
        const SizedBox(height: 8),
        Text(
          'HT: 0.00 DT',
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        // ADD A LOAD BUTTON FOR MANUAL TRIGGER
        Center(
          child: ElevatedButton(
            onPressed: () {
              print('📱 Manual load button pressed in RevenueSummaryCard');
              context.read<RevenueBloc>().add(
                LoadRevenue(
                  // CHANGED: Use LoadRevenue
                  clientId: clientId,
                  dateFrom: dateFrom,
                  dateTo: dateTo,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.yellowLight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Charger', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    ),
  );

  String _calculatePercentageChange(double current) {
    if (current > 1000) return '+15.3%';
    if (current > 500) return '+8.7%';
    if (current > 0) return '+2.1%';
    return '0.0%';
  }
}
