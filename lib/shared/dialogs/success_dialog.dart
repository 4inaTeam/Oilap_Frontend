import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SuccessDialog extends StatelessWidget {
  final String? title;
  final String message;
  final VoidCallback? onContinue;

  const SuccessDialog({
    Key? key,
    this.title,
    required this.message,
    this.onContinue,
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
            // Success Title
            Text(
              title ?? 'Succès',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 20),

            // Success Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  if (onContinue != null) {
                    onContinue!();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
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

// Helper function to show success dialog
Future<void> showSuccessDialog(
  BuildContext context, {
  String? title,
  required String message,
  VoidCallback? onContinue,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return SuccessDialog(
        title: title,
        message: message,
        onContinue: onContinue,
      );
    },
  );
}

Future<void> showProductAddedSuccess(BuildContext context) {
  return showSuccessDialog(
    context,
    title: 'Succès',
    message: 'Foulen a été ajouté au système',
  );
}

Future<void> showDataSavedSuccess(BuildContext context) {
  return showSuccessDialog(
    context,
    title: 'Succès',
    message: 'Les données ont été sauvegardées avec succès',
  );
}

Future<void> showOperationSuccess(BuildContext context, String operation) {
  return showSuccessDialog(
    context,
    title: 'Succès',
    message: '$operation a été effectué avec succès',
  );
}

Future<void> showGenericSuccess(BuildContext context, String message) {
  return showSuccessDialog(context, title: 'Succès', message: message);
}

Future<void> showProductCreatedSuccess(BuildContext context) {
  return showSuccessDialog(
    context,
    title: 'Succès',
    message: 'Le produit a été ajouté avec succès',
  );
}

Future<void> showProductUpdatedSuccess(BuildContext context) {
  return showSuccessDialog(
    context,
    title: 'Succès',
    message: 'Le produit a été mis à jour avec succès',
  );
}

Future<void> showProductDeletedSuccess(BuildContext context) {
  return showSuccessDialog(
    context,
    title: 'Succès',
    message: 'Le produit a été supprimé avec succès',
  );
}
