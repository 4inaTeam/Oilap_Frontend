import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/core/constants/app_colors.dart';
import 'package:oilab_frontend/features/clients/presentation/screens/client_profile_screen.dart';
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

class __ClientListViewState extends State<_ClientListView>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = '';
  late FocusNode _focusNode;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ClientBloc>().add(LoadClients());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  void _refreshData() {
    if (!mounted || _isRefreshing) return;
    _isRefreshing = true;

    Future.microtask(() {
      final event =
          _currentSearchQuery.isEmpty
              ? LoadClients()
              : SearchClients(query: _currentSearchQuery);
      context.read<ClientBloc>().add(event);
      _isRefreshing = false;
    });
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
      currentRoute: '/clients',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          return Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Column(
              children: [
                SizedBox(height: isMobile ? 12 : 16),
                _SearchSection(
                  controller: _searchController,
                  onSearch: _performSearch,
                  currentQuery: _currentSearchQuery,
                  isMobile: isMobile,
                ),
                SizedBox(height: isMobile ? 16 : 24),
                Expanded(
                  child: _ClientContent(
                    isMobile: isMobile,
                    onRefresh: _refreshData,
                  ),
                ),
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
      width: isMobile ? double.infinity : null,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          iconColor: Colors.white,
          backgroundColor: AppColors.accentGreen,
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 14 : 12,
            horizontal: 16,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed:
            () => showDialog(
              context: context,
              builder: (context) => const ClientAddDialog(),
            ),
        icon: Image.asset('assets/icons/Vector.png', width: 16, height: 16),
        label: const Text(
          'Ajouter un nouveau',
          style: TextStyle(color: Colors.white),
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
            addButton,
            const SizedBox(height: 12),
            statusIndicators,
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
  final VoidCallback onRefresh;

  const _ClientContent({required this.isMobile, required this.onRefresh});

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
              : _ClientTable(
                clients: state.clients,
                isMobile: isMobile,
                onRefresh: onRefresh,
              );
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
  final VoidCallback onRefresh;

  const _ClientTable({
    required this.clients,
    required this.isMobile,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      // Mobile-optimized table with selective columns
      return _buildMobileTable(context);
    } else {
      // Desktop table with all columns
      return _buildDesktopTable(context);
    }
  }

  Widget _buildMobileTable(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                maxWidth:
                    constraints.maxWidth * 1.2, // Allow some horizontal scroll
              ),
              child: DataTable(
                columnSpacing: 12,
                horizontalMargin: 8,
                headingRowHeight: 36,
                dataRowHeight: 48,
                showCheckboxColumn: false,
                columns: const [
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'Nom',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'CIN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'Statut',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'Actions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                rows:
                    clients.map((client) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Tooltip(
                              message: client.name,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: constraints.maxWidth * 0.3,
                                ),
                                child: Text(
                                  client.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth * 0.25,
                              ),
                              child: Text(
                                client.cin,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                          DataCell(_buildStatusChip(client.isActive, true)),
                          DataCell(
                            _CompactMobileActionButtons(
                              client: client,
                              onRefresh: onRefresh,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox.expand(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  columnSpacing: 56.0,
                  horizontalMargin: 24,
                  headingRowHeight: 60,
                  dataRowHeight: 60,
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Nom',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Tél',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Email',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'CIN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Statut',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Action',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                  rows:
                      clients.map((client) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                client.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            DataCell(
                              Text(
                                client.tel ?? '',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            DataCell(
                              Text(
                                client.email,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            DataCell(
                              Text(
                                client.cin,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            DataCell(_buildStatusChip(client.isActive, false)),
                            DataCell(
                              _ActionButtons(
                                client: client,
                                isMobile: false,
                                onRefresh: onRefresh,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(bool isActive, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 6 : 8,
        vertical: isMobile ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color:
            isActive
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.green : Colors.red,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isMobile ? 4 : 6,
            height: isMobile ? 4 : 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.green : Colors.red,
            ),
          ),
          SizedBox(width: isMobile ? 3 : 4),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: isMobile ? 9 : 12,
              color: isActive ? Colors.green[700] : Colors.red[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactMobileActionButtons extends StatelessWidget {
  final dynamic client;
  final VoidCallback onRefresh;

  const _CompactMobileActionButtons({
    required this.client,
    required this.onRefresh,
  });

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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap:
              () => showDialog(
                context: context,
                builder: (context) => ClientUpdateDialog(clientId: client.id),
              ).then((_) {
                onRefresh();
              }),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.all(6),
            child: const Icon(Icons.edit, color: Colors.green, size: 16),
          ),
        ),
        const SizedBox(width: 4),
        InkWell(
          onTap: () => _confirmDisactivation(context),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.all(6),
            child: Image.asset(
              'assets/icons/Disactivate.png',
              width: 14,
              height: 14,
            ),
          ),
        ),
        const SizedBox(width: 4),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ClientProfileScreen(clientId: client.id),
                maintainState: false,
              ),
            ).then(
              (_) =>
                  Future.delayed(const Duration(milliseconds: 100), onRefresh),
            );
          },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.all(6),
            child: Image.asset('assets/icons/View.png', width: 14, height: 14),
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final dynamic client;
  final bool isMobile;
  final VoidCallback onRefresh;

  const _ActionButtons({
    required this.client,
    this.isMobile = false,
    required this.onRefresh,
  });

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
          constraints:
              isMobile
                  ? const BoxConstraints(minWidth: 32, minHeight: 32)
                  : const BoxConstraints(minWidth: 48, minHeight: 48),
          padding: isMobile ? const EdgeInsets.all(4) : const EdgeInsets.all(8),
          icon: Icon(Icons.edit, color: Colors.green, size: iconSize),
          onPressed:
              () => showDialog(
                context: context,
                builder: (context) => ClientUpdateDialog(clientId: client.id),
              ).then((_) {
                onRefresh();
              }),
        ),
        if (!isMobile) ...[
          const SizedBox(width: 5),
          Text('|', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(width: 5),
        ],
        IconButton(
          constraints:
              isMobile
                  ? const BoxConstraints(minWidth: 32, minHeight: 32)
                  : const BoxConstraints(minWidth: 48, minHeight: 48),
          padding: isMobile ? const EdgeInsets.all(4) : const EdgeInsets.all(8),
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
          constraints:
              isMobile
                  ? const BoxConstraints(minWidth: 32, minHeight: 32)
                  : const BoxConstraints(minWidth: 48, minHeight: 48),
          padding: isMobile ? const EdgeInsets.all(4) : const EdgeInsets.all(8),
          icon: Image.asset('assets/icons/View.png', width: 16, height: 16),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ClientProfileScreen(clientId: client.id),
                maintainState: false,
              ),
            ).then(
              (_) =>
                  Future.delayed(const Duration(milliseconds: 100), onRefresh),
            );
          },
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
                        isMobile: true,
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
                        isMobile: false,
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
  final bool isMobile;

  const _PaginationControls({
    required this.state,
    required this.onPageChange,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final maxPages = isMobile ? 3 : 5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed:
              state.currentPage > 1
                  ? () => onPageChange(state.currentPage - 1)
                  : null,
          icon: const Icon(Icons.chevron_left),
          iconSize: isMobile ? 20 : 24,
        ),
        ...List.generate((state.totalPages).clamp(0, maxPages), (index) {
          final pageNum = index + 1;
          final isActive = pageNum == state.currentPage;

          return GestureDetector(
            onTap: () => onPageChange(pageNum),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: isMobile ? 2 : 4),
              width: isMobile ? 28 : 32,
              height: isMobile ? 28 : 32,
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
                  fontSize: isMobile ? 11 : 14,
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
          iconSize: isMobile ? 20 : 24,
        ),
      ],
    );
  }
}
