import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onConfirm;
  final String? confirmText;
  final String? cancelText;

  const ErrorDialog({
    Key? key,
    required this.title,
    required this.message,
    this.onConfirm,
    this.confirmText,
    this.cancelText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 400.0,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(cancelText ?? 'Annuler'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onConfirm?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: Text(confirmText ?? 'Confirmer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 400.0,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'ERREUR',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      onRetry != null ? 'Réessayer' : 'Fermer',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
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
