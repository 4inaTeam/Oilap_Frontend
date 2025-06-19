import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SummaryCard extends StatelessWidget {
  final String title, value, change;
  final Color color;
  final double width;

  const SummaryCard({
    required this.title,
    required this.value,
    required this.change,
    required this.color,
    required this.width,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen width to determine if it's mobile
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Force smaller square dimensions
    final cardSize = isMobile ? 70.0 : 120.0; // Much smaller on mobile
    final cardPadding = isMobile ? 6.0 : 12.0;
    final titleFontSize = isMobile ? 8.0 : 12.0;
    final valueFontSize = isMobile ? 12.0 : 16.0;
    final changeFontSize = isMobile ? 7.0 : 10.0;
    final spacing = isMobile ? 2.0 : 4.0;
    final borderRadius = isMobile ? 4.0 : 6.0;

    return Container(
      width: cardSize, // Fixed small size
      height: cardSize, // Square shape
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: titleFontSize,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing),
          Text(
            value,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing),
          Text(
            change,
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: changeFontSize,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
