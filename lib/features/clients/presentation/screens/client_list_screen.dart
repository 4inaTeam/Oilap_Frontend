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
    context.read<ClientBloc>().add(LoadClients());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      _currentSearchQuery = query;
    });

    if (query.isEmpty) {
      context.read<ClientBloc>().add(LoadClients());
    } else {
      context.read<ClientBloc>().add(SearchClients(query: query));
    }
  }

  void _changePage(int page) {
    context.read<ClientBloc>().add(
      ChangePage(
        page,
        currentSearchQuery:
            _currentSearchQuery.isEmpty ? null : _currentSearchQuery,
      ),
    );
  }


  void _refreshClientList() {
    if (_currentSearchQuery.isEmpty) {
      context.read<ClientBloc>().add(LoadClients());
    } else {
      context.read<ClientBloc>().add(SearchClients(query: _currentSearchQuery));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return AppLayout(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAppBar(isMobile, context),
            const SizedBox(height: 16),
            _buildSearchAndAddButton(isMobile),
            const SizedBox(height: 24),
            _buildClientTable(),
            const SizedBox(height: 16),
            _buildPaginationFooter(),
          ],
        ),
      ),
    );
  }

  void _confirmDisactivate(int userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              context.read<ClientBloc>().add(DisactivateClient(userId));
              Navigator.pop(context);
            },
            child: const Text('Disactiver'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isMobile, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!isMobile)
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 28),
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            ),
          ),
        if (!isMobile) const SizedBox(width: 8),
        const Text(
          'Clients',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSearchAndAddButton(bool isMobile) {
    return Flex(
      direction: isMobile ? Axis.vertical : Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_searchController.text == value) {
                  _performSearch(value.trim());
                }
              });
            },
            onSubmitted: (value) => _performSearch(value.trim()),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Rechercher par CIN',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _currentSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        if (!isMobile) const SizedBox(width: 16),
        if (isMobile) const SizedBox(height: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            iconColor: Colors.white,
            backgroundColor: AppColors.accentGreen,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () async {
            // Wait for the dialog to close and refresh if needed
            final result = await showDialog(
              context: context,
              builder: (context) => const ClientAddDialog(),
            );
            // If a client was added, refresh the list
            if (result == true) {
              _refreshClientList();
            }
          },
          icon: Image.asset('assets/icons/Vector.png', width: 16, height: 16),
          label: const Text(
            'Ajouter un nouveau',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildClientTable() {
    return Expanded(
      child: BlocBuilder<ClientBloc, ClientState>(
        builder: (ctx, state) {
          if (state is ClientInitial || state is ClientLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ClientLoadSuccess) {
            if (state.clients.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _currentSearchQuery.isEmpty
                          ? 'Aucun client trouvé'
                          : 'Aucun client trouvé pour "${_currentSearchQuery}"',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth,
                      minHeight: 100,
                    ),
                    child: DataTable(
                      columnSpacing: 20,
                      columns: const [
                        DataColumn(label: Text('Nom du client')),
                        DataColumn(label: Text('Numéro de téléphone')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('CIN')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: state.clients
                          .map(
                            (u) => DataRow(
                              cells: [
                                DataCell(Text(u.name)),
                                DataCell(Text(u.tel ?? '')),
                                DataCell(Text(u.email)),
                                DataCell(Text(u.cin)),
                                DataCell(
                                  Text(
                                    u.isActive == true ? 'Actif' : 'Inactif',
                                  ),
                                ),
                                DataCell(_buildActionButtons(u.id)),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              },
            );
          }
          if (state is ClientOperationFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur: ${state.message}',
                    style: TextStyle(fontSize: 16, color: Colors.red.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ClientBloc>().add(LoadClients());
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildActionButtons(int userId) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.green),
          onPressed: () async {
            // Wait for the dialog to close and refresh if needed
            final result = await showDialog(
              context: context,
              builder: (context) => ClientUpdateDialog(clientId: userId),
            );
            // If client was updated, refresh the list
            if (result == true) {
              _refreshClientList();
            }
          },
        ),
        const SizedBox(width: 5),
        Text('|', style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(width: 5),
        IconButton(
          icon: Image.asset(
            'assets/icons/Disactivate.png',
            width: 16,
            height: 16,
          ),
          onPressed: () => _confirmDisactivate(userId),
        ),
        const SizedBox(width: 5),
        Text('|', style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(width: 5),
        IconButton(
          icon: Image.asset('assets/icons/View.png', width: 16, height: 16),
          onPressed: () async {
            // Navigate to ClientProfileScreen and wait for return
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ClientProfileScreen(clientId: userId),
              ),
            );
            // Refresh the client list when returning from profile screen
            _refreshClientList();
          },
        ),
      ],
    );
  }

  Widget _buildPaginationFooter() {
    return BlocBuilder<ClientBloc, ClientState>(
      builder: (context, state) {
        if (state is! ClientLoadSuccess) {
          return const SizedBox.shrink();
        }

        final startItem = (state.currentPage - 1) * state.pageSize + 1;
        final endItem =
            (state.currentPage * state.pageSize) > state.totalClients
                ? state.totalClients
                : state.currentPage * state.pageSize;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  state.totalClients > 0
                      ? 'Affichage des données $startItem à $endItem sur ${state.totalClients} clients'
                      : 'Aucun client trouvé',
                  style: TextStyle(
                    color: AppColors.parametereColor,
                    fontSize: 12,
                  ),
                ),
              ),
              if (state.totalPages > 1) _buildPaginationControls(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaginationControls(ClientLoadSuccess state) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed:
              state.currentPage > 1
                  ? () => _changePage(state.currentPage - 1)
                  : null,
          icon: const Icon(Icons.chevron_left),
        ),
        ..._buildPageNumbers(state),
        IconButton(
          onPressed:
              state.currentPage < state.totalPages
                  ? () => _changePage(state.currentPage + 1)
                  : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  List<Widget> _buildPageNumbers(ClientLoadSuccess state) {
    List<Widget> pageNumbers = [];
    int currentPage = state.currentPage;
    int totalPages = state.totalPages;

    if (totalPages > 0) {
      pageNumbers.add(
        _PageNumber(1, isActive: currentPage == 1, onTap: () => _changePage(1)),
      );
    }

    if (currentPage > 3) {
      pageNumbers.add(
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('…', style: TextStyle(fontSize: 16)),
        ),
      );
    }

    int start = (currentPage - 1).clamp(2, totalPages);
    int end = (currentPage + 1).clamp(2, totalPages);

    for (int i = start; i <= end; i++) {
      if (i != 1 && i != totalPages) {
        pageNumbers.add(
          _PageNumber(
            i,
            isActive: currentPage == i,
            onTap: () => _changePage(i),
          ),
        );
      }
    }

    if (currentPage < totalPages - 2) {
      pageNumbers.add(
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('…', style: TextStyle(fontSize: 16)),
        ),
      );
    }

    if (totalPages > 1) {
      pageNumbers.add(
        _PageNumber(
          totalPages,
          isActive: currentPage == totalPages,
          onTap: () => _changePage(totalPages),
        ),
      );
    }

    return pageNumbers;
  }
}

class _PageNumber extends StatelessWidget {
  final int number;
  final bool isActive;
  final VoidCallback? onTap;

  const _PageNumber(this.number, {this.isActive = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? AppColors.mainColor : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: !isActive ? Border.all(color: Colors.grey.shade300) : null,
        ),
        child: Text(
          '$number',
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textColor,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}