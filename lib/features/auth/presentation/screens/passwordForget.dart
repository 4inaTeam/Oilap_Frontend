import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/password_reset_bloc.dart';
import 'passwordVerifyScreen.dart';

Future<void> showPasswordForgetDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder:
        (_) => BlocListener<PasswordResetBloc, PasswordResetState>(
          listener: (ctx, state) {
            if (state is ResetEmailSent) {
              Navigator.of(ctx).pop(); // close this dialog
              showPasswordVerifyDialog(ctx); // proceed to code verification
            } else if (state is ResetFailure) {
              ScaffoldMessenger.of(
                ctx,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: const PasswordForgetDialog(),
        ),
  );
}

class PasswordForgetDialog extends StatefulWidget {
  const PasswordForgetDialog({Key? key}) : super(key: key);
  @override
  _PasswordForgetDialogState createState() => _PasswordForgetDialogState();
}

class _PasswordForgetDialogState extends State<PasswordForgetDialog> {
  final _emailCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _onContinue() {
    setState(() => _submitting = true);
    context.read<PasswordResetBloc>().add(
      ResetEmailRequested(_emailCtrl.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.9;
    final dialogWidth = maxWidth > 600 ? 600.0 : maxWidth;

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
                      Image.asset(
                        'assets/images/Picture.png',
                        width: dialogWidth * 0.4,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Veuillez saisir l'e-mail ou le numéro de portable lié à votre compte.",
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailCtrl,
                        decoration: InputDecoration(
                          hintText: 'Email ou numéro de portable',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
                          onPressed: _submitting ? null : _onContinue,
                          child:
                              _submitting
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
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
