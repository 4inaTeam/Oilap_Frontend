import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({Key? key}) : super(key: key);

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  String? _selectedRoute;

  final _items = [
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

  void _onItemTap(String route) {
    setState(() => _selectedRoute = route);
    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: AppColors.mainColor,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const CircleAvatar(
              radius: 36,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 44, color: AppColors.mainColor),
            ),
            const SizedBox(height: 12),
            const Text(
              'Owner_Name',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),

            // Make the menu scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    ..._items.map((item) {
                      final route = item['route'] as String;
                      final isSelected = route == _selectedRoute;
                      return _SidebarItem(
                        label: item['label'] as String,
                        icon: item['icon'] as IconData,
                        isSelected: isSelected,
                        onTap: () => _onItemTap(route),
                      );
                    }).toList(),

                    const SizedBox(height: 16),
                    const _LogoutButton(),
                    const SizedBox(height: 16),

                    Image.asset(
                      'assets/images/image118.png',
                      fit: BoxFit.contain,
                      height: 120,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
        color:
            isSelected
                ? AppColors.accentGreen.withOpacity(0.2)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.accentGreen : Colors.white70,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.accentGreen : Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder:
              (child, anim) => ScaleTransition(scale: anim, child: child),
          child:
              isSelected
                  ? Image.asset(
                    'assets/icons/mask.png',
                    key: const ValueKey('selected-mask'),
                    width: 24,
                    height: 24,
                    // optional tint: color: AppColors.accentGreen,
                  )
                  : Icon(
                    Icons.chevron_right,
                    key: const ValueKey('default-chevron'),
                    color: Colors.white70,
                  ),
        ),
        onTap: onTap,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.accentGreen,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: const Icon(Icons.logout, color: Colors.white),
          title: const Text(
            'Déconnexion',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          onTap: () => Navigator.of(context).pushReplacementNamed('/signin'),
        ),
      ),
    );
  }
}
