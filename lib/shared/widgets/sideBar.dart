import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({Key? key}) : super(key: key);

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  String? _selectedRoute;

  static const _items = [
    {
      'label': 'Tableau de bord',
      'icon': Icons.dashboard,
      'route': '/dashboard',
    },
    {'label': 'Employés', 'icon': Icons.group, 'route': '/employees'},
    {
      'label': 'Comptables',
      'icon': Icons.account_balance,
      'route': '/comptables',
    },
    {'label': 'Clients', 'icon': Icons.people, 'route': '/clients'},
    {'label': 'Produits', 'icon': Icons.shopping_bag, 'route': '/produits'},
    {'label': 'Factures', 'icon': Icons.receipt, 'route': '/factures'},
    {'label': 'Énergie', 'icon': Icons.bolt, 'route': '/energie'},
    {'label': 'Paramètres', 'icon': Icons.settings, 'route': '/parametres'},
  ];

  static const String baseUrl =
      kIsWeb ? 'http://localhost:8000' : 'http://192.168.100.8:8000';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentRoute = ModalRoute.of(context)?.settings.name;
      if (currentRoute != null) {
        setState(() => _selectedRoute = currentRoute);
      }

      final authBloc = context.read<AuthBloc>();
      final currentState = authBloc.state;

      if (currentState is AuthLoadSuccess &&
          currentState is! AuthUserLoadSuccess) {
        authBloc.add(AuthUserRequested());
      }
    });
  }

  void _onItemTap(String route) {
    if (_selectedRoute == route) return;
    setState(() => _selectedRoute = route);
    Navigator.of(context).pushNamed(route).then((_) {
      setState(() => _selectedRoute = route);
    });
  }

  String? _getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return null;

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    if (imageUrl.startsWith('/')) {
      return '$baseUrl$imageUrl';
    }

    return '$baseUrl/$imageUrl';
  }

  Widget _buildProfileAvatar(String? profileImageUrl) {
    final fullImageUrl = _getFullImageUrl(profileImageUrl);

    if (fullImageUrl == null) {
      return const CircleAvatar(
        radius: 36,
        backgroundColor: Colors.white,
        child: Icon(Icons.person, size: 44, color: AppColors.mainColor),
      );
    }

    return CircleAvatar(
      radius: 36,
      backgroundColor: Colors.white,
      child: ClipOval(
        child: Image.network(
          fullImageUrl,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.person,
              size: 44,
              color: AppColors.mainColor,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const CircularProgressIndicator(
              color: AppColors.mainColor,
              strokeWidth: 2,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        late final Widget avatar;
        late final Widget header;

        if (state is AuthUserLoadSuccess) {
          avatar = _buildProfileAvatar(state.user.profilePhotoUrl);
          header = Text(
            state.user.name.isNotEmpty ? state.user.name : 'Utilisateur',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          );
        } else if (state is AuthUserLoadFailure) {
          avatar = const CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 44, color: AppColors.mainColor),
          );
          header = Column(
            children: [
              const Text('Erreur', style: TextStyle(color: Colors.white)),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(AuthUserRequested());
                },
                child: const Text(
                  'Réessayer',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          );
        } else if (state is AuthLoggedOut) {
          // User has been logged out (possibly due to token issues)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/signin');
            }
          });
          avatar = const CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 44, color: AppColors.mainColor),
          );
          header = const Text(
            'Déconnecté',
            style: TextStyle(color: Colors.white),
          );
        } else if (state is AuthLoadSuccess) {
          // Authenticated but user data not loaded yet
          avatar = const CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            child: CircularProgressIndicator(
              color: AppColors.mainColor,
              strokeWidth: 2,
            ),
          );
          header = const SizedBox(
            width: 100,
            height: 24,
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          );

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.read<AuthBloc>().add(AuthUserRequested());
            }
          });
        } else {
          avatar = const CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 44, color: AppColors.mainColor),
          );
          header = const Text(
            'Non connecté',
            style: TextStyle(color: Colors.white),
          );
        }

        return Container(
          width: 260,
          color: AppColors.mainColor,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    const SizedBox(height: 40),
                    avatar,
                    const SizedBox(height: 12),
                    header,
                    const SizedBox(height: 32),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ..._items.map(
                              (item) => _SidebarItem(
                                label: item['label'] as String,
                                icon: item['icon'] as IconData,
                                route: item['route'] as String,
                                selectedRoute: _selectedRoute,
                                onTap:
                                    () => _onItemTap(item['route'] as String),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const _LogoutButton(),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Image.asset(
                                      'assets/images/image118.png',
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final String route;
  final String? selectedRoute;
  final VoidCallback onTap;

  const _SidebarItem({
    Key? key,
    required this.label,
    required this.icon,
    required this.route,
    required this.selectedRoute,
    required this.onTap,
  }) : super(key: key);

  static const IconData energySavingsLeaf = IconData(
    0xf07a0,
    fontFamily: 'MaterialIcons',
  );

  @override
  Widget build(BuildContext context) {
    final isSelected = route == selectedRoute;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color:
            isSelected
                ? AppColors.accentGreen.withOpacity(0.2)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? AppColors.accentGreen : Colors.white70,
            size: 24,
          ),
          title: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.accentGreen : Colors.white,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          trailing: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween(begin: 0, end: isSelected ? 1.0 : 0.0),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 2 * 3.14159,
                child: Icon(
                  isSelected ? energySavingsLeaf : Icons.chevron_right,
                  key: ValueKey(isSelected ? 'leaf' : 'chevron'),
                  color: isSelected ? AppColors.accentGreen : Colors.white70,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const ImageIcon(
          AssetImage("assets/icons/logout_account_exit_door.png"),
          color: Colors.white,
        ),
        label: const Text(
          'Déconnexion',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        onPressed: () {
          context.read<AuthBloc>().add(AuthLogoutRequested());
          Navigator.of(context).pushReplacementNamed('/signin');
        },
      ),
    );
  }
}
