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
    final width = MediaQuery.of(context).size.width * 0.8;
    final dialogWidth = width > 300 ? 300.0 : width;

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
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The green circle + shield icon
              Container(
                decoration: BoxDecoration(
                  color: AppColors.accentGreen,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  'assets/images/Verified.png',
                  width: 40,
                  height: 40,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Félicitations !',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              const Text(
                'Réinitialisation du mot de passe réussie\n'
                'Vous serez redirigé vers l’écran de connexion',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
