import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/client_bloc.dart';
import '../bloc/client_event.dart';
import '../bloc/client_state.dart';

class ClientAddDialog extends StatefulWidget {
  const ClientAddDialog({Key? key}) : super(key: key);

  @override
  State<ClientAddDialog> createState() => _ClientAddDialogState();
}

class _ClientAddDialogState extends State<ClientAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtr = TextEditingController();
  final _emailCtr = TextEditingController();
  final _cinCtr = TextEditingController();
  final _phoneCtr = TextEditingController();
  final _passwordCtr = TextEditingController();
  final _confirmPasswordCtr = TextEditingController();
  final String _role = 'CLIENT';
  bool _submitted = false;

  @override
  void dispose() {
    _usernameCtr.dispose();
    _emailCtr.dispose();
    _cinCtr.dispose();
    _phoneCtr.dispose();
    _passwordCtr.dispose();
    _confirmPasswordCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth =
        screenSize.width < 600
            ? screenSize.width * 0.9
            : screenSize.width * 0.8;
    final isMobile = screenSize.width < 600;

    return BlocListener<ClientBloc, ClientState>(
      listener: (ctx, state) {
        if (state is ClientAddSuccess && mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Client ajouté avec succès')),
          );
        }

        if (state is ClientOperationFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erreur: ${state.message}')));
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: dialogWidth,
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: screenSize.height * 0.8,
          ),
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Ajouter un client',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 600;
                        return isWide
                            ? IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildColumn1()),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildColumn2()),
                                ],
                              ),
                            )
                            : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildColumn1(),
                                const SizedBox(height: 12),
                                _buildColumn2(),
                              ],
                            );
                      },
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _submitted ? null : () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.accentGreen,
                    ),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 8),
                  BlocBuilder<ClientBloc, ClientState>(
                    builder: (ctx, state) {
                      final loading = state is ClientLoading;
                      return ElevatedButton(
                        onPressed:
                            loading
                                ? null
                                : () {
                                  if (!_formKey.currentState!.validate())
                                    return;
                                  setState(() => _submitted = true);
                                  ctx.read<ClientBloc>().add(
                                    AddClient(
                                      username: _usernameCtr.text.trim(),
                                      email: _emailCtr.text.trim(),
                                      password: _passwordCtr.text,
                                      cin: _cinCtr.text.trim(),
                                      tel: _phoneCtr.text.trim(),
                                      role: _role,
                                    ),
                                  );
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGreen,
                        ),
                        child:
                            loading
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  'Enregistrer',
                                  style: TextStyle(color: Colors.white),
                                ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColumn1() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      TextFormField(
        controller: _usernameCtr,
        decoration: const InputDecoration(labelText: 'Nom d\'utilisateur'),
        validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _cinCtr,
        decoration: const InputDecoration(labelText: 'CIN'),
        keyboardType: TextInputType.number,
        maxLength: 8,
        validator:
            (v) => v == null || v.length != 8 ? '8 chiffres requis' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _passwordCtr,
        decoration: const InputDecoration(labelText: 'Mot de passe'),
        obscureText: true,
        validator:
            (v) => v == null || v.length < 6 ? 'Au moins 6 caractères' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _confirmPasswordCtr,
        decoration: const InputDecoration(
          labelText: 'Confirmer le mot de passe',
        ),
        obscureText: true,
        validator: (v) {
          if (v == null || v.isEmpty) return 'Requis';
          if (v != _passwordCtr.text)
            return 'Les mots de passe ne correspondent pas';
          return null;
        },
      ),
    ],
  );

  Widget _buildColumn2() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      TextFormField(
        controller: _emailCtr,
        decoration: const InputDecoration(labelText: 'Email'),
        keyboardType: TextInputType.emailAddress,
        validator:
            (v) => v == null || !v.contains('@') ? 'Email invalide' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _phoneCtr,
        decoration: const InputDecoration(labelText: 'Téléphone'),
        keyboardType: TextInputType.phone,
        validator:
            (v) => v == null || v.length != 8 ? '8 chiffres requis' : null,
      ),
      const SizedBox(height: 12),
    ],
  );
}
