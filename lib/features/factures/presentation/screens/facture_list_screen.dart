import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/shared/widgets/app_layout.dart';
import 'package:oilab_frontend/core/constants/app_colors.dart';
import 'package:oilab_frontend/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:oilab_frontend/features/factures/presentation/bloc/facture_bloc.dart';
import 'package:oilab_frontend/features/factures/presentation/bloc/facture_event.dart';
import 'package:oilab_frontend/features/factures/presentation/bloc/facture_state.dart';
import 'package:oilab_frontend/core/models/facture_model.dart';

class FactureListScreen extends StatefulWidget {
  const FactureListScreen({Key? key}) : super(key: key);

  @override
  State<FactureListScreen> createState() => _FactureListScreenState();
}

class _FactureListScreenState extends State<FactureListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatusFilter;
  String _currentSearchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<FactureBloc>().add(LoadFactures());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _currentSearchQuery = query);
        context.read<FactureBloc>().add(SearchFactures(query));
      }
    });
  }

  void _onFilterByStatus(String? status) {
    setState(() {
      _selectedStatusFilter = status;
    });
    context.read<FactureBloc>().add(FilterFacturesByStatus(status));
  }


  void _changePage(int page) {
    final bloc = context.read<FactureBloc>();
    final currentState = bloc.state;

    if (currentState is FactureLoaded) {
      // Validate page number
      if (page < 1 || page > currentState.totalPages) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Page $page n\'existe pas'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      // Prevent unnecessary API calls for the same page
      if (page == currentState.currentPage) {
        return;
      }

      bloc.add(
        ChangePage(
          page,
          currentSearchQuery: currentState.currentSearch,
          statusFilter: currentState.currentFilter,
        ),
      );
    }
  }





  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filtrer par statut'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Tous'),
                leading: Radio<String?>(
                  value: null,
                  groupValue: _selectedStatusFilter,
                  onChanged: (value) {
                    Navigator.of(context).pop();
                    _onFilterByStatus(null);
                  },
                ),
              ),
              ListTile(
                title: const Text('Payé'),
                leading: Radio<String?>(
                  value: 'paid',
                  groupValue: _selectedStatusFilter,
                  onChanged: (value) {
                    Navigator.of(context).pop();
                    _onFilterByStatus('paid');
                  },
                ),
              ),
              ListTile(
                title: const Text('Non payé'),
                leading: Radio<String?>(
                  value: 'unpaid',
                  groupValue: _selectedStatusFilter,
                  onChanged: (value) {
                    Navigator.of(context).pop();
                    _onFilterByStatus('unpaid');
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatusFilter = null;
      _currentSearchQuery = '';
    });
    context.read<FactureBloc>().add(SearchFactures(''));
    context.read<FactureBloc>().add(FilterFacturesByStatus(null));
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
                  onSearch: _onSearch,
                  currentQuery: _currentSearchQuery,
                  selectedFilter: _selectedStatusFilter,
                  onFilter: _showFilterDialog,
                  onClearFilters: _clearFilters,
                  isMobile: isMobile,
                ),
                SizedBox(height: isMobile ? 16 : 24),
                // Legend
                const _StatusLegend(),
                const SizedBox(height: 16),
                Expanded(child: _FactureContent(isMobile: isMobile)),
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
            'Factures',
            style: TextStyle(
              fontSize: isMobile ? 20 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => context.read<FactureBloc>().add(RefreshFactures()),
          tooltip: 'Actualiser',
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
  final String? selectedFilter;
  final VoidCallback onFilter;
  final VoidCallback onClearFilters;
  final bool isMobile;

  const _SearchSection({
    required this.controller,
    required this.onSearch,
    required this.currentQuery,
    required this.selectedFilter,
    required this.onFilter,
    required this.onClearFilters,
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
        hintText: 'Recherche par ID, client, montant ou statut',
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

    final filterButton = IconButton(
      icon: Icon(
        Icons.filter_list,
        color: selectedFilter != null ? AppColors.accentGreen : null,
      ),
      onPressed: onFilter,
      tooltip: 'Filtrer',
    );

    final clearButton =
        selectedFilter != null || currentQuery.isNotEmpty
            ? IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: onClearFilters,
              tooltip: 'Effacer les filtres',
            )
            : null;

    return isMobile
        ? Column(
          children: [
            searchField,
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [filterButton, if (clearButton != null) clearButton],
            ),
          ],
        )
        : Row(
          children: [
            Expanded(flex: 3, child: searchField),
            const SizedBox(width: 8),
            filterButton,
            if (clearButton != null) clearButton,
          ],
        );
  }
}

