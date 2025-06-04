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

  void _viewFacture(Facture facture) {
    Navigator.of(context).pushNamed('/factures/detail', arguments: facture);
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'unpaid':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Payé';
      case 'unpaid':
        return 'Non payé';
      default:
        return status;
    }
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
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed:
                      () => Navigator.of(context).pushReplacement(
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: _onSearch,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterDialog,
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
                  } else if (state is FactureLoaded) {
                    if (state.filteredFactures.isEmpty) {
                      return const Center(
                        child: Text(
                          'Aucune facture trouvée',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    return isMobile
                        ? SingleChildScrollView(
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(2), // Client
                              1: FlexColumnWidth(1), // Price
                              2: FlexColumnWidth(1), // Status
                              3: FixedColumnWidth(50), // Actions
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                ),
                                children: const [
                                  TableCell(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Client',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Prix',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Statut',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(child: SizedBox(width: 50)),
                                ],
                              ),
                              ...state.filteredFactures.map((facture) {
                                return TableRow(
                                  children: [
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              facture.client,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              _formatDate(facture.issueDate),
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
                                        child: Text(
                                          '${facture.totalAmount} DT',
                                        ),
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
                                                facture.status,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _getStatusText(facture.status),
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
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
                        )
                        : SingleChildScrollView(
                          child: DataTable(
                            columnSpacing: 24,
                            headingRowHeight: 40,
                            dataRowHeight: 56,
                            columns: const [
                              DataColumn(label: Text('ID')),
                              DataColumn(label: Text('Client')),
                              DataColumn(label: Text('Prix Total')),
                              DataColumn(label: Text('Statut')),
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows:
                                state.filteredFactures.map((facture) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(facture.id.toString())),
                                      DataCell(Text(facture.client)),
                                      DataCell(
                                        Text('${facture.totalAmount} DT'),
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircleAvatar(
                                              radius: 6,
                                              backgroundColor: _getStatusColor(
                                                facture.status,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _getStatusText(facture.status),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _formatDate(facture.issueDate),
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                              Text(
                                                'Échéance: ${_formatDate(facture.dueDate)}',
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
                                              onPressed:
                                                  () => _viewFacture(facture),
                                              tooltip: 'Voir',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                          ),
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
                  } else {
                    return const Center(
                      child: Text('Erreur lors du chargement des factures'),
                    );
                  }
                },
              ),
            ),
          ],
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
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
