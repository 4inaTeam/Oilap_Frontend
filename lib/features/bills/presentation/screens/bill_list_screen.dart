import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/core/constants/app_colors.dart';
import 'package:oilab_frontend/core/models/bill_model.dart';
import 'package:oilab_frontend/features/bills/presentation/bloc/bill_bloc.dart';
import 'package:oilab_frontend/features/bills/presentation/bloc/bill_event.dart';
import 'package:oilab_frontend/features/bills/presentation/bloc/bill_state.dart';
import 'package:oilab_frontend/features/bills/presentation/screens/Bill_update_dialog.dart';
import 'package:oilab_frontend/features/bills/presentation/screens/bill_detail_screen.dart';
import 'package:oilab_frontend/features/bills/presentation/screens/bill_upload_screen.dart';
import 'package:oilab_frontend/shared/dialogs/error_dialog.dart';
import 'package:oilab_frontend/shared/dialogs/success_dialog.dart';
import 'package:oilab_frontend/shared/widgets/app_layout.dart';

class BillListScreen extends StatelessWidget {
  const BillListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _BillListView();
  }
}

class _BillListView extends StatefulWidget {
  const _BillListView({Key? key}) : super(key: key);

  @override
  __BillListViewState createState() => __BillListViewState();
}

class __BillListViewState extends State<_BillListView> {
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BillBloc>().add(LoadBills());
      }
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

    if (query.isEmpty) {
      context.read<BillBloc>().add(LoadBills());
    } else {
      context.read<BillBloc>().add(SearchBills(query: query));
    }
  }

  void _changePage(int page) {
    if (!mounted) return;
    context.read<BillBloc>().add(ChangePage(page));
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: "/factures/entreprise",
      child: Column(
        children: [
          Expanded(
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
                      Expanded(child: _BillContent(isMobile: isMobile)),
                      _PaginationFooter(
                        isMobile: isMobile,
                        onPageChange: _changePage,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
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
        // Debounce search to avoid too many API calls
        Future.delayed(const Duration(milliseconds: 500), () {
          if (controller.text == value) onSearch(value.trim());
        });
      },
      onSubmitted: (value) => onSearch(value.trim()),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Rechercher par propriétaire ou catégorie',
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
              builder: (context) => FactureUploadScreen(),
            ),
        icon: Image.asset('assets/icons/Vector.png', width: 16, height: 16),
        label: const Text(
          'Ajouter une nouvelle',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

    return isMobile
        ? Column(children: [searchField, const SizedBox(height: 12), addButton])
        : Row(
          children: [
            Expanded(flex: 3, child: searchField),
            const SizedBox(width: 16),
            addButton,
          ],
        );
  }
}

class _BillContent extends StatelessWidget {
  final bool isMobile;

  const _BillContent({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BillBloc, BillState>(
      listener: (context, state) {
        // Handle success/error states with dialogs
        if (state is BillCreateSuccess) {
          showDialog(
            context: context,
            builder:
                (context) => const SuccessDialog(
                  title: 'Succès',
                  message: 'La facture a été créée avec succès',
                ),
          );
        } else if (state is BillUpdateSuccess) {
          showDialog(
            context: context,
            builder:
                (context) => const SuccessDialog(
                  title: 'Succès',
                  message: 'La facture a été mise à jour avec succès',
                ),
          );
        } else if (state is BillOperationFailure) {
          showDialog(
            context: context,
            builder:
                (context) =>
                    ErrorDialog(title: 'Erreur', message: state.message),
          );
        }
      },
      builder: (context, state) {
        if (state is BillInitial || state is BillLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is BillLoadSuccess) {
          return state.bills.isEmpty
              ? const _EmptyState()
              : _BillTable(bills: state.bills, isMobile: isMobile);
        }

        if (state is BillOperationFailure) {
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
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
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
            onPressed: () => context.read<BillBloc>().add(LoadBills()),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

class _BillTable extends StatelessWidget {
  final List<Bill> bills;
  final bool isMobile;

  const _BillTable({required this.bills, required this.isMobile});

  // Helper method to translate English categories to French
  String _translateCategory(String category) {
    switch (category.toLowerCase()) {
      case 'water':
        return 'Eau';
      case 'electricity':
        return 'Électricité';
      case 'purchase':
        return 'Achats';
      default:
        return category; // Return original if no match found
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use Card for better visual appearance
        return Card(
          elevation: 1,
          child: SizedBox.expand(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    columnSpacing: isMobile ? 10 : 56.0,
                    horizontalMargin: isMobile ? 8 : 24,
                    headingRowHeight: isMobile ? 48 : 60,
                    dataRowHeight: isMobile ? 48 : 60,
                    columns: const [
                      DataColumn(
                        label: Text(
                          'ID',
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
                          'Propriétaire',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Montant',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Catégorie',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Action',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows:
                        bills.map((bill) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  bill.id?.toString() ?? 'N/A',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DataCell(
                                Text(
                                  _formatDate(bill.paymentDate),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DataCell(
                                Text(
                                  bill.owner,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${bill.amount.toStringAsFixed(2)} TND',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(bill.category),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _translateCategory(bill.category),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                _ActionButtons(bill: bill, isMobile: isMobile),
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'electricity':
      case 'électricité':
        return Colors.amber;
      case 'water':
      case 'eau':
        return Colors.blue;
      case 'purchase':
      case 'achats':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

class _ActionButtons extends StatelessWidget {
  final Bill bill;
  final bool isMobile;

  const _ActionButtons({required this.bill, this.isMobile = false});

  void _navigateToBillDetail(BuildContext context) {
    // Get the image URL from the bill (updated to use correct field)
    String? imageUrl = _getImageUrl();

    // If no image URL is available, show a message
    if (imageUrl == null || imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune image disponible pour cette facture'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => BillDetailScreen(
              imageUrl: imageUrl,
              bill: bill, // Pass the entire bill object
              billTitle: 'Facture ${bill.owner}',
              billId: bill.id,
            ),
        maintainState: false,
      ),
    ).then((_) => Future.delayed(const Duration(milliseconds: 100)));
  }

  // Helper method to get the correct image URL
  String? _getImageUrl() {
    // Check for originalImage field first (as used in detail screen)
    if (bill.originalImage != null && bill.originalImage!.isNotEmpty) {
      // If the URL is already absolute, return it
      if (bill.originalImage!.startsWith('http')) {
        return bill.originalImage;
      }
      // If it's relative, make it absolute (adjust base URL as needed)
      return 'http://localhost:8000${bill.originalImage}';
    }

    // Fallback to pdfUrl if originalImage is not available
    if (bill.pdfUrl != null && bill.pdfUrl!.isNotEmpty) {
      if (bill.pdfUrl!.startsWith('http')) {
        return bill.pdfUrl;
      }
      return 'http://localhost:8000${bill.pdfUrl}';
    }

    // Fallback to fullPdfUrl
    if (bill.fullPdfUrl != null && bill.fullPdfUrl!.isNotEmpty) {
      return bill.fullPdfUrl;
    }

    return null;
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
                builder: (context) => BillUpdateDialog(bill: bill),
              ),
          tooltip: 'Modifier',
        ),
        if (!isMobile) ...[
          const SizedBox(width: 5),
          Text('|', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(width: 5),
        ],
        IconButton(
          icon: Image.asset('assets/icons/View.png', width: 16, height: 16),
          onPressed: () => _navigateToBillDetail(context),
          tooltip: 'Voir les détails',
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
    return BlocBuilder<BillBloc, BillState>(
      builder: (context, state) {
        if (state is BillLoadSuccess && state.bills.isNotEmpty) {
          // You can implement pagination logic here based on your BillBloc state
          // For now, returning a simple placeholder
          return const SizedBox(height: 20);
        }
        return const SizedBox.shrink();
      },
    );
  }
}
