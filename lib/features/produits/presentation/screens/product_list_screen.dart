import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:oilab_frontend/core/constants/app_colors.dart';
import 'package:oilab_frontend/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:oilab_frontend/features/produits/presentation/screens/product_add_dialog.dart';
import 'package:oilab_frontend/features/produits/presentation/screens/product_detail_screen.dart';
import 'package:oilab_frontend/features/produits/presentation/screens/product_update_dialog.dart';
import 'package:oilab_frontend/features/auth/data/auth_repository.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import 'package:oilab_frontend/shared/widgets/app_layout.dart';

String _translateStatus(String? status) {
  if (status == null) return 'N/A';
  switch (status.toLowerCase()) {
    case 'pending':
      return 'En attente';
    case 'doing':
      return 'En cours';
    case 'done':
      return 'Fini';
    case 'canceled':
      return 'Annulé';
    default:
      return status;
  }
}

Color _getStatusColor(String? status) {
  if (status == null) return Colors.grey;
  switch (status.toLowerCase()) {
    case 'pending':
      return Colors.orange;
    case 'doing':
      return Colors.blue;
    case 'done':
      return Colors.green;
    case 'canceled':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _ProductListView();
  }
}

class _ProductListView extends StatefulWidget {
  const _ProductListView({Key? key}) : super(key: key);

  @override
  _ProductListViewState createState() => _ProductListViewState();
}

class _ProductListViewState extends State<_ProductListView> {
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProductBloc>().add(LoadProducts());
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

    final event = query.isEmpty ? LoadProducts() : SearchProducts(query: query);
    context.read<ProductBloc>().add(event);
  }

  void _changePage(int page) {
    if (!mounted) return;
    context.read<ProductBloc>().add(
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
                Expanded(child: _ProductContent(isMobile: isMobile)),
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
            'Produits',
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
    final isClient = AuthRepository.currentRole == 'CLIENT';

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
        hintText: 'Rechercher',
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
              builder: (context) => const ProductAddDialog(),
            ),
        icon: Image.asset('assets/icons/Vector.png', width: 16, height: 16),
        label: const Text(
          'Ajouter un nouveau',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

    // Only show addButton if not CLIENT
    return isMobile
        ? Column(
          children: [
            searchField,
            if (!isClient) ...[const SizedBox(height: 12), addButton],
          ],
        )
        : Row(
          children: [
            Expanded(flex: 3, child: searchField),
            if (!isClient) ...[const SizedBox(width: 16), addButton],
          ],
        );
  }
}

class _ProductContent extends StatelessWidget {
  final bool isMobile;