class _StatusLegend extends StatelessWidget {
  const _StatusLegend();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        LegendDot(color: Colors.green, label: 'Payé'),
        SizedBox(width: 16),
        LegendDot(color: Colors.red, label: 'Non payé'),
      ],
    );
  }
}

class _FactureContent extends StatelessWidget {
  final bool isMobile;

  const _FactureContent({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FactureBloc, FactureState>(
      listener: (context, state) {
        if (state is FactureError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Réessayer',
                onPressed:
                    () => context.read<FactureBloc>().add(LoadFactures()),
              ),
            ),
          );
        } else if (state is FactureDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Facture supprimée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is FactureLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is FactureLoaded) {
          return state.factures.isEmpty
              ? const _EmptyState()
              : _FactureTable(factures: state.factures, isMobile: isMobile);
        }

        if (state is FactureDeleting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Suppression en cours...'),
              ],
            ),
          );
        }

        if (state is FactureError) {
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
          Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Aucune facture trouvée',
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
            onPressed: () => context.read<FactureBloc>().add(LoadFactures()),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

class _FactureTable extends StatelessWidget {
  final List<Facture> factures;
  final bool isMobile;

  const _FactureTable({required this.factures, required this.isMobile});

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'payé':
        return Colors.green;
      case 'unpaid':
      case 'non payé':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String paymentStatus) {
    switch (paymentStatus.toLowerCase()) {
      case 'paid':
        return 'Payé';
      case 'unpaid':
        return 'Non payé';
      default:
        return paymentStatus;
    }
  }


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox.expand(
          child: RefreshIndicator(
            onRefresh:
                () async => context.read<FactureBloc>().add(RefreshFactures()),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    columnSpacing: isMobile ? 10 : 56.0,
                    horizontalMargin: isMobile ? 8 : 24,
                    columns: [
                      DataColumn(
                        label: Text(
                          'ID',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (!isMobile)
                        DataColumn(
                          label: Text(
                            'Numéro',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      DataColumn(
                        label: Text(
                          'Client',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (!isMobile)
                        DataColumn(
                          label: Text(
                            'Email',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      DataColumn(
                        label: Text(
                          'Prix Total',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Statut',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Actions',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows:
                        factures.map((facture) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  facture.id.toString(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!isMobile)
                                DataCell(
                                  Text(
                                    facture.factureNumber,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              DataCell(
                                Text(
                                  facture.clientName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!isMobile)
                                DataCell(
                                  Text(
                                    facture.clientEmail,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              DataCell(
                                Text(
                                  '${facture.finalTotal} DT',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _getStatusColor(
                                          facture.paymentStatus,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getStatusText(facture.paymentStatus),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _formatDate(facture.createdAt),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    if (!isMobile)
                                      Text(
                                        'TVA (${facture.tvaRate}%)',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              DataCell(
                                _ActionButtons(
                                  facture: facture,
                                  isMobile: isMobile,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final Facture facture;
  final bool isMobile;

  const _ActionButtons({required this.facture, this.isMobile = false});

  void _viewFacture(BuildContext context, Facture facture) {
    Navigator.of(context).pushNamed(
      '/factures/client/detail',
      arguments: {
        'factureId': facture.id,
        'facture': facture,
        'pdfUrl': facture.pdfUrl,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = isMobile ? 16.0 : 24.0;

    if (isMobile) {
      return PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, size: iconSize),
        onSelected: (value) {
          if (value == 'view') {
            _viewFacture(context, facture);
          }
        },
        itemBuilder:
            (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.remove_red_eye, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text('Voir'),
                  ],
                ),
              ),
            ],
      );
    }

    return IconButton(
      icon: Icon(Icons.remove_red_eye, color: Colors.blue, size: iconSize),
      onPressed: () => _viewFacture(context, facture),
      tooltip: 'Voir',
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  final bool isMobile;
  final Function(int) onPageChange;

  const _PaginationFooter({required this.isMobile, required this.onPageChange});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FactureBloc, FactureState>(
      builder: (context, state) {
        if (state is! FactureLoaded || state.totalPages <= 1) {
          return const SizedBox.shrink();
        }

        final startItem = (state.currentPage - 1) * 6 + 1;
        final endItem = math.min(
          startItem + state.factures.length - 1,
          state.totalCount,
        );

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isMobile
                          ? 'Page ${state.currentPage} sur ${state.totalPages}'
                          : 'Affichage de $startItem à $endItem sur ${state.totalCount} factures',
                      style: TextStyle(
                        color: AppColors.parametereColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      size: 16,
                      color: AppColors.parametereColor,
                    ),
                    onPressed:
                        () =>
                            context.read<FactureBloc>().add(RefreshFactures()),
                    tooltip: 'Actualiser',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _PaginationControls(state: state, onPageChange: onPageChange),
            ],
          ),
        );
      },
    );
  }
}

class _PaginationControls extends StatelessWidget {
  final FactureLoaded state;
  final Function(int) onPageChange;

  const _PaginationControls({required this.state, required this.onPageChange});

  @override
  Widget build(BuildContext context) {
    // Don't show pagination if there's only one page or no pages
    if (state.totalPages <= 1) {
      return const SizedBox.shrink();
    }

    int startPage = 1;
    int endPage = state.totalPages;

    // Logic for showing page numbers (show max 5 pages at a time)
    if (state.totalPages > 5) {
      if (state.currentPage <= 3) {
        // Show first 5 pages
        endPage = 5;
      } else if (state.currentPage >= state.totalPages - 2) {
        // Show last 5 pages
        startPage = state.totalPages - 4;
      } else {
        // Show current page in the middle
        startPage = state.currentPage - 2;
        endPage = state.currentPage + 2;
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Previous button
          IconButton(
            onPressed:
                state.currentPage > 1
                    ? () => onPageChange(state.currentPage - 1)
                    : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Page précédente',
          ),

          // First page + ellipsis if needed
          if (startPage > 1) ...[
            _PageButton(
              pageNumber: 1,
              isActive: state.currentPage == 1,
              onTap: () => onPageChange(1),
            ),
            if (startPage > 2) ...[
              const SizedBox(width: 4),
              const Text('...', style: TextStyle(color: Colors.grey)),
              const SizedBox(width: 4),
            ],
          ],

          // Page number buttons
          ...List.generate(endPage - startPage + 1, (index) {
            final pageNum = startPage + index;
            return _PageButton(
              pageNumber: pageNum,
              isActive: pageNum == state.currentPage,
              onTap: () => onPageChange(pageNum),
            );
          }),

          // Last page + ellipsis if needed
          if (endPage < state.totalPages) ...[
            if (endPage < state.totalPages - 1) ...[
              const SizedBox(width: 4),
              const Text('...', style: TextStyle(color: Colors.grey)),
              const SizedBox(width: 4),
            ],
            _PageButton(
              pageNumber: state.totalPages,
              isActive: state.currentPage == state.totalPages,
              onTap: () => onPageChange(state.totalPages),
            ),
          ],

          // Next button
          IconButton(
            onPressed:
                state.currentPage < state.totalPages
                    ? () => onPageChange(state.currentPage + 1)
                    : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Page suivante',
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final int pageNumber;
  final bool isActive;
  final VoidCallback onTap;

  const _PageButton({
    required this.pageNumber,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? AppColors.mainColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: !isActive ? Border.all(color: Colors.grey.shade300) : null,
        ),
        child: Text(
          '$pageNumber',
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textColor,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const LegendDot({required this.color, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
