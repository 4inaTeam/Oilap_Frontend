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
        widget.product.status == 'pending' ? 'doing' : widget.product.status;
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
          _handleErrorMessage(context, state.message);
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
                          enabled: _canEditField(),
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          label: 'Origine',
                          controller: _origineCtr,
                          enabled: _canEditField(),
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          label: 'Prix (DT)',
                          controller: _priceCtr,
                          keyboardType: TextInputType.number,
                          enabled: _canEditField(),
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          label: 'Quantité',
                          controller: _quantityCtr,
                          keyboardType: TextInputType.number,
                          enabled: _canEditField(),
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          label: 'CIN Client',
                          controller: _clientCinCtr,
                          enabled: _canEditField(),
                        ),
                        const SizedBox(height: 12),
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
                                  _getAvailableStatuses().map((status) {
                                    return DropdownMenuItem(
                                      value: status,
                                      child: Text(
                                        _getStatusDisplayName(status),
                                        style: TextStyle(
                                          color:
                                              _canChangeToStatus(status)
                                                  ? Colors.black
                                                  : Colors.grey,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null &&
                                    _canChangeToStatus(newValue)) {
                                  setState(() => _selectedStatus = newValue);
                                }
                              },
                            ),
                            if (_getStatusHelpText().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _getStatusHelpText(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
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
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 24,
                        vertical: isMobile ? 12 : 16,
                      ),
                    ),
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
                                : const Text(
                                  'Mettre à jour',
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

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: enabled ? AppColors.textColor : Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
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
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          validator:
              enabled
                  ? (v) => v == null || v.isEmpty ? 'Ce champ est requis' : null
                  : null,
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
        quantity: quantity,
        clientCin: _clientCinCtr.text.trim(),
        status: _selectedStatus,
      ),
    );
  }

  // Check if fields can be edited (not for done products)
  bool _canEditField() {
    return widget.product.status != 'done';
  }

  List<String> _getAvailableStatuses() {
    switch (widget.product.status) {
      case 'pending':
        return ['doing'];
      case 'doing':
        return ['doing', 'done'];
      case 'done':
        return ['done']; 
      case 'canceled':
        return ['canceled']; 
      default:
        return ['doing', 'done'];
    }
  }

  // Check if status can be changed to specific status
  bool _canChangeToStatus(String status) {
    final currentStatus = widget.product.status;

    // Cannot update products with 'done' status
    if (currentStatus == 'done') return false;

    // Cannot update products with 'canceled' status
    if (currentStatus == 'canceled') return false;

    switch (currentStatus) {
      case 'pending':
        return status == 'doing';
      case 'doing':
        return status == 'doing' || status == 'done';
      default:
        return true;
    }
  }

  // Get display name for status
  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'pending':
        return 'EN ATTENTE';
      case 'doing':
        return 'EN COURS';
      case 'done':
        return 'TERMINÉ';
      case 'canceled':
        return 'ANNULÉ';
      default:
        return status.toUpperCase();
    }
  }

  // Get help text for current status restrictions
  String _getStatusHelpText() {
    switch (widget.product.status) {
      case 'done':
        return 'Les produits terminés ne peuvent pas être modifiés';
      case 'canceled':
        return 'Les produits annulés ne peuvent pas être modifiés';
      case 'doing':
        return 'Peut être marqué comme terminé';
      case 'pending':
        return 'Peut être mis en cours';
      default:
        return '';
    }
  }

  void _handleErrorMessage(BuildContext context, String message) {
    String userFriendlyMessage;

    if (message.contains("Cannot update a product with 'done' status")) {
      userFriendlyMessage = 'Impossible de modifier un produit déjà terminé.';
    } else if (message.contains(
      "Can only cancel products in 'pending' status",
    )) {
      userFriendlyMessage =
          'Seuls les produits en attente peuvent être annulés.';
    } else if (message.contains(
      "Only employees or admins can cancel products",
    )) {
      userFriendlyMessage =
          'Seuls les employés ou administrateurs peuvent annuler des produits.';
    } else if (message.contains(
      "Only employees or admins can update the status of a product",
    )) {
      userFriendlyMessage =
          'Seuls les employés ou administrateurs peuvent modifier le statut d\'un produit.';
    } else if (message.contains(
      "Products in 'doing' status can only be marked as 'done' or 'canceled'",
    )) {
      userFriendlyMessage =
          'Les produits en cours peuvent seulement être marqués comme terminés ou annulés.';
    } else {
      userFriendlyMessage = 'Erreur: $message';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(userFriendlyMessage),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
