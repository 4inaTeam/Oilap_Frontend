import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/data/auth_repository.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({Key? key}) : super(key: key);

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  String? _selectedRoute;
  bool _isFacturesExpanded = false;

  static const _allItems = [
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
    {
      'label': 'Notifications',
      'icon': Icons.notifications,
      'route': '/notifications',
    },
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
        setState(() {
          _selectedRoute = currentRoute;
          if (currentRoute.startsWith('/factures/')) {
            _isFacturesExpanded = true;
          }
        });
      }

      final authBloc = context.read<AuthBloc>();
      final currentState = authBloc.state;

      if (currentState is AuthLoadSuccess &&
          currentState is! AuthUserLoadSuccess) {
        authBloc.add(AuthUserRequested());
      }
    });
  }

  List<Map<String, dynamic>> _getOrganizedItems() {
    final String? role = AuthRepository.currentRole;

    bool isAdmin = role == 'ADMIN';
    bool isEmployee = role == 'EMPLOYEE';
    bool isAccountant = role == 'ACCOUNTANT';
    bool isClient = role == 'CLIENT';

    List<Map<String, dynamic>> organizedItems = [];

    // Always add dashboard first
    if (isAdmin || isEmployee || isAccountant || isClient) {
      organizedItems.add(
        _allItems.firstWhere((item) => item['route'] == '/dashboard'),
      );
    }

    // Define the order: employees, comptables, clients, produits, notifications, energie, parametres
    final itemsOrder = [
      '/employees',
      '/comptables',
      '/clients',
      '/produits',
      '/notifications',
      '/energie',
      '/parametres', // Paramètres will be last
    ];

    for (String route in itemsOrder) {
      bool hasAccess = false;

      switch (route) {
        case '/employees':
          hasAccess = isAdmin;
          break;
        case '/comptables':
          hasAccess = isAdmin;
          break;
        case '/clients':
          hasAccess = isAdmin || isEmployee;
          break;
        case '/produits':
          hasAccess = isAdmin || isEmployee || isClient; // Accountant removed
          break;
        case '/energie':
          hasAccess = isAdmin;
          break;
        case '/notifications':
          hasAccess = isClient;
          break;
        case '/parametres':
          hasAccess = isAdmin || isEmployee || isAccountant || isClient;
          break;
      }

      if (hasAccess) {
        final item = _allItems.firstWhere((item) => item['route'] == route);
        organizedItems.add(item);
      }
    }

    return organizedItems;
  }

  bool _hasFacturesAccess() {
    final String? role = AuthRepository.currentRole;
    bool isAdmin = role == 'ADMIN';
    bool isAccountant = role == 'ACCOUNTANT';
    bool isClient = role == 'CLIENT';

    return isAdmin || isAccountant || isClient;
  }

  void _onItemTap(String route) {
    if (_selectedRoute == route) return;
    setState(() => _selectedRoute = route);
    Navigator.of(context).pushNamed(route).then((_) {
      setState(() => _selectedRoute = route);
    });
  }

  void _toggleFacturesDropdown() {
    setState(() {
      _isFacturesExpanded = !_isFacturesExpanded;
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

  Widget _buildFacturesSection() {
    final String? role = AuthRepository.currentRole;
    bool isClient = role == 'CLIENT';

    if (isClient) {
      // For clients, show a direct menu item that goes to client factures
      return _SidebarItem(
        label: 'Factures',
        icon: Icons.receipt,
        route: '/factures/client',
        selectedRoute: _selectedRoute,
        onTap: () => _onItemTap('/factures/client'),
      );
    } else {
      // For admin and accountant, show dropdown
      return _FacturesDropdown(
        isExpanded: _isFacturesExpanded,
        selectedRoute: _selectedRoute,
        onToggle: _toggleFacturesDropdown,
        onItemTap: _onItemTap,
      );
    }
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

        // Get organized items based on current user role
        final organizedItems = _getOrganizedItems();
        final hasFacturesAccess = _hasFacturesAccess();

        // Separate items to place Factures and Paramètres in correct order
        final List<Widget> menuItems = [];

        // Add all items except Energie and Paramètres first
        for (var item in organizedItems) {
          if (item['route'] != '/energie' && item['route'] != '/parametres') {
            menuItems.add(
              _SidebarItem(
                label: item['label'] as String,
                icon: item['icon'] as IconData,
                route: item['route'] as String,
                selectedRoute: _selectedRoute,
                onTap: () => _onItemTap(item['route'] as String),
              ),
            );
          }
        }

        // Add Factures section if user has access (after other items, before Energie)
        if (hasFacturesAccess) {
          menuItems.add(_buildFacturesSection());
        }

        // Add Energie if user has access
        final energieItem =
            organizedItems
                .where((item) => item['route'] == '/energie')
                .firstOrNull;
        if (energieItem != null) {
          menuItems.add(
            _SidebarItem(
              label: energieItem['label'] as String,
              icon: energieItem['icon'] as IconData,
              route: energieItem['route'] as String,
              selectedRoute: _selectedRoute,
              onTap: () => _onItemTap(energieItem['route'] as String),
            ),
          );
        }

        // Add Paramètres last if user has access
        final parametresItem =
            organizedItems
                .where((item) => item['route'] == '/parametres')
                .firstOrNull;
        if (parametresItem != null) {
          menuItems.add(
            _SidebarItem(
              label: parametresItem['label'] as String,
              icon: parametresItem['icon'] as IconData,
              route: parametresItem['route'] as String,
              selectedRoute: _selectedRoute,
              onTap: () => _onItemTap(parametresItem['route'] as String),
            ),
          );
        }

        return Container(
          width: 260,
          color: AppColors.mainColor,
          child: SafeArea(
            child: Column(
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
                        ...menuItems,
                        const SizedBox(height: 16),
                        const _LogoutButton(),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
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
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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

class _FacturesDropdown extends StatelessWidget {
  final bool isExpanded;
  final String? selectedRoute;
  final VoidCallback onToggle;
  final Function(String) onItemTap;

  const _FacturesDropdown({
    Key? key,
    required this.isExpanded,
    required this.selectedRoute,
    required this.onToggle,
    required this.onItemTap,
  }) : super(key: key);

  static const _factureItems = [
    {'label': 'Facture Client', 'route': '/factures/client'},
    {'label': 'Facture d\'Entreprise', 'route': '/factures/entreprise'},
  ];

  List<Map<String, String>> _getFilteredFactureItems() {
    final String? role = AuthRepository.currentRole;
    bool isClient = role == 'CLIENT';

    if (isClient) {
      // Clients can only access 'Facture Client'
      return _factureItems
          .where((item) => item['route'] == '/factures/client')
          .toList();
    } else {
      // Admin and Accountant can access both
      return _factureItems;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSelectedFacture = selectedRoute?.startsWith('/factures/') ?? false;
    final filteredItems = _getFilteredFactureItems();

    return Column(
      children: [
        // Main Factures item
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color:
                hasSelectedFacture
                    ? AppColors.accentGreen.withOpacity(0.2)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(8),
            child: ListTile(
              leading: Icon(
                Icons.receipt,
                color:
                    hasSelectedFacture ? AppColors.accentGreen : Colors.white70,
                size: 24,
              ),
              title: Text(
                'Factures',
                style: TextStyle(
                  color:
                      hasSelectedFacture ? AppColors.accentGreen : Colors.white,
                  fontWeight:
                      hasSelectedFacture ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              trailing: AnimatedRotation(
                turns: isExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color:
                      hasSelectedFacture
                          ? AppColors.accentGreen
                          : Colors.white70,
                ),
              ),
            ),
          ),
        ),

        // Dropdown items with proper overflow handling
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                filteredItems
                    .map(
                      (item) => _FactureSubItem(
                        label: item['label'] as String,
                        route: item['route'] as String,
                        selectedRoute: selectedRoute,
                        onTap: () => onItemTap(item['route'] as String),
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }
}

class _FactureSubItem extends StatelessWidget {
  final String label;
  final String route;
  final String? selectedRoute;
  final VoidCallback onTap;

  const _FactureSubItem({
    Key? key,
    required this.label,
    required this.route,
    required this.selectedRoute,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected = route == selectedRoute;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
      decoration: BoxDecoration(
        color:
            isSelected
                ? AppColors.accentGreen.withOpacity(0.3)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              const SizedBox(width: 32),
              Icon(
                Icons.arrow_right,
                color: isSelected ? AppColors.accentGreen : Colors.white60,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? AppColors.accentGreen : Colors.white70,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
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
