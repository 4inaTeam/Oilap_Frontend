import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/dialogs/success_dialog.dart';
import '../../../../shared/dialogs/error_dialog.dart';
import '../bloc/bill_bloc.dart';
import '../bloc/bill_event.dart';
import '../bloc/bill_state.dart';

class BillAddDialog extends StatefulWidget {
  final String? preselectedCategory;

  const BillAddDialog({Key? key, this.preselectedCategory}) : super(key: key);

  @override
  State<BillAddDialog> createState() => _BillAddDialogState();
}

class _BillAddDialogState extends State<BillAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _ownerCtr = TextEditingController();
  final _amountCtr = TextEditingController();
  final _consumptionCtr = TextEditingController();
  final _itemNameCtr = TextEditingController();
  final _itemQuantityCtr = TextEditingController();
  final _itemPriceCtr = TextEditingController();

  String _selectedCategory = 'electricity';
  DateTime? _paymentDate;
  File? _selectedImage;
  Uint8List? _webImage;
  List<Map<String, dynamic>> _items = [];
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    if (widget.preselectedCategory != null) {
      _selectedCategory = widget.preselectedCategory!;
    }
  }

  final List<String> _categories = ['electricity', 'water', 'purchase'];

  final ImagePicker _picker = ImagePicker();

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
  bool get _requiresImage =>
      _isUtilityBill || _isPurchaseBill; 

  bool get _hasValidImage {
    if (kIsWeb) {
      return _webImage != null;
    } else {
      return _selectedImage != null;
    }
  }

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
        if (state is BillCreateSuccess && mounted) {
          final billOwner = _ownerCtr.text.trim();

          Navigator.of(context).pop();

          showSuccessDialog(
            context,
            title: 'Succès',
            message: 'Facture de $billOwner a été ajoutée avec succès',
          ).then((_) {
            context.read<BillBloc>().add(LoadBills());
          });
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
                'Ajouter une facture',
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 24,
                        vertical: isMobile ? 12 : 16,
                      ),
                    ),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(color: Colors.white),
                    ),
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
                                  'Ajouter',
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

    // Validate image requirement - ALL bill types now require images
    if (!_hasValidImage) {
      showValidationError(
        context,
        'Une image est requise pour toutes les factures.',
      );
      return;
    }

    // Validate items for purchase bills
    if (_isPurchaseBill && _items.isEmpty) {
      showValidationError(
        context,
        'Au moins un article est requis pour les factures d\'achat.',
      );
      return;
    }

    // Additional validation for image file accessibility (mobile only)
    if (!kIsWeb && _selectedImage != null) {
      // Check if file exists and is accessible
      try {
        if (!_selectedImage!.existsSync()) {
          showValidationError(
            context,
            'Le fichier image sélectionné n\'est pas accessible. Veuillez sélectionner une nouvelle image.',
          );
          return;
        }
      } catch (e) {
        showValidationError(
          context,
          'Erreur lors de la vérification de l\'image. Veuillez sélectionner une nouvelle image.',
        );
        return;
      }
    }

    // Validate web image
    if (kIsWeb && _webImage == null) {
      showValidationError(context, 'Veuillez sélectionner une image.');
      return;
    }

    setState(() => _submitted = true);

    context.read<BillBloc>().add(
      CreateBill(
        owner: _ownerCtr.text.trim(),
        amount: double.parse(_amountCtr.text),
        category: _selectedCategory,
        paymentDate: _paymentDate ?? DateTime.now(),
        consumption:
            _isUtilityBill ? double.tryParse(_consumptionCtr.text) : null,
        items: _isPurchaseBill ? _items : null,
        imageFile: !kIsWeb ? _selectedImage : null,
        webImage: kIsWeb ? _webImage : null,
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
            _items.clear();
            _selectedImage = null;
            _webImage = null;
            _consumptionCtr.clear();
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
      if (_requiresImage) ...[
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              (_selectedImage != null || _webImage != null)
                  ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:
                            kIsWeb
                                ? Image.memory(
                                  _webImage!,
                                  width: double.infinity,
                                  height: 120,
                                  fit: BoxFit.cover,
                                )
                                : Image.file(
                                  _selectedImage!,
                                  width: double.infinity,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          onPressed:
                              () => setState(() {
                                _selectedImage = null;
                                _webImage = null;
                              }),
                          icon: const Icon(Icons.close, color: Colors.red),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(4),
                          ),
                        ),
                      ),
                    ],
                  )
                  : InkWell(
                    onTap: _pickImage,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_photo_alternate,
                          size: 40,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isPurchaseBill
                              ? 'Ajouter photo de la facture'
                              : 'Ajouter une image',
                          style: const TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
        ),
        const SizedBox(height: 12),
      ],

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
          height: 200,
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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) {
        return;
      }

      if (kIsWeb) {
        try {
          final bytes = await image.readAsBytes();

          if (bytes.isEmpty) {
            throw Exception('Image file is empty');
          }

          setState(() {
            _webImage = bytes;
            _selectedImage = null;
          });
        } catch (e) {
          showValidationError(
            context,
            'Erreur lors de la lecture de l\'image: ${e.toString()}',
          );
          return;
        }
      } else {
        try {
          final file = File(image.path);

          if (!await file.exists()) {
            throw Exception('Image file does not exist');
          }

          final fileSize = await file.length();

          if (fileSize == 0) {
            throw Exception('Image file is empty');
          }

          final testBytes = await file.readAsBytes();
          if (testBytes.isEmpty) {
            throw Exception('Cannot read image file');
          }

          setState(() {
            _selectedImage = file;
            _webImage = null;
          });
        } catch (e) {
          showValidationError(
            context,
            'Erreur lors de la sélection de l\'image: ${e.toString()}',
          );
          return;
        }
      }
    } catch (e) {
      showValidationError(
        context,
        'Erreur de sélection d\'image: ${e.toString()}',
      );
    }
  }

  void _showAddItemDialog() {
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
                  if (_itemNameCtr.text.isNotEmpty &&
                      _itemQuantityCtr.text.isNotEmpty &&
                      _itemPriceCtr.text.isNotEmpty) {
                    setState(() {
                      _items.add({
                        'name': _itemNameCtr.text,
                        'quantity': int.parse(_itemQuantityCtr.text),
                        'price': double.parse(_itemPriceCtr.text),
                      });
                    });
                    _itemNameCtr.clear();
                    _itemQuantityCtr.clear();
                    _itemPriceCtr.clear();
                    Navigator.of(context).pop();
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
