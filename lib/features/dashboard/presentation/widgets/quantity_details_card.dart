import 'package:flutter/material.dart';
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
        children: const [
          Text(
            'Détails des quantités',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          DetailRow(label: "Quantité d'olives", value: '72 Kg'),
          DetailRow(label: 'Huile produite', value: '39 L'),
          DetailRow(label: 'Déchets vendus', value: '25 Kg'),
          DetailRow(label: 'Déchets finaux', value: '61 Kg'),
        ],
      ),
    );
  }
}
