import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/features/produits/presentation/bloc/product_bloc.dart';
import 'package:oilab_frontend/features/produits/presentation/bloc/product_state.dart';
import '../../../../core/constants/app_colors.dart';
import 'detail_row.dart';

class QuantityDetailsCard extends StatelessWidget {
  final double width;
  const QuantityDetailsCard({required this.width, Key? key}) : super(key: key);

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
        children: [
          const Text(
            'Détails des quantités',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              String quantityValue = '3630 Kg';

              if (state is TotalQuantityLoaded) {
                quantityValue =
                    '${state.data.totalQuantity.toStringAsFixed(0)} Kg';
              } else if (state is ProductLoading) {
                quantityValue = '... Kg';
              } else if (state is ProductOperationFailure) {
                quantityValue = 'Error';
              }

              return DetailRow(
                label: "Quantité d'olives",
                value: quantityValue,
                child: null,
              );
            },
          ),
          // Static rows remain unchanged
          const DetailRow(label: 'Huile produite', value: '39 L', child: null),
          const DetailRow(label: 'Déchets vendus', value: '25 Kg', child: null),
          const DetailRow(label: 'Déchets finaux', value: '61 Kg', child: null),
        ],
      ),
    );
  }
}
