import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/screens/signin_screen.dart';

Future<void> showResetSuccessDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _ResetSuccessDialog(),
  );
}

class _ResetSuccessDialog extends StatefulWidget {
  const _ResetSuccessDialog({Key? key}) : super(key: key);
  @override
  __ResetSuccessDialogState createState() => __ResetSuccessDialogState();
}

class __ResetSuccessDialogState extends State<_ResetSuccessDialog> {
  @override
  void initState() {
    super.initState();
    // After 2 seconds, close this dialog and go back to sign-in
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // close dialog
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 500 ? 350.0 : screenWidth * 0.85;
    final iconSize = screenWidth > 500 ? 56.0 : 40.0;
    final paddingV = screenWidth > 500 ? 40.0 : 24.0;
    final paddingH = screenWidth > 500 ? 32.0 : 16.0;
    final titleFont = screenWidth > 500 ? 24.0 : 20.0;
    final textFont = screenWidth > 500 ? 16.0 : 14.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          width: dialogWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(
            vertical: paddingV,
            horizontal: paddingH,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The green circle + shield icon
              Container(
                decoration: BoxDecoration(
                  color: AppColors.accentGreen,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(iconSize / 2.5),
                child: Image.asset(
                  'assets/images/Verified.png',
                  width: iconSize,
                  height: iconSize,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Félicitations !',
                style: TextStyle(
                  fontSize: titleFont,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Réinitialisation du mot de passe réussie\n'
                'Vous serez redirigé vers l’écran de connexion',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: textFont),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
