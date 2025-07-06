
import 'package:flutter/material.dart';

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final double? percentage;
  final int? count;

  const LegendItem({
    Key? key,
    required this.color,
    required this.label,
    this.percentage,
    this.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (percentage != null)
          Text(
            '${percentage!.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        if (count != null)
          Text(
            ' (${count})',
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
      ],
    );
  }
}