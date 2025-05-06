import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: AppColors.mainColor,
      child: Column(
        children: [
          const SizedBox(height: 40),
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 44, color: AppColors.mainColor),
          ),
          const SizedBox(height: 12),
          Text(
            'Owner_Name',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32),

          ...[
            {'label': 'Employés', 'icon': Icons.group, 'route': '/employees'},
            {
              'label': 'Comptables',
              'icon': Icons.account_balance,
              'route': '/comptables',
            },
            {'label': 'Clients', 'icon': Icons.people, 'route': '/clients'},
            {
              'label': 'Produits',
              'icon': Icons.shopping_bag,
              'route': '/produits',
            },
            {'label': 'Factures', 'icon': Icons.receipt, 'route': '/factures'},
            {'label': 'Énergie', 'icon': Icons.bolt, 'route': null},
            {
              'label': 'Paramètres',
              'icon': Icons.settings,
              'route': '/parametres',
            },
          ].map((item) {
            return SidebarItem(
              label: item['label'] as String,
              icon: item['icon'] as IconData,
              routeName: item['route'] as String?,
            );
          }).toList(),

          const Spacer(),
          const LogoutButton(),
          const SizedBox(height: 16),

          // Bottom image
          Image.asset(
            'assets/images/image118.png',
            fit: BoxFit.contain,
            height: 120,
          ),
        ],
      ),
    );
  }
}

class SidebarItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? routeName;

  const SidebarItem({
    required this.label,
    required this.icon,
    this.routeName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          routeName != null
              ? () {
                Navigator.of(context).pushNamed(routeName!);
              }
              : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushReplacementNamed('/signin');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.logout, color: Colors.white),
            const SizedBox(width: 12),
            const Text(
              'Déconnexion',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
