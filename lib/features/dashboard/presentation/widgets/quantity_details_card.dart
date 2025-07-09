import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/features/produits/presentation/bloc/product_bloc.dart';
import 'package:oilab_frontend/features/produits/presentation/bloc/product_event.dart';
import 'package:oilab_frontend/features/produits/presentation/bloc/product_state.dart';
import '../../../../core/constants/app_colors.dart';
import 'detail_row.dart';

class QuantityDetailsCard extends StatefulWidget {
  final double width;

  const QuantityDetailsCard({required this.width, Key? key}) : super(key: key);

  @override
  State<QuantityDetailsCard> createState() => _QuantityDetailsCardState();
}

class _QuantityDetailsCardState extends State<QuantityDetailsCard> {
  @override
  void initState() {
    super.initState();
    // Load total quantity data when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductBloc>().add(LoadTotalQuantity());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.accentGreen),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with refresh button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Détails des quantités',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                onPressed: () {
                  context.read<ProductBloc>().add(LoadTotalQuantity());
                },
                icon: const Icon(Icons.refresh),
                iconSize: 20,
                color: AppColors.accentGreen,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Dynamic content based on state
          BlocBuilder<ProductBloc, ProductState>(
            buildWhen: (previous, current) {
              // Only rebuild for relevant states
              return current is TotalQuantityLoaded ||
                  current is ProductLoading ||
                  current is ProductOperationFailure;
            },
            builder: (context, state) {
              if (state is ProductLoading) {
                return _buildLoadingContent();
              } else if (state is TotalQuantityLoaded) {
                return _buildLoadedContent(state.data);
              } else if (state is ProductOperationFailure) {
                return _buildErrorContent(state.message);
              } else {
                return _buildInitialContent();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Column(
      children: [
        Container(
          height: 60,
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text(
                  'Loading quantity data...',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const DetailRow(label: 'Huile produite', value: '... L'),
        const DetailRow(label: 'Déchets vendus', value: '... Kg'),
        const DetailRow(label: 'Déchets finaux', value: '... Kg'),
      ],
    );
  }

  Widget _buildLoadedContent(data) {
    return Column(
      children: [
        DetailRow(
          label: "Quantité d'olives",
          value: '${data.totalQuantity.toStringAsFixed(0)} Kg',
        ),
        DetailRow(
          label: 'Huile produite',
          value: '${data.totalOilVolume.toStringAsFixed(1)} L',
        ),
        const DetailRow(label: 'Déchets vendus', value: '25 Kg'),
        const DetailRow(label: 'Déchets finaux', value: '61 Kg'),
      ],
    );
  }

  Widget _buildErrorContent(String message) {
    return Column(
      children: [
        Container(
          height: 80,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red.withOpacity(0.7),
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  'Error loading data',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                ElevatedButton(
                  onPressed: () {
                    context.read<ProductBloc>().add(LoadTotalQuantity());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                  ),
                  child: const Text('Retry', style: TextStyle(fontSize: 10)),
                ),
              ],
            ),
          ),
        ),
        const DetailRow(label: 'Huile produite', value: '-- L'),
        const DetailRow(label: 'Déchets vendus', value: '-- Kg'),
        const DetailRow(label: 'Déchets finaux', value: '-- Kg'),
      ],
    );
  }

  Widget _buildInitialContent() {
    return Column(
      children: [
        Container(
          height: 60,
          child: Center(
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<ProductBloc>().add(LoadTotalQuantity());
              },
              icon: const Icon(Icons.play_arrow, size: 16),
              label: const Text('Load Data', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ),
        const DetailRow(label: 'Huile produite', value: '-- L'),
        const DetailRow(label: 'Déchets vendus', value: '-- Kg'),
        const DetailRow(label: 'Déchets finaux', value: '-- Kg'),
      ],
    );
  }
}
