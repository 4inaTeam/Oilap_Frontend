import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';


class IconToggleButton extends StatefulWidget {
  const IconToggleButton({super.key});

  @override
  State<IconToggleButton> createState() => _IconToggleButtonState();
}

class _IconToggleButtonState extends State<IconToggleButton> {
  bool _isClicked = false;
  IconData _buttonIcon = Icons.favorite_border;
  final String _buttonText = "Favoris";

  void _toggleIcon() {
    setState(() {
      _isClicked = !_isClicked;
      _buttonIcon = _isClicked ? Icons.favorite : Icons.favorite_border;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: _toggleIcon,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          foregroundColor: AppColors.mainColor,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_buttonIcon),
            const SizedBox(width: 8),
            Text(_buttonText),
          ],
        ),
      ),
    );
  }
}

class Sidebar extends StatefulWidget {
  const Sidebar({Key? key}) : super(key: key);

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  String? _selectedRoute;

  static const _items = [
    {'label': 'Tableau de bord', 'icon': Icons.dashboard, 'route': '/dashboard'},
    {'label': 'Employés',        'icon': Icons.group,     'route': '/employees'},
    {'label': 'Comptables',      'icon': Icons.account_balance, 'route': '/comptables'},
    {'label': 'Clients',         'icon': Icons.people,    'route': '/clients'},
    {'label': 'Produits',        'icon': Icons.shopping_bag, 'route': '/produits'},
    {'label': 'Factures',        'icon': Icons.receipt,   'route': '/factures'},
    {'label': 'Énergie',         'icon': Icons.bolt,      'route': '/energie'},
    {'label': 'Paramètres',      'icon': Icons.settings,  'route': '/parametres'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = ModalRoute.of(context)?.settings.name;
      if (current != null) setState(() => _selectedRoute = current);
      final bloc = context.read<AuthBloc>();
      if (bloc.state is! AuthUserLoadSuccess) bloc.add(AuthUserRequested());
    });
  }

  bool _isSelected(String route) => _selectedRoute == route;

  void _onItemTap(String route) {
    if (_selectedRoute == route) return;
    setState(() => _selectedRoute = route);
    Navigator.of(context).pushNamed(route).then((_) {
      setState(() => _selectedRoute = route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        Widget header, avatar;
        if (state is AuthUserLoadSuccess) {
          header = Text(
            state.username,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          );
          avatar = CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            backgroundImage: state.profileImageUrl != null ? NetworkImage(state.profileImageUrl!) : null,
            child: state.profileImageUrl == null
                ? const Icon(Icons.person, size: 44, color: AppColors.mainColor)
                : null,
          );
        } else if (state is AuthUserLoadFailure) {
          header = const Text('Erreur', style: TextStyle(color: Colors.white));
          avatar = const CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 44, color: AppColors.mainColor),
          );
        } else {
          header = const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          );
          avatar = const CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            child: CircularProgressIndicator(color: AppColors.mainColor, strokeWidth: 2),
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
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      // Navigation items
                      for (var item in _items)
                        _SidebarItem(
                          label:      item['label'] as String,
                          icon:       item['icon']  as IconData,
                          isSelected: _isSelected(item['route'] as String),
                          onTap:      () => _onItemTap(item['route'] as String),
                        ),

                      const SizedBox(height: 16),

                      // Your toggle button
                      const IconToggleButton(),

                      const SizedBox(height: 16),

                      // Logout
                      const _LogoutButton(),

                      const SizedBox(height: 16),

                      // Footer image
                      Image.asset('assets/images/image118.png', height: 120, fit: BoxFit.contain),
                    ],
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
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    Key? key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accentGreen.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          leading: Icon(icon, color: isSelected ? AppColors.accentGreen : Colors.white70, size: 24),
          title: Text(label,
            style: TextStyle(
              color: isSelected ? AppColors.accentGreen : Colors.white,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            )
          ),
          trailing: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isSelected
                ? const Icon(Icons.check_circle, key: ValueKey('selected'), color: AppColors.accentGreen)
                : const Icon(Icons.chevron_right, key: ValueKey('unselected'), color: Colors.white70),
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
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text('Déconnexion', style: TextStyle(color: Colors.white, fontSize: 16)),
        onPressed: () {
          context.read<AuthBloc>().add(AuthLogoutRequested());
          Navigator.of(context).pushReplacementNamed('/signin');
        },
      ),
    );
  }
}
