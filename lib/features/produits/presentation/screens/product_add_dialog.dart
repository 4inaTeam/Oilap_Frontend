import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/dialogs/error_dialog.dart';
import '../../../../shared/dialogs/success_dialog.dart';

class ProductAddDialog extends StatefulWidget {
  const ProductAddDialog({Key? key}) : super(key: key);

  @override
  State<ProductAddDialog> createState() => _ProductAddDialogState();
}

class _ProductAddDialogState extends State<ProductAddDialog> {
  final _quantityController = TextEditingController();
  final _originController = TextEditingController();
  final _qualityController = TextEditingController();
  final _priceController = TextEditingController();
  final _clientCinController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _originController.dispose();
    _qualityController.dispose();
    _priceController.dispose();
    _clientCinController.dispose();
    super.dispose();
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
                _buildInputField(
                  label: 'Qualité',
                  controller: _qualityController,
                ),
                const SizedBox(height: 12),
                _buildInputField(
                  label: 'Origine',
                  controller: _originController,
                ),
                const SizedBox(height: 12),
                _buildInputField(
                  label: 'Prix (DT)',
                  controller: _priceController,
                  keyboardType: TextInputType.number,
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
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Annuler'),
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
                      child: const Text('Ajouter'),
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

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
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
        TextField(
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
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CustomErrorWidget(message: message, showRetry: false),
            ),
          ),
    );
  }

  void _handleAddProduct() {
    try {
      // Validate inputs
      final quality = _qualityController.text.trim();
      final origin = _originController.text.trim();
      final clientCin = _clientCinController.text.trim();
      final price = double.tryParse(_priceController.text.trim());
      final quantity = double.tryParse(_quantityController.text.trim());

      if (quality.isEmpty ||
          origin.isEmpty ||
          clientCin.isEmpty ||
          price == null ||
          quantity == null) {
        _showError('Veuillez remplir tous les champs correctement');
        return;
      }

      // Create product through bloc
      context.read<ProductBloc>().add(
        CreateProduct(
          quality: quality,
          origine: origin,
          price: price,
          quantity: quantity,
          clientCin: clientCin,
        ),
      );
    } catch (e) {
      _showError('Erreur: ${e.toString()}');
    }
  }
}

// Usage example:
// To show the dialog, use this function:
Future<Map<String, String>?> showProductAddDialog(BuildContext context) {
  return showDialog<Map<String, String>>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const ProductAddDialog();
    },
  );
}
