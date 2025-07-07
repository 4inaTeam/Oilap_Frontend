import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/features/clients/presentation/screens/client_list_screen.dart';
import 'package:oilab_frontend/features/comptableDashboard/presentation/screens/dashboard_Accounatant_screen.dart';
import 'package:oilab_frontend/features/produits/presentation/screens/product_list_screen.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/footer_widget.dart';
import '../../data/auth_repository.dart';

import '../screens/passwordForget.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

import 'package:oilab_frontend/shared/dialogs/error_dialog.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SignInView();
  }
}

class _SignInView extends StatefulWidget {
  const _SignInView();
  @override
  State<_SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<_SignInView> {
  final _formKey = GlobalKey<FormState>();
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _hasNavigated = false;

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      AuthLoginRequested(
        _identifierCtrl.text.trim(),
        _passwordCtrl.text.trim(),
      ),
    );
  }

  void _navigateBasedOnRole() {
    if (_hasNavigated) return;

    final String? role = AuthRepository.currentRole;

    if (role == null) {
      return;
    }

    _hasNavigated = true;

    if (role == 'ACCOUNTANT') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AccountantScreen()),
        (route) => false,
      );
    } else if (role == 'CLIENT') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ProductListScreen()),
        (route) => false,
      );
    } else if (role == 'EMPLOYEE') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ClientListScreen()),
        (route) => false,
      );
    } else {

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardPage()),
        (route) => false,
      );
    }
  }

  Future<void> _showAuthErrorDialog() async {
    if (!mounted) return;

    await showCustomErrorDialog(
      context,
      message: 'Email ou mot de passe incorrect. Veuillez réessayer.',
      showRetry: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final panelWidth = screenWidth * 0.8;
    const logoHeight = 100.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUserLoadSuccess) {
            _navigateBasedOnRole();
          } else if (state is AuthLoadSuccess) {
            // Handle successful authentication without user details
          } else if (state is AuthLoadFailure) {
            // Show custom error dialog instead of SnackBar
            _showAuthErrorDialog();
          }
        },
        child: Center(
          child: SingleChildScrollView(
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: panelWidth,
                  margin: EdgeInsets.only(top: isMobile ? logoHeight / 2 : 0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/Group.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 48,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isMobile) ...[
                        Image.asset(
                          'assets/images/WhatsApp.png',
                          height: logoHeight,
                        ),
                        const SizedBox(height: 24),
                      ],
                      const Text(
                        'Se connecter',
                        style: TextStyle(
                          fontFamily: 'BAHNSCHRIFT',
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _identifierCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Email ou CIN',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Veuillez entrer votre email ou CIN';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: _obscure,
                                decoration: InputDecoration(
                                  labelText: 'Mot de passe',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: AppColors.accentGreen,
                                    ),
                                    onPressed:
                                        () => setState(
                                          () => _obscure = !_obscure,
                                        ),
                                  ),
                                ),
                                validator:
                                    (v) =>
                                        (v == null || v.length < 6)
                                            ? '6 caractères min.'
                                            : null,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed:
                                      () => showPasswordForgetDialog(context),
                                  child: const Text(
                                    'Mot de passe oublié ?',
                                    style: TextStyle(
                                      color: AppColors.accentGreen,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: BlocBuilder<AuthBloc, AuthState>(
                                  builder: (_, state) {
                                    final inProgress =
                                        state is AuthLoadInProgress ||
                                        state is AuthUserLoadInProgress;
                                    return ElevatedButton(
                                      onPressed: inProgress ? null : _onSubmit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.accentGreen,
                                        shape: const StadiumBorder(),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                      ),
                                      child:
                                          inProgress
                                              ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                              : const Text(
                                                'Se connecter',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: -40,
                  right: -60,
                  child: Image.asset(
                    'assets/images/olive.png',
                    width: screenWidth * 0.3,
                  ),
                ),
                Positioned(
                  bottom: -90,
                  left: 0,
                  right: 0,
                  child: const FooterWidget(),
                ),
                if (isMobile)
                  Positioned(
                    top: -logoHeight / 2,
                    child: Image.asset(
                      'assets/images/WhatsApp.png',
                      height: logoHeight,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }
}