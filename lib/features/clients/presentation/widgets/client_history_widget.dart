import 'package:flutter/material.dart';
import 'package:oilab_frontend/core/models/product_model.dart';
import '../../../produits/presentation/screens/product_update_dialog.dart';

class ClientHistoryWidget extends StatelessWidget {
  final List<Product> products;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final BoxConstraints constraints;

  const ClientHistoryWidget({
    Key? key,
    required this.products,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.constraints,
  }) : super(key: key);

  String _mapStatusToFrench(String? status) {
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
      case 'en cours':
        return Colors.orange;
      case 'doing':
      case 'en pesage':
        return Colors.blue;
      case 'done':
      case 'fini':
        return Colors.green;
      case 'canceled':
      case 'annulé':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _confirmDeletion(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer ce produit ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                // Add your delete logic here
                Navigator.of(context).pop();
                // Call delete function
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double iconSize = isMobile ? 16 : (isTablet ? 18 : 20);
    final double fontSize = isMobile ? 10 : (isTablet ? 11 : 13);
    final double dataFontSize = isMobile ? 9 : (isTablet ? 10 : 12);
    final double columnSpacing = isMobile ? 8 : (isTablet ? 12 : 20);
    final double horizontalMargin = isMobile ? 8 : (isTablet ? 12 : 16);
    final double rowHeight = isMobile ? 40 : (isTablet ? 48 : 52);
    final double headerHeight = isMobile ? 36 : (isTablet ? 44 : 48);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: BoxConstraints(
          minWidth: isMobile ? 320 : (constraints.maxWidth - 32),
          maxWidth: isDesktop ? double.infinity : constraints.maxWidth + 200,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dataTableTheme: DataTableThemeData(
              headingTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
              dataTextStyle: TextStyle(fontSize: dataFontSize),
              headingRowHeight: headerHeight,
              dataRowHeight: rowHeight,
              horizontalMargin: horizontalMargin,
              columnSpacing: columnSpacing,
            ),
          ),
          child: DataTable(
            columns: [
              DataColumn(
                label: Flexible(
                  child: Text(
                    isMobile ? 'Entrée' : 'Temps d\'entrée',
                    style: TextStyle(fontSize: fontSize),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataColumn(
                label: Flexible(
                  child: Text(
                    isMobile ? 'Estimé' : 'Temps estimé',
                    style: TextStyle(fontSize: fontSize),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (!isMobile)
                DataColumn(
                  label: Flexible(
                    child: Text(
                      'Temps de sortie',
                      style: TextStyle(fontSize: fontSize),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              DataColumn(
                label: Flexible(
                  child: Text(
                    'Origine',
                    style: TextStyle(fontSize: fontSize),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataColumn(
                label: Flexible(
                  child: Text(
                    'Statut',
                    style: TextStyle(fontSize: fontSize),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (!isMobile)
                DataColumn(
                  label: Flexible(
                    child: Text(
                      'Qualité',
                      style: TextStyle(fontSize: fontSize),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              DataColumn(
                label: Flexible(
                  child: Text(
                    'Prix',
                    style: TextStyle(fontSize: fontSize),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataColumn(
                label: Flexible(
                  child: Text(
                    'Actions',
                    style: TextStyle(fontSize: fontSize),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            rows:
                products.map((product) {
                  return DataRow(
                    cells: [
                      DataCell(
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isMobile ? 60 : (isTablet ? 80 : 120),
                          ),
                          child: Text(
                            product.formattedCreatedAt,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: dataFontSize),
                          ),
                        ),
                      ),
                      DataCell(
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isMobile ? 60 : (isTablet ? 80 : 120),
                          ),
                          child: Text(
                            product.formattedEstimationDate,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: dataFontSize),
                          ),
                        ),
                      ),
                      if (!isMobile)
                        DataCell(
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isTablet ? 80 : 120,
                            ),
                            child: Text(
                              product.formattedEndTime,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: dataFontSize),
                            ),
                          ),
                        ),
                      DataCell(
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isMobile ? 40 : (isTablet ? 60 : 100),
                          ),
                          child: Text(
                            product.origine ?? 'N/A',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: dataFontSize),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 4 : 8,
                            vertical: isMobile ? 2 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              product.status,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              isMobile ? 8 : 12,
                            ),
                          ),
                          child: Text(
                            _mapStatusToFrench(product.status),
                            style: TextStyle(
                              color: _getStatusColor(product.status),
                              fontWeight: FontWeight.w600,
                              fontSize: dataFontSize,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (!isMobile)
                        DataCell(
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isTablet ? 60 : 80,
                            ),
                            child: Text(
                              product.quality ?? 'N/A',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: dataFontSize),
                            ),
                          ),
                        ),
                      DataCell(
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isMobile ? 50 : (isTablet ? 70 : 90),
                          ),
                          child: Text(
                            product.price != null
                                ? '${product.price!.toStringAsFixed(2)} DT'
                                : 'N/A',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: dataFontSize),
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Colors.green,
                                size: iconSize,
                              ),
                              onPressed:
                                  () => showDialog(
                                    context: context,
                                    builder:
                                        (context) => ProductUpdateDialog(
                                          product: product,
                                        ),
                                  ),
                              constraints: BoxConstraints(
                                minWidth: isMobile ? 24 : 32,
                                minHeight: isMobile ? 24 : 32,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            if (!isMobile && !isTablet) ...[
                              const SizedBox(width: 4),
                              Text(
                                '|',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: iconSize,
                              ),
                              onPressed:
                                  () => _confirmDeletion(context, product),
                              constraints: BoxConstraints(
                                minWidth: isMobile ? 24 : 32,
                                minHeight: isMobile ? 24 : 32,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}
