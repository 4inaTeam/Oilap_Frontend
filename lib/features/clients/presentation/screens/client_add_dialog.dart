import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/dialogs/success_dialog.dart';
import '../bloc/client_bloc.dart';
import '../bloc/client_event.dart';
import '../bloc/client_state.dart';

class ClientAddDialog extends StatefulWidget {
  final String? initialCin;

  const ClientAddDialog({Key? key, this.initialCin}) : super(key: key);

  @override
  State<ClientAddDialog> createState() => _ClientAddDialogState();
}

class _ClientAddDialogState extends State<ClientAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtr = TextEditingController();
  final _emailCtr = TextEditingController();
  final _cinCtr = TextEditingController();
  final _phoneCtr = TextEditingController();
  final _passwordCtr = TextEditingController();
  final _confirmPasswordCtr = TextEditingController();
  final String _role = 'CLIENT';
  bool _submitted = false;

  // Country code selection
  String _selectedCountryCode = '+216'; // Default to Tunisia
  final List<Map<String, String>> _countryCodes = [
    {'code': '+216', 'country': 'Tunisia', 'flag': '🇹🇳', 'phoneLength': '8'},
    {'code': '+33', 'country': 'France', 'flag': '🇫🇷', 'phoneLength': '10'},
    {'code': '+49', 'country': 'Germany', 'flag': '🇩🇪', 'phoneLength': '11'},
    {
      'code': '+1',
      'country': 'USA/Canada',
      'flag': '🇺🇸',
      'phoneLength': '10',
    },
    {'code': '+44', 'country': 'UK', 'flag': '🇬🇧', 'phoneLength': '10'},
    {'code': '+39', 'country': 'Italy', 'flag': '🇮🇹', 'phoneLength': '10'},
    {'code': '+34', 'country': 'Spain', 'flag': '🇪🇸', 'phoneLength': '9'},
    {'code': '+212', 'country': 'Morocco', 'flag': '🇲🇦', 'phoneLength': '9'},
    {'code': '+213', 'country': 'Algeria', 'flag': '🇩🇿', 'phoneLength': '9'},
    {'code': '+20', 'country': 'Egypt', 'flag': '🇪🇬', 'phoneLength': '10'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCin != null) {
      _cinCtr.text = widget.initialCin!;
    }
  }

  @override
  void dispose() {
    _usernameCtr.dispose();
    _emailCtr.dispose();
    _cinCtr.dispose();
    _phoneCtr.dispose();
    _passwordCtr.dispose();
    _confirmPasswordCtr.dispose();
    super.dispose();
  }

  String get _fullPhoneNumber =>
      '$_selectedCountryCode${_phoneCtr.text.trim()}';

  int get _expectedPhoneLength {
    final country = _countryCodes.firstWhere(
      (c) => c['code'] == _selectedCountryCode,
      orElse: () => {'phoneLength': '8'},
    );
    return int.tryParse(country['phoneLength'] ?? '8') ?? 8;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth =
        screenSize.width < 600
            ? screenSize.width * 0.9
            : screenSize.width * 0.8;
    final isMobile = screenSize.width < 600;

    return BlocListener<ClientBloc, ClientState>(
      listener: (ctx, state) {
        if (state is ClientAddSuccess && mounted) {
          Navigator.of(context).pop();
          showSuccessDialog(
            context,
            title: 'Succès',
            message: 'Le client ${_usernameCtr.text} a été ajouté avec succès',
          );
        }

        if (state is ClientOperationFailure) {
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
                'Ajouter un client',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _submitted ? null : () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.accentGreen,
                    ),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 8),
                  BlocBuilder<ClientBloc, ClientState>(
                    builder: (ctx, state) {
                      final loading = state is ClientLoading;
                      return ElevatedButton(
                        onPressed:
                            loading
                                ? null
                                : () {
                                  if (!_formKey.currentState!.validate())
                                    return;
                                  setState(() => _submitted = true);
                                  ctx.read<ClientBloc>().add(
                                    AddClient(
                                      username: _usernameCtr.text.trim(),
                                      email: _emailCtr.text.trim(),
                                      password: _passwordCtr.text,
                                      cin: _cinCtr.text.trim(),
                                      tel:
                                          _fullPhoneNumber, // Send full phone number with country code
                                      role: _role,
                                    ),
                                  );
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGreen,
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
                                  'Enregistrer',
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
        validator:
            (v) => v == null || v.length != 8 ? '8 chiffres requis' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _passwordCtr,
        decoration: const InputDecoration(labelText: 'Mot de passe'),
        obscureText: true,
        validator:
            (v) => v == null || v.length < 6 ? 'Au moins 6 caractères' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _confirmPasswordCtr,
        decoration: const InputDecoration(
          labelText: 'Confirmer le mot de passe',
        ),
        obscureText: true,
        validator: (v) {
          if (v == null || v.isEmpty) return 'Requis';
          if (v != _passwordCtr.text)
            return 'Les mots de passe ne correspondent pas';
          return null;
        },
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
        validator:
            (v) => v == null || !v.contains('@') ? 'Email invalide' : null,
      ),
      const SizedBox(height: 12),
      _buildPhoneField(),
      const SizedBox(height: 12),
    ],
  );

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Téléphone',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            // Country Code Dropdown
            Container(
              width: 120,
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCountryCode,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, size: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  items:
                      _countryCodes.map((country) {
                        return DropdownMenuItem<String>(
                          value: country['code'],
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                country['flag']!,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  country['code']!,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCountryCode = value;
                        _phoneCtr.clear(); // Clear phone when country changes
                      });
                    }
                  },
                ),
              ),
            ),
            // Phone Number Input
            Expanded(
              child: TextFormField(
                controller: _phoneCtr,
                decoration: InputDecoration(
                  hintText: 'Ex: ${_getPhoneExample()}',
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requis';
                  if (v.length != _expectedPhoneLength) {
                    return '$_expectedPhoneLength chiffres requis';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(v)) {
                    return 'Numéros uniquement';
                  }
                  return null;
                },
                onChanged: (value) {
                  // Remove any non-digit characters
                  final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
                  if (digitsOnly != value) {
                    _phoneCtr.value = _phoneCtr.value.copyWith(
                      text: digitsOnly,
                      selection: TextSelection.collapsed(
                        offset: digitsOnly.length,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        // Show full phone number preview
        if (_phoneCtr.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Numéro complet: $_fullPhoneNumber',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  String _getPhoneExample() {
    switch (_selectedCountryCode) {
      case '+216':
        return '12345678';
      case '+33':
        return '0123456789';
      case '+49':
        return '01234567890';
      case '+1':
        return '1234567890';
      case '+44':
        return '1234567890';
      case '+39':
        return '1234567890';
      case '+34':
        return '123456789';
      case '+212':
        return '123456789';
      case '+213':
        return '123456789';
      case '+20':
        return '1234567890';
      default:
        return '12345678';
    }
  }
}
