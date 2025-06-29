import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/dialogs/success_dialog.dart';
import '../../../../shared/dialogs/error_dialog.dart';
import '../../../../core/models/bill_model.dart';
import '../bloc/bill_bloc.dart';
import '../bloc/bill_event.dart';
import '../bloc/bill_state.dart';

class BillUpdateDialog extends StatefulWidget {
  final Bill bill;

  const BillUpdateDialog({Key? key, required this.bill}) : super(key: key);

  @override
  State<BillUpdateDialog> createState() => _BillUpdateDialogState();
}

class _BillUpdateDialogState extends State<BillUpdateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _ownerCtr = TextEditingController();
  final _amountCtr = TextEditingController();
  final _consumptionCtr = TextEditingController();
  final _itemNameCtr = TextEditingController();
  final _itemQuantityCtr = TextEditingController();
  final _itemPriceCtr = TextEditingController();

  String _selectedCategory = 'electricity';
  DateTime? _paymentDate;
  List<Map<String, dynamic>> _items = [];
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  void _populateFields() {
    _ownerCtr.text = widget.bill.owner;
    _selectedCategory = widget.bill.category;
    _amountCtr.text = widget.bill.amount.toString();
    _paymentDate = widget.bill.paymentDate;

    if (widget.bill.consumption != null) {
      _consumptionCtr.text = widget.bill.consumption.toString();
    }

    // Populate items if they exist
    if (widget.bill.items != null) {
      _items = List<Map<String, dynamic>>.from(widget.bill.items!);
    }
  }

  final List<String> _categories = ['electricity', 'water', 'purchase'];

  @override
  void dispose() {
    _ownerCtr.dispose();
    _amountCtr.dispose();
    _consumptionCtr.dispose();
    _itemNameCtr.dispose();
    _itemQuantityCtr.dispose();
    _itemPriceCtr.dispose();
    super.dispose();
  }

  bool get _isUtilityBill =>
      _selectedCategory == 'electricity' || _selectedCategory == 'water';
  bool get _isPurchaseBill => _selectedCategory == 'purchase';

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth =
        screenSize.width < 600
            ? screenSize.width * 0.9
            : screenSize.width * 0.8;
    final isMobile = screenSize.width < 600;

    return BlocListener<BillBloc, BillState>(
      listener: (ctx, state) {
        if (state is BillUpdateSuccess && mounted) {
          final billOwner = _ownerCtr.text.trim();
          Navigator.of(context).pop();
          showSuccessDialog(
            context,
            title: 'Succès',
            message: 'Facture de $billOwner a été mise à jour avec succès',
          );
        }

        if (state is BillOperationFailure && mounted) {
          setState(() => _submitted = false);

          showCustomErrorDialog(
            context,
            message: state.message,
            onRetry: () {
              Navigator.of(context).pop();
              _onSubmit();
            },
          );
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: dialogWidth,
          constraints: BoxConstraints(
            maxWidth: 600,
            maxHeight: screenSize.height * 0.9,
          ),
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Mettre à jour la facture',
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
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _submitted ? null : () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.grey,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 24,
                        vertical: isMobile ? 12 : 16,
                      ),
                    ),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 8),
                  BlocBuilder<BillBloc, BillState>(
                    builder: (ctx, state) {
                      final loading = state is BillLoading;
                      return ElevatedButton(
                        onPressed: loading ? null : _onSubmit,
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

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) {
      showValidationError(
        context,
        'Veuillez corriger les erreurs dans le formulaire.',
      );
      return;
    }

    if (_paymentDate == null) {
      showValidationError(
        context,
        'Veuillez sélectionner une date de paiement.',
      );
      return;
    }

    // Enhanced validation for items for purchase bills
    if (_isPurchaseBill) {
      if (_items.isEmpty) {
        showValidationError(
          context,
          'Au moins un article est requis pour les factures d\'achat.',
        );
        return;
      }

      // Validate each item has required fields
      for (int i = 0; i < _items.length; i++) {
        final item = _items[i];

        if (item['name'] == null || item['name'].toString().trim().isEmpty) {
          showValidationError(
            context,
            'Le nom de l\'article ${i + 1} est requis.',
          );
          return;
        }

        if (item['quantity'] == null ||
            item['quantity'].toString().trim().isEmpty) {
          showValidationError(
            context,
            'La quantité de l\'article ${i + 1} est requise.',
          );
          return;
        }

        if (item['price'] == null || item['price'].toString().trim().isEmpty) {
          showValidationError(
            context,
            'Le prix de l\'article ${i + 1} est requis.',
          );
          return;
        }

        // Validate numeric values
        final quantity = double.tryParse(item['quantity'].toString());
        final price = double.tryParse(item['price'].toString());

        if (quantity == null || quantity <= 0) {
          showValidationError(
            context,
            'La quantité de l\'article ${i + 1} doit être un nombre positif.',
          );
          return;
        }

        if (price == null || price <= 0) {
          showValidationError(
            context,
            'Le prix de l\'article ${i + 1} doit être un nombre positif.',
          );
          return;
        }
      }
    }

    setState(() => _submitted = true);

    context.read<BillBloc>().add(
      UpdateBill(
        id: widget.bill.id!,
        owner: _ownerCtr.text.trim(),
        amount: double.parse(_amountCtr.text),
        category: _selectedCategory,
        paymentDate: _paymentDate!,
        consumption:
            _isUtilityBill ? double.tryParse(_consumptionCtr.text) : null,
        items: _isPurchaseBill ? _items : null,
      ),
    );
  }

  Widget _buildColumn1() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      TextFormField(
        controller: _ownerCtr,
        decoration: const InputDecoration(labelText: 'Propriétaire'),
        validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: const InputDecoration(labelText: 'Catégorie'),
        items:
            _categories.map((category) {
              String displayText;
              switch (category) {
                case 'electricity':
                  displayText = 'Électricité';
                  break;
                case 'water':
                  displayText = 'Eau';
                  break;
                case 'purchase':
                  displayText = 'Achat';
                  break;
                default:
                  displayText = category;
              }
              return DropdownMenuItem(
                value: category,
                child: Text(displayText),
              );
            }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategory = value!;
            // Clear items when changing category
            if (_selectedCategory != 'purchase') {
              _items.clear();
            }
            // Clear consumption when changing to purchase
            if (_selectedCategory == 'purchase') {
              _consumptionCtr.clear();
            }
          });
        },
        validator: (v) => v == null ? 'Requis' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _amountCtr,
        decoration: const InputDecoration(labelText: 'Montant'),
        keyboardType: TextInputType.number,
        validator: (v) {
          if (v == null || v.isEmpty) return 'Requis';
          if (double.tryParse(v) == null) return 'Montant invalide';
          return null;
        },
      ),
      const SizedBox(height: 12),
      if (_isUtilityBill) ...[
        TextFormField(
          controller: _consumptionCtr,
          decoration: const InputDecoration(labelText: 'Consommation'),
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v != null && v.isNotEmpty && double.tryParse(v) == null) {
              return 'Consommation invalide';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
      ],
      InkWell(
        onTap: () => _selectPaymentDate(),
        child: InputDecorator(
          decoration: const InputDecoration(labelText: 'Date de paiement'),
          child: Text(
            _paymentDate != null
                ? '${_paymentDate!.day}/${_paymentDate!.month}/${_paymentDate!.year}'
                : 'Sélectionner une date',
            style: TextStyle(
              color: _paymentDate != null ? Colors.black : Colors.grey[600],
            ),
          ),
        ),
      ),
    ],
  );

  Widget _buildColumn2() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (_isPurchaseBill) ...[
        Row(
          children: [
            const Text(
              'Articles',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              onPressed: _showAddItemDialog,
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.mainColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              _items.isEmpty
                  ? const Center(
                    child: Text(
                      'Aucun article ajouté',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                  : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return ListTile(
                        title: Text(item['name']),
                        subtitle: Text(
                          'Qté: ${item['quantity']} - Prix: ${item['price']} DT',
                        ),
                        trailing: IconButton(
                          onPressed:
                              () => setState(() => _items.removeAt(index)),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      );
                    },
                  ),
        ),
      ] else ...[
        // Show image placeholder for utility bills (non-editable)
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[100],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Image de la facture\n(non modifiable)',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    ],
  );

  Future<void> _selectPaymentDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _paymentDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _paymentDate = date);
    }
  }

  void _showAddItemDialog() {
    // Clear controllers before showing dialog
    _itemNameCtr.clear();
    _itemQuantityCtr.clear();
    _itemPriceCtr.clear();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Ajouter un article'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _itemNameCtr,
                  decoration: const InputDecoration(
                    labelText: 'Nom de l\'article',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _itemQuantityCtr,
                  decoration: const InputDecoration(labelText: 'Quantité'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _itemPriceCtr,
                  decoration: const InputDecoration(labelText: 'Prix unitaire'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _itemNameCtr.clear();
                  _itemQuantityCtr.clear();
                  _itemPriceCtr.clear();
                  Navigator.of(context).pop();
                },
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Validate all fields before adding
                  if (_itemNameCtr.text.trim().isNotEmpty &&
                      _itemQuantityCtr.text.trim().isNotEmpty &&
                      _itemPriceCtr.text.trim().isNotEmpty) {
                    // Validate numeric values
                    final quantity = double.tryParse(
                      _itemQuantityCtr.text.trim(),
                    );
                    final price = double.tryParse(_itemPriceCtr.text.trim());

                    if (quantity == null || quantity <= 0) {
                      showValidationError(context, 'Quantité invalide');
                      return;
                    }

                    if (price == null || price <= 0) {
                      showValidationError(context, 'Prix invalide');
                      return;
                    }

                    setState(() {
                      _items.add({
                        'name': _itemNameCtr.text.trim(),
                        'quantity': quantity,
                        'price': price,
                      });
                    });

                    _itemNameCtr.clear();
                    _itemQuantityCtr.clear();
                    _itemPriceCtr.clear();
                    Navigator.of(context).pop();
                  } else {
                    showValidationError(context, 'Tous les champs sont requis');
                  }
                },
                child: const Text('Ajouter'),
              ),
            ],
          ),
    );
  }

  void showValidationError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
