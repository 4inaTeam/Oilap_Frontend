import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/features/auth/data/auth_repository.dart';
import 'package:oilab_frontend/features/notifications/presentation/bloc/notification_event.dart';
import 'package:oilab_frontend/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:oilab_frontend/features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../../core/constants/app_colors.dart';

class AppHeader extends StatelessWidget {
  final String? title;
  final bool showBackArrow;
  final bool showSearch;
  final VoidCallback? onBackPressed;
  final String? currentRoute;

  const AppHeader({
    Key? key,
    this.title,
    this.showBackArrow = false,
    this.showSearch = true,
    this.onBackPressed,
    this.currentRoute,
  }) : super(key: key);

  static const Map<String, String> _routeTitles = {
    '/dashboard': 'Dashboard',
    '/comptableDashboard': 'Dashboard',
    '/employees': 'Employés',
    '/comptables': 'Comptables',
    '/clients': 'Clients',
    '/clients/detail': 'Profile Client',
    '/produits': 'Produits',
    '/produits/detail': 'Détail de Produit',
    '/factures/client': 'Facture Client',
    '/factures/client/detail': 'Détail Facture Client',
    '/factures/entreprise': 'Facture d\'Entreprise',
    '/factures/entreprise/ajouter': 'Ajouter Facture',
    '/factures/entreprise/detail': 'Détail Facture Entreprise',
    '/energie': 'Énergie',
    '/notifications': 'Notifications',
    '/parametres': 'Paramètres',
  };

  // Define navigation hierarchy - Updated to include ajouter route
  static const Map<String, String> _backNavigationMap = {
    '/factures/client/detail': '/factures/client',
    '/factures/entreprise/detail': '/factures/entreprise',
    '/factures/entreprise/ajouter': '/factures/entreprise',
    '/clients/detail': '/clients',
    '/produits/detail': '/produits',
  };

  String _getDynamicTitle(BuildContext context) {
    if (title != null) return title!;

    // Use explicit currentRoute parameter first
    if (currentRoute != null) {
      return _routeTitles[currentRoute] ?? _getDefaultDashboardTitle();
    }

    // Fallback: try multiple methods to get route
    final route = ModalRoute.of(context)?.settings.name;
    print('Current route: $route'); // Debug print

    // If still null, default to appropriate dashboard
    if (route == null) {
      return _getDefaultDashboardTitle();
    }

    return _routeTitles[route] ?? _getDefaultDashboardTitle();
  }

  String _getDefaultDashboardTitle() {
    final String? role = AuthRepository.currentRole;

    if (role == 'ACCOUNTANT') {
      return 'Tableau de bord Comptable';
    } else if (role == 'CLIENT') {
      return 'Produits';
    } else if (role == 'EMPLOYEE') {
      return 'Clients';
    } else {
      return 'Tableau de bord';
    }
  }

  bool _shouldShowBackArrow(BuildContext context) {
    if (showBackArrow) return true;

    if (currentRoute != null) {
      return !_isMainDashboard(currentRoute!);
    }

    final route = ModalRoute.of(context)?.settings.name;

    if (route == null) {
      return false;
    }

    return !_isMainDashboard(route);
  }

  bool _isMainDashboard(String route) {
    final String? role = AuthRepository.currentRole;

    if (role == 'ACCOUNTANT') {
      return route == '/comptableDashboard';
    } else if (role == 'CLIENT') {
      return route == '/produits';
    } else if (role == 'EMPLOYEE') {
      return route == '/clients';
    } else {
      return route == '/dashboard';
    }
  }

  bool _shouldShowSearch(BuildContext context) {
    if (!showSearch) return false;

    if (currentRoute != null) {
      return _isMainDashboard(currentRoute!);
    }

    final route = ModalRoute.of(context)?.settings.name;

    if (route == null) {
      return true; // Default to showing search when route is unknown
    }

    return _isMainDashboard(route);
  }

  bool _shouldShowNotifications() {
    final String? role = AuthRepository.currentRole;
    // Show notifications only to clients
    return role == 'CLIENT';
  }

