import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'sidebar.dart';
import 'footer_widget.dart';

/// A responsive layout that shows a sidebar on desktop
/// and a top app bar with drawer on mobile, plus a common footer.
class AppLayout extends StatelessWidget {
  final Widget child;

  const AppLayout({Key? key, required this.child}) : super(key: key);

  static const _desktopBreakpoint = 800.0;

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get a true screen width
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= _desktopBreakpoint) {
      return _DesktopScaffold(child: child);
    } else {
      return _MobileScaffold(child: child);
    }
  }
}

/// Desktop scaffold with persistent sidebar and footer
class _DesktopScaffold extends StatelessWidget {
  final Widget child;
  const _DesktopScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(children: [const Sidebar(), Expanded(child: child)]),
          ),
          const FooterWidget(),
        ],
      ),
    );
  }
}

/// Mobile scaffold with drawer and footer
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
          builder:
              (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const Drawer(child: Sidebar()),
      body: child,
      bottomNavigationBar: const FooterWidget(),
    );
  }
}
