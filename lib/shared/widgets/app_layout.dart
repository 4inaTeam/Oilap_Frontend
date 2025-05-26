import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
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
      body: SafeArea(
        child: Row(
          children: [
            const SizedBox(width: 250, child: Sidebar()),
            Expanded(
              child: Column(
                children: [Expanded(child: child), const FooterWidget()],
              ),
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
      body: SafeArea(child: child),
      bottomNavigationBar: const FooterWidget(),
    );
  }
}
