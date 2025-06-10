import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    // Load factures when the screen initializes
    context.read<FactureBloc>().add(LoadFactures());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<FactureBloc>().add(SearchFactures(query));
  }

  void _onFilterByStatus(String? status) {
    setState(() {
      _selectedStatusFilter = status;
    });
    context.read<FactureBloc>().add(FilterFacturesByStatus(status));
  }

  void _onRefresh() {
    context.read<FactureBloc>().add(RefreshFactures());
  }

  void _changePage(int page) {
    final bloc = context.read<FactureBloc>();
    final currentState = bloc.state;
    
    if (currentState is FactureLoaded && page == currentState.currentPage) return;
    // Prevent multiple rapid taps by disabling the button if already loading
    if (bloc.state is FactureLoading) return;
    bloc.add(LoadFacturesPage(page));
  }

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

  void _viewFacture(Facture facture) {
    Navigator.of(context).pushNamed(
      '/factures/detail',
      arguments: {
        'factureId': facture.id,
        'facture': facture,
        'pdfUrl': facture.pdfUrl,
      },
    );
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
                    _onFilterByStatus(value);
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
                    _onFilterByStatus(value);
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
                    _onFilterByStatus(value);
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
    });
    context.read<FactureBloc>().add(SearchFactures(''));
    context.read<FactureBloc>().add(FilterFacturesByStatus(null));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return AppLayout(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const DashboardScreen(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Factures',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _onRefresh,
                  tooltip: 'Actualiser',
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () {},
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Search and filter row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Recherche par ID, client, montant ou statut',
                      isDense: true,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearch('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: _onSearch,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: _selectedStatusFilter != null
                        ? AppColors.accentGreen
                        : null,
                  ),
                  onPressed: _showFilterDialog,
                ),
                if (_selectedStatusFilter != null || _searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear_all),
                    onPressed: _clearFilters,
                    tooltip: 'Effacer les filtres',
                  ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/factures/upload');
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Ajouter une facture',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Legend
            Row(
              children: const [
                LegendDot(color: Colors.green, label: 'Payé'),
                SizedBox(width: 16),
                LegendDot(color: Colors.red, label: 'Non payé'),
              ],
            ),

            const SizedBox(height: 16),

            // Facture table with BLoC
            Expanded(
              child: BlocConsumer<FactureBloc, FactureState>(
                listener: (context, state) {
                  if (state is FactureError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                        action: SnackBarAction(
                          label: 'Réessayer',
                          onPressed: () => context.read<FactureBloc>().add(
                            LoadFactures(),
                          ),
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
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Chargement des factures...'),
                        ],
                      ),
                    );
                  } else if (state is FactureLoaded) {
                    // Use factures directly since filtering is done server-side
                    final displayFactures = state.factures;
                    
                    if (displayFactures.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune facture trouvée',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            if (state.currentSearch?.isNotEmpty == true || 
                                state.currentFilter != null) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _clearFilters,
                                child: const Text('Effacer les filtres'),
                              ),
                            ],
                          ],
                        ),
                      );
                    }
                    
                    return Column(
                      children: [
                        // Results summary
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Text(
                                'Affichage de ${displayFactures.length} sur ${state.totalCount} factures',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              if (state.currentSearch?.isNotEmpty == true) ...[
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text('Recherche: "${state.currentSearch}"'),
                                  onDeleted: () {
                                    _searchController.clear();
                                    _onSearch('');
                                  },
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                ),
                              ],
                              if (state.currentFilter != null) ...[
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text('Statut: ${_getStatusText(state.currentFilter!)}'),
                                  onDeleted: () => _onFilterByStatus(null),
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async => _onRefresh(),
                            child: isMobile
                                ? _buildMobileTable(displayFactures)
                                : _buildDesktopTable(displayFactures),
                          ),
                        ),
                        _PaginationFooter(
                          state: state,
                          onPageChange: _changePage,
                          isMobile: isMobile,
                        ),
                      ],
                    );
                  } else if (state is FactureDeleting) {
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
                  } else if (state is FactureError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Erreur lors du chargement',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => context.read<FactureBloc>().add(
                              LoadFactures(),
                            ),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const Center(child: Text('État inattendu'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTable(List<Facture> factures) {
    return SingleChildScrollView(
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2), // Client
          1: FlexColumnWidth(1), // Price
          2: FlexColumnWidth(1), // Status
          3: FixedColumnWidth(50), // Actions
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey[100]),
            children: const [
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Client',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Prix',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Statut',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              TableCell(child: SizedBox(width: 50)),
            ],
          ),
          ...factures.map((facture) {
            return TableRow(
              children: [
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          facture.clientName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          _formatDate(facture.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${facture.finalTotal} DT'),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 4,
                          backgroundColor: _getStatusColor(
                            facture.paymentStatus,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusText(facture.paymentStatus),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                TableCell(
                  child: IconButton(
                    icon: const Icon(
                      Icons.remove_red_eye,
                      size: 20,
                      color: Colors.blue,
                    ),
                    onPressed: () => _viewFacture(facture),
                  ),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(List<Facture> factures) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 1100),
        child: DataTable(
          columnSpacing: 48,
          headingRowHeight: 48,
          dataRowHeight: 64,
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Numéro')),
            DataColumn(label: Text('Client')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Prix Total')),
            DataColumn(label: Text('Statut')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Actions')),
          ],
          rows: factures.map((facture) {
            return DataRow(
              cells: [
                DataCell(Text(facture.id.toString())),
                DataCell(Text(facture.factureNumber)),
                DataCell(Text(facture.clientName)),
                DataCell(Text(facture.clientEmail)),
                DataCell(Text('${facture.finalTotal} DT')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 6,
                        backgroundColor: _getStatusColor(
                          facture.paymentStatus,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(_getStatusText(facture.paymentStatus)),
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
                      Text(
                        'Échéance: TVA (${facture.tvaRate}%)',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.remove_red_eye,
                          color: Colors.blue,
                          size: 20,
                        ),
                        onPressed: () => _viewFacture(facture),
                        tooltip: 'Voir',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  final FactureLoaded state;
  final Function(int) onPageChange;
  final bool isMobile;

  const _PaginationFooter({
    required this.state,
    required this.onPageChange,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    if (state.totalPages <= 1) return const SizedBox.shrink();
    
    // Assume pageSize of 10 if not available in state
    final pageSize = 10; // You might want to get this from state if available
    final startItem = (state.currentPage - 1) * pageSize + 1;
    final endItem = (state.currentPage * pageSize).clamp(0, state.totalCount);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: isMobile
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
                    'Affichage $startItem à $endItem sur ${state.totalCount} factures',
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
  }
}

class _PaginationControls extends StatelessWidget {
  final FactureLoaded state;
  final Function(int) onPageChange;

  const _PaginationControls({
    required this.state,
    required this.onPageChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: state.currentPage > 1
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
                border: !isActive
                    ? Border.all(color: Colors.grey.shade300)
                    : null,
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
          onPressed: state.currentPage < state.totalPages
              ? () => onPageChange(state.currentPage + 1)
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
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
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}