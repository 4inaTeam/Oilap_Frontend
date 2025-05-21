import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/employee_bloc.dart';
import '../bloc/employee_event.dart';
import '../bloc/employee_state.dart';

class EmployeeAddDialog extends StatefulWidget {
  const EmployeeAddDialog({Key? key}) : super(key: key);

  @override
  State<EmployeeAddDialog> createState() => _EmployeeAddDialogState();
}

class _EmployeeAddDialogState extends State<EmployeeAddDialog> {
  final _formKey       = GlobalKey<FormState>();
  final _usernameCtr   = TextEditingController();
  final _emailCtr      = TextEditingController();
  final _cinCtr        = TextEditingController();
  final _phoneCtr      = TextEditingController();
  final _passwordCtr   = TextEditingController();
  String _role         = 'EMPLOYEE';
  bool   _submitted    = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<EmployeeBloc, EmployeeState>(
      listener: (ctx, state) {
        if (state is EmployeeAddSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Employé ajouté avec succès')),
          );
        }
        if (state is EmployeeOperationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${state.message}')),
          );
        }
      },
      child: AlertDialog(
        title: const Text('Ajouter un employé'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildColumn1()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildColumn2()),
                        ],
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
        actions: [
          TextButton(
            onPressed: _submitted ? null : () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.accentGreen,
            ),
            child: const Text('Annuler'),
          ),
          BlocBuilder<EmployeeBloc, EmployeeState>(
            builder: (ctx, state) {
              final loading = state is EmployeeLoading;
              return ElevatedButton(
                onPressed: loading
                    ? null
                    : () {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() => _submitted = true);
                        ctx.read<EmployeeBloc>().add(
                          AddEmployee(
                            username: _usernameCtr.text.trim(),
                            email:    _emailCtr.text.trim(),
                            password: _passwordCtr.text,
                            cin:      _cinCtr.text.trim(),
                            tel:      _phoneCtr.text.trim(),
                            role:     _role,
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
                        'Enregistrer',
                        style: TextStyle(color: Colors.white),
                      ),
              );
            },
          ),
        ],
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
            decoration: const InputDecoration(labelText: 'Mot de passe'),
            obscureText: true,
            validator: (v) => v == null || v.length < 6 ? 'Au moins 6 caractères' : null,
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
          DropdownButtonFormField<String>(
            value: _role,
            decoration: const InputDecoration(labelText: 'Rôle'),
            items: const [
              DropdownMenuItem(value: 'EMPLOYEE', child: Text('Employé')),
              DropdownMenuItem(value: 'ACCOUNTANT', child: Text('Comptable')),
            ],
            onChanged: (s) => setState(() => _role = s!),
          ),
        ],
      );

  @override
  void dispose() {
    for (final c in [
      _usernameCtr,
      _emailCtr,
      _cinCtr,
      _phoneCtr,
      _passwordCtr
    ]) {
      c.dispose();
    }
    super.dispose();
  }
}
