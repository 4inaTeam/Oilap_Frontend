import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        '© 4InA Technologies',
        style: TextStyle(color: AppColors.backgroundLight),
        textAlign: TextAlign.right,
      ),
    );
  }
}
