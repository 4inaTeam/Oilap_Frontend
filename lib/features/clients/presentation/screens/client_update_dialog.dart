import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/user_model.dart';
import '../bloc/client_bloc.dart';
import '../bloc/client_event.dart';
import '../bloc/client_state.dart';

class ClientUpdateDialog extends StatefulWidget {
  final int clientId;
  
  const ClientUpdateDialog({
    Key? key,
    required this.clientId,
  }) : super(key: key);

  @override
  State<ClientUpdateDialog> createState() => _ClientUpdateDialogState();
}

class _ClientUpdateDialogState extends State<ClientUpdateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtr = TextEditingController();
  final _emailCtr = TextEditingController();
  final _cinCtr = TextEditingController();
  final _phoneCtr = TextEditingController();
  final _passwordCtr = TextEditingController();
  bool _submitted = false;
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    // Load client details when dialog opens
    context.read<ClientBloc>().add(GetClientForUpdate(widget.clientId));
  }

  @override
  void dispose() {
    _usernameCtr.dispose();
    _emailCtr.dispose();
    _cinCtr.dispose();
    _phoneCtr.dispose();
    _passwordCtr.dispose();
    super.dispose();
  }

  void _populateFields(User client) {
    if (!_dataLoaded) {
      _usernameCtr.text = client.name;
      _emailCtr.text = client.email;
      _cinCtr.text = client.cin;
      _phoneCtr.text = client.tel ?? '';
      _dataLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClientBloc, ClientState>(
      listener: (ctx, state) {
        if (state is ClientUpdateSuccess && mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Client mis à jour avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }

        if (state is ClientOperationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<ClientBloc, ClientState>(
        builder: (context, state) {
          if (state is ClientLoading && !_dataLoaded) {
            return const AlertDialog(
              content: SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }

          if (state is ClientDetailsLoaded) {
            _populateFields(state.client);
          }

          return AlertDialog(
            title: const Text('Mettre à jour un client'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
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
            actions: [
              TextButton(
                onPressed: _submitted ? null : () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
                child: const Text('Annuler'),
              ),
              BlocBuilder<ClientBloc, ClientState>(
                builder: (ctx, state) {
                  final loading = state is ClientLoading && _dataLoaded;
                  return ElevatedButton(
                    onPressed: loading
                        ? null
                        : () {
                      if (!_formKey.currentState!.validate()) return;
                      setState(() => _submitted = true);
                      
                      ctx.read<ClientBloc>().add(
                        UpdateClient(
                          clientId: widget.clientId,
                          username: _usernameCtr.text.trim(),
                          email: _emailCtr.text.trim(),
                          cin: _cinCtr.text.trim(),
                          tel: _phoneCtr.text.trim(),
                          password: _passwordCtr.text.isNotEmpty ? _passwordCtr.text : null,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGreen,
                    ),
                    child: loading
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Mettre à jour',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ],
          );
        },
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
        validator: (v) => v == null || v.length != 8 ? '8 chiffres requis' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _passwordCtr,
        decoration: const InputDecoration(
          labelText: 'Nouveau mot de passe (optionnel)',
          helperText: 'Laissez vide pour conserver l\'actuel'
        ),
        obscureText: true,
        validator: (v) => v != null && v.isNotEmpty && v.length < 6 
            ? 'Au moins 6 caractères' 
            : null,
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
        validator: (v) => v == null || !v.contains('@') ? 'Email invalide' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _phoneCtr,
        decoration: const InputDecoration(labelText: 'Téléphone'),
        keyboardType: TextInputType.phone,
        validator: (v) => v == null || v.length != 8 ? '8 chiffres requis' : null,
      ),
      const SizedBox(height: 12),
    ],
  );
}