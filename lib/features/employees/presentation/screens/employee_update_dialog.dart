import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/employee_bloc.dart';
import '../bloc/employee_event.dart';
import '../bloc/employee_state.dart';

class EmployeeUpdateDialog extends StatefulWidget {
  // *** UPDATED: Accept employee data as parameter ***
  final dynamic employee;
  
  const EmployeeUpdateDialog({Key? key, required this.employee}) : super(key: key);

  @override
  State<EmployeeUpdateDialog> createState() => _EmployeeUpdateDialogState();
}

class _EmployeeUpdateDialogState extends State<EmployeeUpdateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtr = TextEditingController();
  final _emailCtr = TextEditingController();
  final _cinCtr = TextEditingController();
  final _phoneCtr = TextEditingController();
  final _passwordCtr = TextEditingController();
  final String _role = 'EMPLOYEE';
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    // *** UPDATED: Populate fields with existing employee data ***
    _populateFields();
  }

  // *** NEW: Method to populate form fields with existing data ***
  void _populateFields() {
    if (widget.employee != null) {
      _usernameCtr.text = widget.employee.name ?? '';
      _emailCtr.text = widget.employee.email ?? '';
      _cinCtr.text = widget.employee.cin ?? '';
      _phoneCtr.text = widget.employee.tel ?? '';
      // Note: Password field is left empty for security reasons
    }
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<EmployeeBloc, EmployeeState>(
      listener: (ctx, state) {
        // *** UPDATED: Listen for update success instead of add success ***
        if (state is EmployeeUpdateSuccess && mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Employé mis à jour avec succès')),
          );
        }

        if (state is EmployeeOperationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${state.message}'))
          );
        }
      },
      child: AlertDialog(
        title: const Text('Mettre à jour un employé'),
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
                        
                        // *** UPDATED: Dispatch UpdateEmployee event instead of AddEmployee ***
                        ctx.read<EmployeeBloc>().add(
                              UpdateEmployee(
                                id: widget.employee.id,
                                username: _usernameCtr.text.trim(),
                                email: _emailCtr.text.trim(),
                                password: _passwordCtr.text.isNotEmpty ? _passwordCtr.text : null,
                                cin: _cinCtr.text.trim(),
                                tel: _phoneCtr.text.trim(),
                                role: _role,
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
              hintText: 'Laissez vide pour garder l\'ancien'
            ),
            obscureText: true,
            // *** UPDATED: Password is optional for updates ***
            validator: (v) => v != null && v.isNotEmpty && v.length < 6 ? 'Au moins 6 caractères' : null,
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