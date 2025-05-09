import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/password_reset_bloc.dart';
import '../screens/passwordResetSuccess.dart';

Future<void> showPasswordResetDialog(
  BuildContext context, {
  required String token,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (_) => BlocProvider.value(
          value: context.read<PasswordResetBloc>(),
          child: PasswordResetDialog(token: token),
        ),
  );
}

class PasswordResetDialog extends StatefulWidget {
  final String token;
  const PasswordResetDialog({Key? key, required this.token}) : super(key: key);

  @override
  _PasswordResetDialogState createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends State<PasswordResetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _pass1 = TextEditingController();
  final _pass2 = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _pass1.dispose();
    _pass2.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    context.read<PasswordResetBloc>().add(
      ResetConfirmRequested(widget.token, _pass1.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PasswordResetBloc, PasswordResetState>(
      listener: (ctx, state) {
        if (state is ResetSuccess) {
          Navigator.of(ctx).pop(); // close reset dialog
          showResetSuccessDialog(ctx); // show success popup
        } else if (state is ResetFailure) {
          setState(() => _submitting = false);
          ScaffoldMessenger.of(
            ctx,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 600),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.accentYellow,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.accentGreen,
                        width: 2,
                      ),
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
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Créer un nouveau mot de passe',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _pass1,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Nouveau mot de passe',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                validator:
                                    (v) =>
                                        (v == null || v.length < 6)
                                            ? '6 caractères min.'
                                            : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _pass2,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Répéter mot de passe',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                validator:
                                    (v) =>
                                        (v != _pass1.text)
                                            ? 'Les mots de passe ne correspondent pas'
                                            : null,
                              ),
                            ],
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
                            onPressed: _submitting ? null : _onSubmit,
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
      ),
    );
  }
}
