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
    // Check if mobile
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Responsive sizes
    final containerSize = isMobile ? 12.0 : 16.0;
    final fontSize = isMobile ? 10.0 : 12.0;
    final smallFontSize = isMobile ? 9.0 : 10.0;
    final spacing = isMobile ? 6.0 : 8.0;

    return Row(
      children: [
        Container(
          width: containerSize,
          height: containerSize,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (percentage != null) ...[
          SizedBox(width: spacing),
          Text(
            '${percentage!.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
        if (count != null)
          Text(
            ' (${count})',
            style: TextStyle(fontSize: smallFontSize, color: Colors.grey),
          ),
      ],
    );
  }
}
