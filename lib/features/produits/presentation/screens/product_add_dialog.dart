import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../../../../core/constants/app_colors.dart';

import '../../../../shared/dialogs/success_dialog.dart';
import 'package:oilab_frontend/features/clients/presentation/screens/client_add_dialog.dart';
import 'package:oilab_frontend/features/clients/presentation/bloc/client_bloc.dart';

class ProductAddDialog extends StatefulWidget {
  const ProductAddDialog({Key? key}) : super(key: key);

  @override
  State<ProductAddDialog> createState() => _ProductAddDialogState();
}

class _ProductAddDialogState extends State<ProductAddDialog> {
  final _quantityController = TextEditingController();
  final _originController = TextEditingController();
  final _clientCinController = TextEditingController();

  bool _isCheckingClient = false;
  bool _clientExists = false;
  final Map<String, String> _errors = {};

  // Quality dropdown value
  String _selectedQuality = 'moyenne';

  // Quality options matching the backend
  final List<Map<String, String>> _qualityOptions = [
    {'value': 'excellente', 'label': 'Excellente'},
    {'value': 'bonne', 'label': 'Bonne'},
    {'value': 'moyenne', 'label': 'Moyenne'},
    {'value': 'mauvaise', 'label': 'Mauvaise'},
  ];

  @override
  void dispose() {
    _quantityController.dispose();
    _originController.dispose();
    _clientCinController.dispose();
    super.dispose();
  }

  Future<void> _checkClientExists(String cin) async {
    if (cin.isEmpty) return;

    setState(() => _isCheckingClient = true);

    try {
      final exists = await context.read<ClientBloc>().checkClientExists(cin);
      setState(() => _clientExists = exists);

      if (!exists) {
        final shouldCreateClient = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                title: const Text('Client non trouvé'),
                content: Text(
                  'Aucun client trouvé avec le CIN: $cin. Voulez-vous créer un nouveau client?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Non'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Oui'),
                  ),
                ],
              ),
        );

        if (shouldCreateClient == true) {
          await showDialog(
            context: context,
            builder: (context) => ClientAddDialog(initialCin: cin),
          );
          _checkClientExists(cin);
        }
      }
    } finally {
      setState(() => _isCheckingClient = false);
    }
  }

  String? _validateField(String field, String value) {
    if (value.isEmpty) {
      return 'Ce champ est obligatoire';
    }
    switch (field) {
      case 'cin':
        if (value.length != 8) {
          return 'Le CIN doit contenir 8 chiffres';
        }
        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
          return 'Le CIN ne doit contenir que des chiffres';
        }
        break;
      case 'quantity':
        if (double.tryParse(value) == null) {
          return 'Veuillez entrer un nombre valide';
        }
        if (double.parse(value) <= 0) {
          return 'La quantité doit être supérieure à 0';
        }
        break;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductOperationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
        if (state is ProductLoadSuccess) {
          Navigator.of(context).pop();
          showProductCreatedSuccess(context);
        }
      },
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 400.0,
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ajouter un produit',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildQualityDropdown(),
                const SizedBox(height: 12),
                _buildInputField(
                  label: 'Origine',
                  controller: _originController,
                ),
                const SizedBox(height: 12),
                _buildInputField(
                  label: 'Quantité (Kg)',
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildInputField(
                  label: 'CIN Client',
                  controller: _clientCinController,
                  keyboardType: TextInputType.number,
                  onBlur: _checkClientExists,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.accentGreen,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _handleAddProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'Ajouter',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQualityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Qualité',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: _selectedQuality,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          items:
              _qualityOptions.map((quality) {
                return DropdownMenuItem<String>(
                  value: quality['value'],
                  child: Text(
                    quality['label']!,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedQuality = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    void Function(String)? onBlur,
  }) {
    final fieldName = label.toLowerCase().replaceAll(' ', '_');
    final error = _errors[fieldName];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 4),
        FocusScope(
          onFocusChange: (hasFocus) {
            if (!hasFocus) {
              setState(() {
                final error = _validateField(
                  label == 'CIN Client' ? 'cin' : fieldName,
                  controller.text.trim(),
                );
                if (error != null) {
                  _errors[fieldName] = error;
                } else {
                  _errors.remove(fieldName);
                }
                if (onBlur != null) onBlur(controller.text);
              });
            }
          },
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: error != null ? Colors.red : Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: error != null ? Colors.red : Colors.grey.shade300,
                ),
              ),
              errorText: error,
              suffixIcon:
                  label == 'CIN Client' && _isCheckingClient
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                      : null,
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  void _handleAddProduct() {
    final fields = {
      'origine': _originController.text.trim(),
      'quantity': _quantityController.text.trim(),
      'cin': _clientCinController.text.trim(),
    };

    setState(() {
      _errors.clear();
      fields.forEach((key, value) {
        final error = _validateField(key, value);
        if (error != null) {
          _errors[key] = error;
        }
      });
    });

    if (_errors.isNotEmpty) {
      return;
    }

    if (!_clientExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez vérifier le CIN du client'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Note: Price is calculated automatically by the backend based on quality
    // estimation_time defaults to 15 minutes in the backend
    // payement defaults to 'unpaid' in the backend
    context.read<ProductBloc>().add(
      CreateProduct(
        quality: _selectedQuality,
        origine: fields['origine']!,
        price: 0.0, // Will be calculated by backend
        quantity: double.parse(fields['quantity']!),
        clientCin: fields['cin']!,
        estimationTime: 15, // Default value, backend will handle this
      ),
    );
  }
}

Future<Map<String, String>?> showProductAddDialog(BuildContext context) {
  return showDialog<Map<String, String>>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const ProductAddDialog();
    },
  );
}
