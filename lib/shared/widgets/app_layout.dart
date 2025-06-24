import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:oilab_frontend/features/notifications/presentation/screens/notifications_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';
import 'sidebar.dart';
import 'footer_widget.dart';
import 'header_widget.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final String? userName;
  final VoidCallback? onUserProfileTap;
  final Function(String)? onSearchResult;
  final List<String>? searchData;

  const AppLayout({
    Key? key,
    required this.child,
    this.userName,
    this.onUserProfileTap,
    this.onSearchResult,
    this.searchData,
  }) : super(key: key);

  static const desktopBreakpoint = 800.0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopBreakpoint) {
      return _DesktopScaffold(
        child: child,
        userName: userName,
        onUserProfileTap: onUserProfileTap,
        onSearchResult: onSearchResult,
        searchData: searchData,
      );
    } else {
      return _MobileScaffold(
        child: child,
        onSearchResult: onSearchResult,
        searchData: searchData,
      );
    }
  }
}

// Updated _DesktopScaffold - now uses dynamic header without title parameter
class _DesktopScaffold extends StatelessWidget {
  final Widget child;
  final String? userName;
  final VoidCallback? onUserProfileTap;
  final Function(String)? onSearchResult;
  final List<String>? searchData;

  const _DesktopScaffold({
    required this.child,
    this.userName,
    this.onUserProfileTap,
    this.onSearchResult,
    this.searchData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SizedBox(width: 250, child: Sidebar()),
          Expanded(
            child: Column(
              children: [
                // Dynamic header that automatically detects the route and shows appropriate title
                const AppHeader(showSearch: true),
                Expanded(child: child),
                const FooterWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Updated _MobileScaffold with dynamic title
class _MobileScaffold extends StatelessWidget {
  final Widget child;
  final Function(String)? onSearchResult;
  final List<String>? searchData;

  const _MobileScaffold({
    required this.child,
    this.onSearchResult,
    this.searchData,
  });

  // Map routes to their display titles for mobile
  static const Map<String, String> _routeTitles = {
    '/dashboard': 'Tableau de bord',
    '/employees': 'Employés',
    '/comptables': 'Comptables',
    '/clients': 'Clients',
    '/produits': 'Produits',
    '/factures/client': 'Facture Client',
    '/factures/entreprise': 'Facture d\'Entreprise',
    '/energie': 'Énergie',
    '/notifications': 'Notifications',
    '/parametres': 'Paramètres',
  };

  String _getDynamicTitle(BuildContext context) {
    // Get current route
    final currentRoute = ModalRoute.of(context)?.settings.name;

    // Return the mapped title or default
    return _routeTitles[currentRoute] ?? 'Dashboard';
  }

  @override
  Widget build(BuildContext context) {
    final dynamicTitle = _getDynamicTitle(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        title: Text(dynamicTitle, style: const TextStyle(color: Colors.white)),
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
            onPressed: () {
              showSearch(
                context: context,
                delegate: LiveSearchDelegate(
                  onSearchResult: onSearchResult,
                  customSearchData: searchData,
                ),
              );
            },
          ),
          _MobileNotificationIcon(),
        ],
      ),
      drawer: const Drawer(child: Sidebar()),
      body: child,
      bottomNavigationBar: const FooterWidget(),
    );
  }
}

// Mobile notification icon for AppBar
class _MobileNotificationIcon extends StatelessWidget {
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
              icon: const Icon(Icons.notifications_none, color: Colors.white),
              onPressed: () {
                // Navigate to notifications screen or show modal
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

// Live Search Delegate for Mobile
class LiveSearchDelegate extends SearchDelegate<String> {
  final Function(String)? onSearchResult;
  final List<String>? customSearchData;

  LiveSearchDelegate({this.onSearchResult, this.customSearchData});

  List<String> _searchResults = [];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Start typing to search...'));
    }
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    // Use custom search data if provided, otherwise use mock data
    final searchData =
        customSearchData ??
        [
          'User: John Doe',
          'Project: Mobile App',
          'Document: Requirements.pdf',
          'Task: Update Dashboard',
          'File: config.json',
        ];

    _searchResults =
        searchData
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(_getIconForResult(_searchResults[index])),
          title: Text(_searchResults[index]),
          onTap: () {
            onSearchResult?.call(_searchResults[index]);
            close(context, _searchResults[index]);
          },
        );
      },
    );
  }

  IconData _getIconForResult(String result) {
    if (result.startsWith('User:')) return Icons.person;
    if (result.startsWith('Project:')) return Icons.folder;
    if (result.startsWith('Document:')) return Icons.description;
    if (result.startsWith('Task:')) return Icons.task;
    if (result.startsWith('File:')) return Icons.insert_drive_file;
    return Icons.search;
  }
}
