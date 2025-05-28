import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';

class ProductUpdateDialog extends StatefulWidget {
  final dynamic product;
  
  const ProductUpdateDialog({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductUpdateDialog> createState() => _ProductUpdateDialogState();
}

class _ProductUpdateDialogState extends State<ProductUpdateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtr = TextEditingController();
  final _emailCtr = TextEditingController();
  final _cinCtr = TextEditingController();
  final _phoneCtr = TextEditingController();
  final _passwordCtr = TextEditingController();
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    // *** UPDATED: Populate fields with existing product data ***
    _populateFields();
  }

  // *** NEW: Method to populate form fields with existing data ***
  void _populateFields() {
    if (widget.product != null) {
      _usernameCtr.text = widget.product.name ?? '';
      _emailCtr.text = widget.product.email ?? '';
      _cinCtr.text = widget.product.cin ?? '';
      _phoneCtr.text = widget.product.tel ?? '';
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
    return BlocListener<ProductBloc, ProductState>(
      listener: (ctx, state) {
        // *** UPDATED: Listen for update success instead of add success ***
        if (state is ProductUpdateSuccess && mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Employé mis à jour avec succès')),
          );
        }

        if (state is ProductOperationFailure) {
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
          BlocBuilder<ProductBloc, ProductState>(
            builder: (ctx, state) {
              final loading = state is ProductLoading;
              return ElevatedButton(
                onPressed: loading
                    ? null
                    : () {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() => _submitted = true);
                        
                        // *** UPDATED: Dispatch Updateproduct event instead of Addproduct ***
                        ctx.read<ProductBloc>().add(
                              UpdateProduct(
                                id: widget.product.id,
                                name: _usernameCtr.text,
                                description: _emailCtr.text,
                                category: _cinCtr.text,
                                sku: _phoneCtr.text,
                                barcode: _passwordCtr.text,   
                                price: 0.0, 
                                quantity: 0, 
                               
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