  void _handleBackPress(BuildContext context) {
    if (onBackPressed != null) {
      onBackPressed!();
      return;
    }

    String? route = currentRoute ?? ModalRoute.of(context)?.settings.name;

    if (route != null && _backNavigationMap.containsKey(route)) {
      String parentRoute = _backNavigationMap[route]!;
      Navigator.pushNamedAndRemoveUntil(context, parentRoute, (route) => false);
    } else {
      final String? role = AuthRepository.currentRole;
      String mainRoute;

      if (role == 'ACCOUNTANT') {
        mainRoute = '/comptableDashboard';
      } else if (role == 'CLIENT') {
        mainRoute = '/produits';
      } else if (role == 'EMPLOYEE') {
        mainRoute = '/clients';
      } else {
        mainRoute = '/dashboard';
      }

      Navigator.pushNamedAndRemoveUntil(context, mainRoute, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dynamicTitle = _getDynamicTitle(context);
    final shouldShowBackArrow = _shouldShowBackArrow(context);
    final shouldShowSearch = _shouldShowSearch(context);
    final shouldShowNotifications = _shouldShowNotifications();

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFFEF7FF),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            if (shouldShowBackArrow)
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _handleBackPress(context),
              ),

            Expanded(
              child: Text(
                dynamicTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),

            if (shouldShowSearch) ...[
              const _SearchBarUI(),
              const SizedBox(width: 16),
            ],

            if (shouldShowNotifications) _NotificationDropdown(),
          ],
        ),
      ),
    );
  }
}

class _SearchBarUI extends StatelessWidget {
  const _SearchBarUI();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Icon(Icons.search, color: Colors.grey.shade600, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            'Search...',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// Enhanced Notification Dropdown
class _NotificationDropdown extends StatefulWidget {
  @override
  State<_NotificationDropdown> createState() => _NotificationDropdownState();
}

class _NotificationDropdownState extends State<_NotificationDropdown> {
  final GlobalKey _key = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NotificationBloc>().add(LoadUnreadCount());
      }
    });
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            left: offset.dx - 300 + size.width,
            top: offset.dy + size.height + 8,
            child: _NotificationDropdownContent(onClose: _closeDropdown),
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        int unreadCount = 0;

        if (state is NotificationLoaded) {
          unreadCount = state.unreadCount;
        }

        return GestureDetector(
          key: _key,
          onTap: _toggleDropdown,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Stack(
              children: [
                Icon(
                  Icons.notifications_none,
                  color: Colors.grey.shade700,
                  size: 24,
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
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

  @override
  void dispose() {
    _closeDropdown();
    super.dispose();
  }
}

class _NotificationDropdownContent extends StatelessWidget {
  final VoidCallback onClose;

  const _NotificationDropdownContent({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 350,
        constraints: const BoxConstraints(maxHeight: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          context.read<NotificationBloc>().add(
                            MarkAllNotificationsAsRead(),
                          );
                        },
                        child: const Text('Mark all read'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: onClose,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Notifications list
            Expanded(
              child: BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  if (state is NotificationLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is NotificationLoaded) {
                    if (state.notifications.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('No notifications'),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: state.notifications.length,
                      itemBuilder: (context, index) {
                        final notification = state.notifications[index];
                        return _NotificationItem(
                          notification: notification,
                          onTap: () {
                            if (!notification.isRead) {
                              context.read<NotificationBloc>().add(
                                MarkNotificationAsRead(notification.id),
                              );
                            }
                            onClose();
                          },
                        );
                      },
                    );
                  }

                  return const Center(
                    child: Text('Error loading notifications'),
                  );
                },
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    onClose();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NotificationScreen(),
                      ),
                    );
                  },
                  child: const Text('See all notifications'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final dynamic notification;
  final VoidCallback onTap;

  const _NotificationItem({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : Colors.blue.shade50,
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.mainColor,
              child: Icon(
                _getNotificationIcon(notification.type),
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title ?? 'Notification',
                    style: TextStyle(
                      fontWeight:
                          notification.isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body ?? '',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(notification.createdAt),
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'message':
        return Icons.message;
      case 'task':
        return Icons.task;
      case 'alert':
        return Icons.warning;
      case 'info':
        return Icons.info;
      case 'general':
        return Icons.notifications;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

// Notification Badge Widget for reuse
class NotificationBadge extends StatelessWidget {
  final int count;
  final Widget child;

  const NotificationBadge({Key? key, required this.count, required this.child})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