  const _ProductContent({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductInitial || state is ProductLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProductLoadSuccess) {
          return state.products.isEmpty
              ? const _EmptyState()
              : _ProductTable(products: state.products, isMobile: isMobile);
        }

        if (state is ProductOperationFailure) {
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
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun produit trouvé',
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
            onPressed: () => context.read<ProductBloc>().add(LoadProducts()),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

String _formatDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '-';
  try {
    final date = DateTime.parse(dateStr);
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  } catch (e) {
    debugPrint('Error formatting date: $e for date: $dateStr');
    return '-';
  }
}

class _ProductTable extends StatelessWidget {
  final List<dynamic> products;
  final bool isMobile;

  const _ProductTable({required this.products, required this.isMobile});

  @override
  Widget build(BuildContext context) {
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
                  columnSpacing: isMobile ? 10 : 56.0,
                  horizontalMargin: isMobile ? 8 : 24,
                  columns: [
                    DataColumn(
                      label: Text(
                        'Propriétaire',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Temps d\'entrée',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Only show "Date de sortie" column on web/desktop, right after "Temps d'entrée"
                    if (!isMobile)
                      DataColumn(
                        label: Text(
                          'Date de sortie',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    DataColumn(
                      label: Text(
                        'Quantité',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Origine',
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
                        'Actions',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows:
                      products
                          .map((product) {
                            if (product == null) return null;

                            final ownerDisplay =
                                product.clientDetails?['username']
                                    ?.toString() ??
                                product.client ??
                                '-';

                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    ownerDisplay,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    _formatDate(product.createdAt?.toString()),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Only show "Date de sortie" cell on web/desktop, right after "Temps d'entrée"
                                if (!isMobile)
                                  DataCell(
                                    Text(
                                      _formatDate(product.end_time?.toString()),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color:
                                            product.end_time != null
                                                ? Colors.black
                                                : Colors.grey,
                                      ),
                                    ),
                                  ),
                                DataCell(
                                  Text(
                                    product.quantity != null
                                        ? '${product.quantity} Kg'
                                        : '',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    product.origine?.toString() ?? '',
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
                                            product.status,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _translateStatus(product.status),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  _ActionButtons(
                                    product: product,
                                    isMobile: isMobile,
                                  ),
                                ),
                              ],
                            );
                          })
                          .where((row) => row != null)
                          .cast<DataRow>()
                          .toList(),
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
  final dynamic product;
  final bool isMobile;

  const _ActionButtons({required this.product, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final iconSize = isMobile ? 16.0 : 24.0;
    final isStatusDone =
        product.status == 'done' || product.status == 'canceled';
    final canCancel = product.status == 'pending';

    if (isMobile) {
      // For mobile: Show actions vertically or in a more compact way
      return PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, size: iconSize),
        onSelected: (value) {
          switch (value) {
            case 'edit':
              if (!isStatusDone) {
                showDialog(
                  context: context,
                  builder: (context) => ProductUpdateDialog(product: product),
                );
              }
              break;
            case 'cancel':
              if (canCancel) {
                _confirmCancel(context, product);
              }
              break;
            case 'view':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: product),
                ),
              );
              break;
          }
        },
        itemBuilder:
            (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'edit',
                enabled: !isStatusDone,
                child: Row(
                  children: [
                    Icon(
                      Icons.edit,
                      color: isStatusDone ? Colors.grey : Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Modifier',
                      style: TextStyle(
                        color: isStatusDone ? Colors.grey : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'cancel',
                enabled: canCancel,
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icons/Disactivate.png',
                      width: 16,
                      height: 16,
                      color: canCancel ? null : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Annuler',
                      style: TextStyle(color: canCancel ? null : Colors.grey),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'view',
                child: Row(
                  children: [
                    Image.asset('assets/icons/View.png', width: 16, height: 16),
                    const SizedBox(width: 8),
                    const Text('Voir'),
                  ],
                ),
              ),
            ],
      );
    }

    // For desktop: Show actions horizontally as before
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.edit,
            color: isStatusDone ? Colors.grey : Colors.green,
            size: iconSize,
          ),
          onPressed:
              isStatusDone
                  ? null
                  : () => showDialog(
                    context: context,
                    builder: (context) => ProductUpdateDialog(product: product),
                  ),
        ),
        const SizedBox(width: 5),
        Text('|', style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(width: 5),
        IconButton(
          icon: Image.asset(
            'assets/icons/Disactivate.png',
            width: 16,
            height: 16,
            color: canCancel ? null : Colors.grey,
          ),
          onPressed: canCancel ? () => _confirmCancel(context, product) : null,
        ),
        const SizedBox(width: 5),
        Text('|', style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(width: 5),
        IconButton(
          icon: Image.asset(
            'assets/icons/View.png',
            width: 16,
            height: 16,
            color: null,
          ),
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: product),
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
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is! ProductLoadSuccess || state.totalPages <= 1) {
          return const SizedBox.shrink();
        }

        final startItem = (state.currentPage - 1) * state.pageSize + 1;
        final endItem = (state.currentPage * state.pageSize).clamp(
          0,
          state.totalProducts,
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
                          'Affichage $startItem à $endItem sur ${state.totalProducts} produits',
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
  final ProductLoadSuccess state;
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

void _confirmCancel(BuildContext context, dynamic product) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmer l\'annulation'),
        content: const Text('Voulez-vous vraiment annuler ce produit ?'),
        actions: [
          TextButton(
            child: const Text('Non'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Oui', style: TextStyle(color: Colors.red)),
            onPressed: () {
              context.read<ProductBloc>().add(CancelProduct(product: product));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Produit annulé avec succès'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      );
    },
  );
}
