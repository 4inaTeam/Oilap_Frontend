import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/features/notifications/presentation/bloc/notification_event.dart';
import 'package:oilab_frontend/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:oilab_frontend/features/notifications/presentation/screens/notifications_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';
import 'sidebar.dart';
import 'footer_widget.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  const AppLayout({Key? key, required this.child}) : super(key: key);

  static const desktopBreakpoint = 800.0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopBreakpoint) {
      return _DesktopScaffold(child: child);
    } else {
      return _MobileScaffold(child: child);
    }
  }
}

class _DesktopScaffold extends StatelessWidget {
  final Widget child;
  const _DesktopScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SizedBox(width: 250, child: Sidebar()),
          Expanded(
            child: Column(
              children: [
                _DesktopHeader(),
                Expanded(child: child), 
                const FooterWidget()
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
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
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.search, size: 24),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            _NotificationButton(),
            const SizedBox(width: 16),
            // User profile section
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.mainColor,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'User',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileScaffold extends StatelessWidget {
  final Widget child;
  const _MobileScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          _NotificationButton(isWhite: true),
        ],
      ),
      drawer: const Drawer(child: Sidebar()),
      body: child, 
      bottomNavigationBar: const FooterWidget(),
    );
  }
}

class _NotificationButton extends StatefulWidget {
  final bool isWhite;
  
  const _NotificationButton({this.isWhite = false});

  @override
  State<_NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<_NotificationButton> {
  @override
  void initState() {
    super.initState();
    // Load notifications when the button is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NotificationBloc>().add(LoadUnreadCount());
      }
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

        return Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_none,
                color: widget.isWhite ? Colors.white : Colors.grey.shade700,
                size: 24,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
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
        );
      },
    );
  }
}

// Notification Badge Widget for reuse
class NotificationBadge extends StatelessWidget {
  final int count;
  final Widget child;
  
  const NotificationBadge({
    Key? key,
    required this.count,
    required this.child,
  }) : super(key: key);

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
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
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