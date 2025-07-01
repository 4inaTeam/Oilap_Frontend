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
  String? _selectedCategory;

  // Available categories for filtering
  final List<Map<String, String>> _categories = [
    {'value': '', 'label': 'Toutes les catégories'},
    {'value': 'water', 'label': 'Eau'},
    {'value': 'electricity', 'label': 'Électricité'},
    {'value': 'purchase', 'label': 'Achats'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BillBloc>().add(LoadBills(pageSize: 10));
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
      context.read<BillBloc>().add(
        LoadBills(
          pageSize: 10,
          categoryFilter:
              _selectedCategory?.isNotEmpty == true ? _selectedCategory : null,
        ),
      );
    } else {
      context.read<BillBloc>().add(
        SearchBills(
          query: query,
          pageSize: 10,
          categoryFilter:
              _selectedCategory?.isNotEmpty == true ? _selectedCategory : null,
        ),
      );
    }
  }

  void _filterByCategory(String? category) {
    if (!mounted) return;
    setState(() => _selectedCategory = category);

    context.read<BillBloc>().add(
      FilterBillsByCategory(
        category: category?.isNotEmpty == true ? category : null,
        pageSize: 10,
        searchQuery:
            _currentSearchQuery.isNotEmpty ? _currentSearchQuery : null,
      ),
    );
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
                      SizedBox(height: isMobile ? 12 : 16),
                      _FilterSection(
                        categories: _categories,
                        selectedCategory: _selectedCategory,
                        onCategoryChanged: _filterByCategory,
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

class _FilterSection extends StatelessWidget {
  final List<Map<String, String>> categories;
  final String? selectedCategory;
  final Function(String?) onCategoryChanged;
  final bool isMobile;

  const _FilterSection({
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_list, size: 20, color: AppColors.mainColor),
                const SizedBox(width: 8),
                Text(
                  'Filtrer par catégorie',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            isMobile ? _buildMobileFilters() : _buildDesktopFilters(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileFilters() {
    return DropdownButtonFormField<String>(
      value: selectedCategory ?? '',
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        isDense: true,
      ),
      items:
          categories.map((category) {
            return DropdownMenuItem<String>(
              value: category['value'],
              child: Text(category['label']!),
            );
          }).toList(),
      onChanged: (value) => onCategoryChanged(value),
    );
  }

  Widget _buildDesktopFilters() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          categories.map((category) {
            final isSelected = selectedCategory == category['value'];
            return FilterChip(
              label: Text(
                category['label']!,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.mainColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onCategoryChanged(category['value']),
              selectedColor: AppColors.mainColor,
              checkmarkColor: Colors.white,
              backgroundColor: Colors.grey.shade100,
              side: BorderSide(
                color: isSelected ? AppColors.mainColor : Colors.grey.shade300,
              ),
            );
          }).toList(),
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
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres ou d\'ajouter une nouvelle facture',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
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
            onPressed:
                () => context.read<BillBloc>().add(LoadBills(pageSize: 10)),
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

  String _translateCategory(String category) {
    switch (category.toLowerCase()) {
      case 'water':
        return 'Eau';
      case 'electricity':
        return 'Électricité';
      case 'purchase':
        return 'Achats';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
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
    String? imageUrl = _getImageUrl();

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
              bill: bill,
              billTitle: 'Facture ${bill.owner}',
              billId: bill.id,
            ),
        maintainState: false,
      ),
    ).then((_) => Future.delayed(const Duration(milliseconds: 100)));
  }

  String? _getImageUrl() {
    if (bill.originalImage != null && bill.originalImage!.isNotEmpty) {
      if (bill.originalImage!.startsWith('http')) {
        return bill.originalImage;
      }
      return 'http://localhost:8000${bill.originalImage}';
    }

    if (bill.pdfUrl != null && bill.pdfUrl!.isNotEmpty) {
      if (bill.pdfUrl!.startsWith('http')) {
        return bill.pdfUrl;
      }
      return 'http://localhost:8000${bill.pdfUrl}';
    }

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
        if (state is! BillLoadSuccess || state.totalPages <= 1) {
          return const SizedBox.shrink();
        }

        final startItem = (state.currentPage - 1) * state.pageSize + 1;
        final endItem = (state.currentPage * state.pageSize).clamp(
          0,
          state.totalBills,
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
                          'Affichage $startItem à $endItem sur ${state.totalBills} factures',
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
  final BillLoadSuccess state;
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
