import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/password_reset_bloc.dart';
import 'passwordReset.dart';

Future<void> showPasswordVerifyDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder:
        (_) => BlocListener<PasswordResetBloc, PasswordResetState>(
          listener: (ctx, state) {
            if (state is ResetFailure) {
              ScaffoldMessenger.of(
                ctx,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: const PasswordVerifyDialog(),
        ),
  );
}

class PasswordVerifyDialog extends StatefulWidget {
  const PasswordVerifyDialog({Key? key}) : super(key: key);

  @override
  _PasswordVerifyDialogState createState() => _PasswordVerifyDialogState();
}

class _PasswordVerifyDialogState extends State<PasswordVerifyDialog> {
  final _codeController = TextEditingController();
  bool _verifying = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onVerify() {
    setState(() => _verifying = true);
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final cardW = (screenW * .9).clamp(0.0, 600.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          width: cardW,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.accentYellow, width: 2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accentGreen, width: 2),
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Expanded(
                            child: Text(
                              'Mot de passe oublié',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Vérifier',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Veuillez saisir le code que nous vous avons envoyé",
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Code de vérification',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Vous n'avez pas reçu le code ?",
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () {
                          // you could re-dispatch ResetEmailRequested here
                        },
                        child: const Text(
                          'Renvoyer le code',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentGreen,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed:
                              _verifying
                                  ? null
                                  : () {
                                    _onVerify(); // sets _verifying = true
                                    Navigator.of(context).pop();
                                    // pass the code along to the next dialog
                                    showPasswordResetDialog(
                                      context,
                                      token: _codeController.text.trim(),
                                    );
                                  },
                          child:
                              _verifying
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text(
                                    'Vérifier',
                                    style: TextStyle(color: Colors.white),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
