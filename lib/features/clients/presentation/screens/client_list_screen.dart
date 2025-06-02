import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/core/constants/app_colors.dart';
import 'package:oilab_frontend/features/clients/presentation/screens/client_profile_screen.dart';
import 'package:oilab_frontend/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:oilab_frontend/features/clients/presentation/bloc/client_bloc.dart';
import 'package:oilab_frontend/features/clients/presentation/bloc/client_event.dart';
import 'package:oilab_frontend/features/clients/presentation/bloc/client_state.dart';
import 'package:oilab_frontend/features/clients/presentation/screens/client_add_dialog.dart';
import 'package:oilab_frontend/features/clients/presentation/screens/client_update_dialog.dart';
import 'package:oilab_frontend/shared/widgets/app_layout.dart';

class ClientListScreen extends StatelessWidget {
  const ClientListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _ClientListView();
  }
}

class _ClientListView extends StatefulWidget {
  const _ClientListView({Key? key}) : super(key: key);

  @override
  __ClientListViewState createState() => __ClientListViewState();
}

class __ClientListViewState extends State<_ClientListView> {
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ClientBloc>().add(LoadClients());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (!mounted) return;
    setState(() => _currentSearchQuery = query);

    final event = query.isEmpty ? LoadClients() : SearchClients(query: query);
    context.read<ClientBloc>().add(event);
  }

  void _changePage(int page) {
    if (!mounted) return;
    context.read<ClientBloc>().add(
      ChangePage(
        page,
        currentSearchQuery:
            _currentSearchQuery.isEmpty ? null : _currentSearchQuery,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          return Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Column(
              children: [
                _AppBar(isMobile: isMobile),
                SizedBox(height: isMobile ? 12 : 16),
                _SearchSection(
                  controller: _searchController,
                  onSearch: _performSearch,
                  currentQuery: _currentSearchQuery,
                  isMobile: isMobile,
                ),
                SizedBox(height: isMobile ? 16 : 24),
                Expanded(child: _ClientContent(isMobile: isMobile)),
                _PaginationFooter(
                  isMobile: isMobile,
                  onPageChange: _changePage,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  final bool isMobile;

  const _AppBar({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!isMobile) ...[
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 28),
            onPressed:
                () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            'Clients',
            style: TextStyle(
              fontSize: isMobile ? 20 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _SearchSection extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final String currentQuery;
  final bool isMobile;

  const _SearchSection({
    required this.controller,
    required this.onSearch,
    required this.currentQuery,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final searchField = TextField(
      controller: controller,
      onChanged: (value) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (controller.text == value) onSearch(value.trim());
        });
      },
      onSubmitted: (value) => onSearch(value.trim()),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Rechercher par CIN',
        prefixIcon: const Icon(Icons.search),
        suffixIcon:
            currentQuery.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    onSearch('');
                  },
                )
                : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    final addButton = SizedBox(
      height: 36,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          iconColor: Colors.white,
          backgroundColor: AppColors.accentGreen,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed:
            () => showDialog(
              context: context,
              builder: (context) => const ClientAddDialog(),
            ),
        icon: Image.asset('assets/icons/Vector.png', width: 14, height: 14),
        label: const Text(
          'Ajouter un nouveau',
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    );

    final statusIndicators = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 4),
        const Text('Actif', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 16),
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 4),
        const Text('Inactif', style: TextStyle(fontSize: 12)),
      ],
    );

    return isMobile
        ? Column(
          children: [
            searchField,
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [statusIndicators, addButton],
            ),
          ],
        )
        : Row(
          children: [
            Expanded(flex: 3, child: searchField),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                addButton,
                const SizedBox(height: 8),
                statusIndicators,
              ],
            ),
          ],
        );
  }
}

class _ClientContent extends StatelessWidget {
  final bool isMobile;

