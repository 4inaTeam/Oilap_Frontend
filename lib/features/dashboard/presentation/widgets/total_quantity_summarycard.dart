import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/core/constants/app_colors.dart';
import 'package:oilab_frontend/features/produits/presentation/bloc/product_bloc.dart';
import 'package:oilab_frontend/features/produits/presentation/bloc/product_event.dart';
import 'package:oilab_frontend/features/produits/presentation/bloc/product_state.dart';
import 'summary_card.dart';

class TotalQuantitySummaryCard extends StatefulWidget {
  final double? width;

  const TotalQuantitySummaryCard({Key? key, this.width}) : super(key: key);

  @override
  State<TotalQuantitySummaryCard> createState() =>
      _TotalQuantitySummaryCardState();
}

class _TotalQuantitySummaryCardState extends State<TotalQuantitySummaryCard> {
  @override
  void initState() {
    super.initState();
    // Trigger loading when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductBloc>().add(LoadTotalQuantity());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      buildWhen: (previous, current) {
        // Only rebuild for relevant states
        return current is TotalQuantityLoaded ||
            current is ProductLoading ||
            current is ProductOperationFailure;
      },
      builder: (context, state) {
        if (state is TotalQuantityLoaded) {
          // Successfully loaded data
          final totalQuantity = state.data.totalQuantityInt;
          const changePercentage =
              '+8.2%'; // You can calculate this dynamically

          return SummaryCard(
            title: 'Quantité',
            value: '$totalQuantity Kg',
            change: changePercentage,
            color: AppColors.accentYellow,
            width: widget.width ?? 200,
          );
        } else if (state is ProductLoading) {
          // Loading state - show loading indicator
          return Container(
            width: widget.width,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.accentYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.accentYellow),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.accentYellow,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Loading quantity...',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        } else if (state is ProductOperationFailure) {
          // Error state - show error with retry button
          return Container(
            width: widget.width,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProductBloc>().add(LoadTotalQuantity());
                    },
                    child: const Text('Retry', style: TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            ),
          );
        } else {
          // Initial state - show tap to load
          return Container(
            width: widget.width,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.accentYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.accentYellow),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Quantité',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap to load',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProductBloc>().add(LoadTotalQuantity());
                    },
                    child: const Text('Load', style: TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
