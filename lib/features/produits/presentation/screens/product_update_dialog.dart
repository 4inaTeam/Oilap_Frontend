import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/product_model.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';

class ProductUpdateDialog extends StatefulWidget {
  final Product product;

  const ProductUpdateDialog({Key? key, required this.product})
    : super(key: key);

  @override
  State<ProductUpdateDialog> createState() => _ProductUpdateDialogState();
}

class _ProductUpdateDialogState extends State<ProductUpdateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _qualityCtr = TextEditingController();
  final _origineCtr = TextEditingController();
  final _priceCtr = TextEditingController();
  final _quantityCtr = TextEditingController();
  final _clientCinCtr = TextEditingController();
  String? _selectedStatus;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  void _populateFields() {
    _qualityCtr.text = widget.product.quality ?? '';
    _origineCtr.text = widget.product.origine ?? '';
    _priceCtr.text = widget.product.price?.toString() ?? '';
    _quantityCtr.text = widget.product.quantity?.toString() ?? '';
    _clientCinCtr.text = widget.product.client;
    _selectedStatus =
        widget.product.status == 'pending'
            ? 'doing'
            : widget.product.status; // Initialize with valid value
  }

  @override
  void dispose() {
    _isDisposed = true;
    _qualityCtr.dispose();
    _origineCtr.dispose();
    _priceCtr.dispose();
    _quantityCtr.dispose();
    _clientCinCtr.dispose();
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

    return BlocListener<ProductBloc, ProductState>(
      listenWhen: (_, __) => !_isDisposed,
      listener: (ctx, state) {
        if (!mounted || _isDisposed) return;

        if (state is ProductUpdateSuccess) {
          Navigator.of(context).pop();


          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Le produit a été mis à jour avec succès'),
            ),
          );

          // Finally reload products
          Future.microtask(() {
            if (!_isDisposed) {
              context.read<ProductBloc>().add(
                LoadProducts(page: 1, pageSize: 6),
              );
            }
          });
        }

        if (state is ProductOperationFailure) {
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
                'Mettre à jour le produit',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildInputField(
                          label: 'Qualité',
                          controller: _qualityCtr,
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          label: 'Origine',
                          controller: _origineCtr,
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          label: 'Prix (DT)',
                          controller: _priceCtr,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          label: 'Quantité',
                          controller: _quantityCtr,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          label: 'CIN Client',
                          controller: _clientCinCtr,
                        ),
                        const SizedBox(height: 12),
                        // Add Status Dropdown
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Status',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              value: _selectedStatus,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                              validator:
                                  (value) =>
                                      value == null ? 'Champ requis' : null,
                              items:
                                  ['doing', 'done'].map((status) {
                                    return DropdownMenuItem(
                                      value: status,
                                      enabled: _canChangeStatus(status),
                                      child: Text(status.toUpperCase()),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null &&
                                    _canChangeStatus(newValue)) {
                                  setState(() => _selectedStatus = newValue);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 8),
                  BlocBuilder<ProductBloc, ProductState>(
                    builder: (ctx, state) {
                      final loading = state is ProductLoading;
                      return ElevatedButton(
                        onPressed: loading ? null : _handleUpdate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 16 : 24,
                            vertical: isMobile ? 12 : 16,
                          ),
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
                                : const Text('Mettre à jour'),
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
        TextFormField(
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
          validator:
              (v) => v == null || v.isEmpty ? 'Ce champ est requis' : null,
        ),
      ],
    );
  }

  void _handleUpdate() {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceCtr.text.trim());
    final quantityDouble = double.tryParse(_quantityCtr.text.trim());
    final quantity = quantityDouble?.toInt();

    if (price == null || quantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prix et quantité doivent être des nombres valides'),
        ),
      );
      return;
    }

    context.read<ProductBloc>().add(
      UpdateProduct(
        id: widget.product.id,
        quality: _qualityCtr.text.trim(),
        origine: _origineCtr.text.trim(),
        price: price,
        quantity: quantity,
        clientCin: _clientCinCtr.text.trim(),
        status: _selectedStatus,
      ),
    );
  }

  bool _canChangeStatus(String status) {
    if (widget.product.status == 'done') return false;
    if (widget.product.status == 'doing' && status != 'done') return false;
    return true;
  }
}