  const _ClientContent({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientBloc, ClientState>(
      builder: (context, state) {
        if (state is ClientInitial || state is ClientLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ClientLoadSuccess) {
          return state.clients.isEmpty
              ? const _EmptyState()
              : _ClientTable(clients: state.clients, isMobile: isMobile);
        }

        if (state is ClientOperationFailure) {
          return _ErrorState(message: state.message);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Aucun client trouvé',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Erreur: $message',
            style: TextStyle(fontSize: 16, color: Colors.red.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<ClientBloc>().add(LoadClients()),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

class _ClientTable extends StatelessWidget {
  final List<dynamic> clients;
  final bool isMobile;

  const _ClientTable({required this.clients, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: isMobile ? 10 : 56.0,
          horizontalMargin: isMobile ? 8 : 24,
          columns: [
            const DataColumn(label: Text('Nom')),
            const DataColumn(label: Text('Tél')),
            if (!isMobile) const DataColumn(label: Text('Email')),
            const DataColumn(label: Text('CIN')),
            const DataColumn(label: Text('Statut')),
            const DataColumn(label: Text('Action')),
          ],
          rows:
              clients
                  .map(
                    (client) => DataRow(
                      cells: [
                        DataCell(
                          Text(client.name, overflow: TextOverflow.ellipsis),
                        ),
                        DataCell(
                          Text(
                            client.tel ?? '',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isMobile)
                          DataCell(
                            Text(client.email, overflow: TextOverflow.ellipsis),
                          ),
                        DataCell(
                          Text(client.cin, overflow: TextOverflow.ellipsis),
                        ),
                        DataCell(
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  client.isActive ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                        DataCell(
                          _ActionButtons(client: client, isMobile: isMobile),
                        ),
                      ],
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final dynamic client;
  final bool isMobile;

  const _ActionButtons({required this.client, this.isMobile = false});

  void _confirmDisactivation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la disactivation de comptes'),
            content: const Text(
              'Êtes-vous sûr de vouloir disactiver ce client?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  context.read<ClientBloc>().add(DisactivateClient(client.id));
                  Navigator.pop(context);
                },
                child: const Text('Disactiver'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = isMobile ? 20.0 : 24.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit, color: Colors.green, size: iconSize),
          onPressed:
              () => showDialog(
                context: context,
                builder: (context) => ClientUpdateDialog(clientId: client.id),
              ),
        ),
        if (!isMobile) ...[
          const SizedBox(width: 5),
          Text('|', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(width: 5),
        ],
        IconButton(
          icon: Image.asset(
            'assets/icons/Disactivate.png',
            width: 16,
            height: 16,
          ),
          onPressed: () => _confirmDisactivation(context),
        ),
        if (!isMobile) ...[
          const SizedBox(width: 5),
          Text('|', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(width: 5),
        ],
        IconButton(
          icon: Image.asset('assets/icons/View.png', width: 16, height: 16),
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ClientProfileScreen(clientId: client.id),
                ),
              ),
        ),
      ],
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  final bool isMobile;
  final Function(int) onPageChange;

  const _PaginationFooter({required this.isMobile, required this.onPageChange});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientBloc, ClientState>(
      builder: (context, state) {
        if (state is! ClientLoadSuccess || state.totalPages <= 1) {
          return const SizedBox.shrink();
        }

        final startItem = (state.currentPage - 1) * state.pageSize + 1;
        final endItem = (state.currentPage * state.pageSize).clamp(
          0,
          state.totalClients,
        );

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child:
              isMobile
                  ? Column(
                    children: [
                      Text(
                        'Page ${state.currentPage} sur ${state.totalPages}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      _PaginationControls(
                        state: state,
                        onPageChange: onPageChange,
                      ),
                    ],
                  )
                  : Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Affichage $startItem à $endItem sur ${state.totalClients} clients',
                          style: TextStyle(
                            color: AppColors.parametereColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      _PaginationControls(
                        state: state,
                        onPageChange: onPageChange,
                      ),
                    ],
                  ),
        );
      },
    );
  }
}

class _PaginationControls extends StatelessWidget {
  final ClientLoadSuccess state;
  final Function(int) onPageChange;

  const _PaginationControls({required this.state, required this.onPageChange});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed:
              state.currentPage > 1
                  ? () => onPageChange(state.currentPage - 1)
                  : null,
          icon: const Icon(Icons.chevron_left),
        ),
        ...List.generate((state.totalPages).clamp(0, 5), (index) {
          final pageNum = index + 1;
          final isActive = pageNum == state.currentPage;

          return GestureDetector(
            onTap: () => onPageChange(pageNum),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? AppColors.mainColor : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border:
                    !isActive ? Border.all(color: Colors.grey.shade300) : null,
              ),
              child: Text(
                '$pageNum',
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.textColor,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
        IconButton(
          onPressed:
              state.currentPage < state.totalPages
                  ? () => onPageChange(state.currentPage + 1)
                  : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
