import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oilab_frontend/core/models/user_model.dart';

import '../../presentation/bloc/profile_bloc.dart';
import '../../presentation/bloc/profile_event.dart';
import '../../presentation/bloc/profile_state.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import 'package:oilab_frontend/core/constants/app_colors.dart';
import 'package:oilab_frontend/shared/widgets/app_layout.dart';

class ParametresScreen extends StatefulWidget {
  const ParametresScreen({super.key});
  @override
  _ParametresScreenState createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  final _picker = ImagePicker();
  File? _pickedImage;
  Uint8List? _pickedImageBytes;
  final _formKey = GlobalKey<FormState>();

  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cinCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadCurrentUser());
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _cinCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (ctx, state) {
        if (state is ProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Profil mis à jour avec succès'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          context.read<ProfileBloc>().add(LoadCurrentUser());
        }
        if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Erreur: ${state.message}')),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
        if (state is ProfileLoaded) {
          _populateFields(state.user);
          _currentUser = state.user;
        }
      },
      child: AppLayout(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.accentGreen,
                          size: 20,
                        ),
                        onPressed:
                            () => Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const DashboardScreen(),
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Mon Profil',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.notifications_none,
                          color: Colors.grey,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  if (state is ProfileLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentGreen,
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfilePictureSection(),
                          const SizedBox(height: 32),

                          _buildSectionCard(
                            title: 'Informations personnelles',
                            icon: Icons.person_outline,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildModernField(
                                      'Nom',
                                      _nomCtrl,
                                      Icons.badge_outlined,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildModernField(
                                      'Prénom',
                                      _prenomCtrl,
                                      Icons.person_outline,
                                    ),
                                  ),
                                ],
                              ),
                              _buildModernField(
                                'CIN',
                                _cinCtrl,
                                Icons.credit_card_outlined,
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          _buildSectionCard(
                            title: 'Informations de contact',
                            icon: Icons.contact_mail_outlined,
                            children: [
                              _buildModernField(
                                'Email',
                                _emailCtrl,
                                Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              _buildModernField(
                                'Numéro de téléphone',
                                _phoneCtrl,
                                Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          _buildSectionCard(
                            title: 'Sécurité',
                            icon: Icons.security_outlined,
                            children: [
                              _buildPasswordField(
                                'Nouveau mot de passe',
                                _passCtrl,
                                _obscurePassword,
                                () {
                                  setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  );
                                },
                              ),
                              _buildPasswordField(
                                'Confirmer le mot de passe',
                                _confirmCtrl,
                                _obscureConfirmPassword,
                                () {
                                  setState(
                                    () =>
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword,
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearFields,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (ctx, state) {
                        final busy = state is ProfileLoading;
                        return ElevatedButton(
                          onPressed: busy ? null : _onSavePressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child:
                              busy
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text(
                                    'Sauvegarder',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentGreen.withOpacity(0.2),
                      AppColors.accentGreen.withOpacity(0.1),
                    ],
                  ),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _getProfileImage(),
                  backgroundColor: Colors.grey[100],
                  child:
                      _getProfileImage() == null
                          ? Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey[400],
                          )
                          : null,
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentGreen.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Changer la photo de profil',
            style: TextStyle(
              color: AppColors.accentGreen,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider? _getProfileImage() {
    if (kIsWeb) {
      if (_pickedImageBytes != null) {
        return MemoryImage(_pickedImageBytes!);
      } else if (_currentUser?.profilePhotoUrl != null &&
          _currentUser!.profilePhotoUrl!.isNotEmpty) {
        return NetworkImage(_currentUser!.profilePhotoUrl!);
      }
    } else {
      if (_pickedImage != null) {
        return FileImage(_pickedImage!);
      } else if (_currentUser?.profilePhotoUrl != null &&
          _currentUser!.profilePhotoUrl!.isNotEmpty) {
        return NetworkImage(_currentUser!.profilePhotoUrl!);
      }
    }
    return null;
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.accentGreen, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildModernField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4A5568),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: ctrl,
            obscureText: obscure,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.accentGreen, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: (value) {
              if (label.contains('Email') &&
                  value != null &&
                  value.isNotEmpty) {
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Veuillez entrer un email valide';
                }
              }
              if ((label.contains('Nom') ||
                      label.contains('Email') ||
                      label.contains('CIN')) &&
                  (value == null || value.isEmpty)) {
                return 'Ce champ est obligatoire';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController ctrl,
    bool obscure,
    VoidCallback toggleVisibility,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4A5568),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: ctrl,
            obscureText: obscure,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.lock_outline,
                color: Colors.grey[400],
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[400],
                  size: 20,
                ),
                onPressed: toggleVisibility,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.accentGreen, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: (value) {
              if (ctrl == _confirmCtrl && value != _passCtrl.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              if (value != null && value.isNotEmpty && value.length < 8) {
                return 'Le mot de passe doit contenir au moins 8 caractères';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  void _populateFields(User user) {
    _nomCtrl.text = user.name;
    _emailCtrl.text = user.email;
    _phoneCtrl.text = user.tel ?? '';
    _cinCtrl.text = user.cin;
    _passCtrl.clear();
    _confirmCtrl.clear();
  }

  void _clearFields() {
    if (_currentUser != null) {
      _populateFields(_currentUser!);
    } else {
      _nomCtrl.clear();
      _prenomCtrl.clear();
      _emailCtrl.clear();
      _phoneCtrl.clear();
      _cinCtrl.clear();
    }
    _passCtrl.clear();
    _confirmCtrl.clear();
    setState(() {
      _pickedImage = null;
      _pickedImageBytes = null;
    });
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (picked != null) {
        setState(() {});

        if (kIsWeb) {
          final bytes = await picked.readAsBytes();
          setState(() {
            _pickedImageBytes = bytes;
          });
        } else {
          setState(() {
            _pickedImage = File(picked.path);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sélection de l\'image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_passCtrl.text.isNotEmpty && _passCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les mots de passe ne correspondent pas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_nomCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _cinCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    context.read<ProfileBloc>().add(
      UpdateProfile(
        name: _nomCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        cin: _cinCtrl.text.trim(),
        tel: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        password: _passCtrl.text.isEmpty ? null : _passCtrl.text,
        profilePhoto: _pickedImage, 
        profilePhotoBytes: _pickedImageBytes, 
      ),
    );
  }
}
