// lib/features/dashboard/presentation/screens/parametres_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../presentation/bloc/profile_bloc.dart';
import '../../presentation/bloc/profile_event.dart';
import '../../presentation/bloc/profile_state.dart';
import '../../data/profile_repository.dart';
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

  final _nomCtrl     = TextEditingController();
  final _prenomCtrl  = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _posteCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc(ProfileRepository(baseUrl: '')),
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (ctx, state) {
          if (state is ProfileLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profil mis à jour avec succès')),
            );
          }
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur: ${state.message}')),
            );
          }
        },
        child: AppLayout(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Back + Title row ────────────────────────────
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, size: 28),
                            onPressed: () => Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                              builder: (_) => const DashboardScreen(),
                            )),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Paramètres',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          IconButton(
                              icon: const Icon(Icons.notifications_none),
                              onPressed: () {}),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // ── Avatar + pick image ────────────────────────
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: _pickedImage != null
                                  ? FileImage(_pickedImage!)
                                  : null,
                              backgroundColor: AppColors.accentGreen
                                  .withOpacity(0.3),
                              child: _pickedImage == null
                                  ? const Icon(Icons.person,
                                      size: 60, color: Colors.grey)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 4,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentGreen,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.photo_camera,
                                      size: 20, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // ── Name & role ───────────────────────────────
                      Center(
                        child: Column(
                          children: const [
                            Text('Moez Foulen',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text('Propriétaire',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // ── Basic info form ────────────────────────────
                      const Text('Informations de base',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const Divider(height: 24),
                      _buildField('Nom', _nomCtrl),
                      _buildField('Prénom', _prenomCtrl),
                      _buildField('Email', _emailCtrl),
                      _buildField('Numéro de téléphone', _phoneCtrl),
                      _buildField('Poste', _posteCtrl),
                      _buildField('Mot de passe', _passCtrl, obscure: true),
                      _buildField('Répéter mot de passe', _confirmCtrl,
                          obscure: true),
                    ],
                  ),
                ),
              ),
              // ── Footer buttons ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: _clearFields,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accentGreen,
                        side:
                            const BorderSide(color: AppColors.accentGreen),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Annuler'),
                    ),
                    const SizedBox(width: 16),
                    BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (ctx, state) {
                        final busy = state is ProfileLoading;
                        return ElevatedButton(
                          onPressed: busy ? null : _onSavePressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentGreen,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: busy
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Sauvegarder'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          obscureText: obscure,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
                vertical: 12, horizontal: 12),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ]),
    );
  }

  void _clearFields() {
    _nomCtrl.clear();
    _prenomCtrl.clear();
    _emailCtrl.clear();
    _phoneCtrl.clear();
    _posteCtrl.clear();
    _passCtrl.clear();
    _confirmCtrl.clear();
    setState(() => _pickedImage = null);
  }

  Future<void> _pickImage() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  void _onSavePressed() {
    if (_passCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Les mots de passe ne correspondent pas')));
      return;
    }
    context.read<ProfileBloc>().add(UpdateProfile(
          username: _nomCtrl.text,
          email: _emailCtrl.text,
          firstName: _prenomCtrl.text,
          // you may map posteCtrl to a “title” or other field as needed
          tel: _phoneCtrl.text,
          password: _passCtrl.text.isEmpty ? null : _passCtrl.text,
          photo: _pickedImage,
        ));
  }
}
