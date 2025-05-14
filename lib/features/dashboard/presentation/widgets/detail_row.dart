import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DetailRow extends StatelessWidget {
  final String label, value;
  const DetailRow({required this.label, required this.value, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Container(
          height: 2,
          color: AppColors.accentGreen.withOpacity(0.3),
          width: double.infinity,
        ),
      ],
    );
  }
}
