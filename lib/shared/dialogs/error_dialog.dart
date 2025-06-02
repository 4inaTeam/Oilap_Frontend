import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool showRetry;

  const CustomErrorWidget({
    Key? key,
    required this.message,
    this.onRetry,
    this.showRetry = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ERREUR',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (onRetry != null) {
                    onRetry!();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showCustomErrorDialog(
  BuildContext context, {
  required String message,
  VoidCallback? onRetry,
  bool showRetry = true,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return CustomErrorWidget(
        message: message,
        onRetry: onRetry,
        showRetry: showRetry,
      );
    },
  );
}

Future<void> showNetworkError(BuildContext context, {VoidCallback? onRetry}) {
  return showCustomErrorDialog(
    context,
    message:
        'Problème de connexion réseau. Veuillez vérifier votre connexion internet.',
    onRetry: onRetry,
  );
}

Future<void> showValidationError(BuildContext context, String message) {
  return showCustomErrorDialog(context, message: message, showRetry: false);
}

Future<void> showServerError(BuildContext context, {VoidCallback? onRetry}) {
  return showCustomErrorDialog(
    context,
    message:
        'Une erreur s\'est produite sur le serveur. Veuillez réessayer plus tard.',
    onRetry: onRetry,
  );
}

Future<void> showGenericError(BuildContext context, [String? customMessage]) {
  return showCustomErrorDialog(
    context,
    message: customMessage ?? 'Une erreur inattendue s\'est produite.',
    showRetry: false,
  );
}
