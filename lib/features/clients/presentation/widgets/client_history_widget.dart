import 'dart:math' as math;
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

  // Helper method to determine if it's a large desktop
  bool get isLargeDesktop => isDesktop && constraints.maxWidth > 1400;

  List<DataColumn> _buildColumns() {
    final double fontSize =
        isMobile ? 10 : (isTablet ? 11 : (isLargeDesktop ? 14 : 13));

    List<DataColumn> columns = [
      // Entry Time
      DataColumn(
        label: SizedBox(
          width:
              isMobile ? 80 : (isTablet ? 100 : (isLargeDesktop ? 150 : 120)),
          child: Text(
            isMobile ? 'Entrée' : 'Temps d\'entrée',
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      // Estimated Time
      DataColumn(
        label: SizedBox(
          width:
              isMobile ? 80 : (isTablet ? 100 : (isLargeDesktop ? 150 : 120)),
          child: Text(
            isMobile ? 'Estimé' : 'Temps estimé',
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ];

    // Exit Time (not on mobile)
    if (!isMobile) {
      columns.add(
        DataColumn(
          label: SizedBox(
            width: isTablet ? 100 : (isLargeDesktop ? 150 : 120),
            child: Text(
              'Temps de sortie',
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    }

    // Origin
    columns.add(
      DataColumn(
        label: SizedBox(
          width: isMobile ? 60 : (isTablet ? 80 : (isLargeDesktop ? 120 : 100)),
          child: Text(
            'Origine',
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );

    // Status
    columns.add(
      DataColumn(
        label: SizedBox(
          width:
              isMobile ? 80 : (isTablet ? 100 : (isLargeDesktop ? 150 : 120)),
          child: Text(
            'Statut',
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );

    // Quality (not on mobile)
    if (!isMobile) {
      columns.add(
        DataColumn(
          label: SizedBox(
            width: isTablet ? 80 : (isLargeDesktop ? 120 : 100),
            child: Text(
              'Qualité',
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    }

    // Price
    columns.add(
      DataColumn(
        label: SizedBox(
          width: isMobile ? 70 : (isTablet ? 90 : (isLargeDesktop ? 120 : 100)),
          child: Text(
            'Prix',
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );

    columns.add(
      DataColumn(
        label: SizedBox(
          width:
              isMobile ? 80 : (isTablet ? 100 : (isLargeDesktop ? 150 : 120)),
          child: Text(
            'Actions',
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    return columns;
  }

  List<DataCell> _buildCells(Product product, BuildContext context) {
    final double dataFontSize =
        isMobile ? 9 : (isTablet ? 10 : (isLargeDesktop ? 13 : 12));
    final double iconSize =
        isMobile ? 16 : (isTablet ? 18 : (isLargeDesktop ? 24 : 20));

    List<DataCell> cells = [
      DataCell(
        SizedBox(
          width:
              isMobile ? 80 : (isTablet ? 100 : (isLargeDesktop ? 150 : 120)),
          child: Text(
            product.formattedCreatedAt,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: dataFontSize),
          ),
        ),
      ),
      DataCell(
        SizedBox(
          width:
              isMobile ? 80 : (isTablet ? 100 : (isLargeDesktop ? 150 : 120)),
          child: Text(
            product.formattedEstimationDate,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: dataFontSize),
          ),
        ),
      ),
    ];

    if (!isMobile) {
      cells.add(
        DataCell(
          SizedBox(
            width: isTablet ? 100 : (isLargeDesktop ? 150 : 120),
            child: Text(
              product.formattedEndTime,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: dataFontSize),
            ),
          ),
        ),
      );
    }

    cells.add(
      DataCell(
        SizedBox(
          width: isMobile ? 60 : (isTablet ? 80 : (isLargeDesktop ? 120 : 100)),
          child: Text(
            product.origine ?? 'N/A',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: dataFontSize),
          ),
        ),
      ),
    );

    cells.add(
      DataCell(
        SizedBox(
          width:
              isMobile ? 80 : (isTablet ? 100 : (isLargeDesktop ? 150 : 120)),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 4 : (isLargeDesktop ? 12 : 8),
              vertical: isMobile ? 2 : (isLargeDesktop ? 6 : 4),
            ),
            decoration: BoxDecoration(
              color: _getStatusColor(product.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                isMobile ? 8 : (isLargeDesktop ? 16 : 12),
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
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    if (!isMobile) {
      cells.add(
        DataCell(
          SizedBox(
            width: isTablet ? 80 : (isLargeDesktop ? 120 : 100),
            child: Text(
              product.quality ?? 'N/A',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: dataFontSize),
            ),
          ),
        ),
      );
    }

    cells.add(
      DataCell(
        SizedBox(
          width: isMobile ? 70 : (isTablet ? 90 : (isLargeDesktop ? 120 : 100)),
          child: Text(
            product.price != null
                ? '${product.price!.toStringAsFixed(2)} DT'
                : 'N/A',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: dataFontSize),
          ),
        ),
      ),
    );

    cells.add(
      DataCell(
        SizedBox(
          width:
              isMobile ? 80 : (isTablet ? 100 : (isLargeDesktop ? 150 : 120)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit icon first
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap:
                      (product.status?.toLowerCase() == 'done' ||
                              product.status?.toLowerCase() == 'canceled')
                          ? null
                          : () => showDialog(
                            context: context,
                            builder:
                                (context) =>
                                    ProductUpdateDialog(product: product),
                          ),
                  child: Container(
                    padding: EdgeInsets.all(
                      isMobile ? 4 : (isLargeDesktop ? 8 : 6),
                    ),
                    child: Icon(
                      Icons.edit,
                      color:
                          (product.status?.toLowerCase() == 'done' ||
                                  product.status?.toLowerCase() == 'canceled')
                              ? Colors.grey
                              : Colors.green,
                      size: iconSize,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isLargeDesktop ? 8 : 4),
              // View icon second
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    // Handle view action
                  },
                  child: Container(
                    padding: EdgeInsets.all(
                      isMobile ? 4 : (isLargeDesktop ? 8 : 6),
                    ),
                    child: Icon(
                      Icons.visibility,
                      color: Colors.blue,
                      size: iconSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return cells;
  }

  @override
  Widget build(BuildContext context) {
    // Enhanced responsive spacing and sizing
    final double columnSpacing =
        isMobile ? 2 : (isTablet ? 6 : (isLargeDesktop ? 12 : 8));
    final double horizontalMargin =
        isMobile ? 4 : (isTablet ? 8 : (isLargeDesktop ? 16 : 12));
    final double rowHeight =
        isMobile ? 44 : (isTablet ? 52 : (isLargeDesktop ? 64 : 56));
    final double headerHeight =
        isMobile ? 40 : (isTablet ? 48 : (isLargeDesktop ? 60 : 52));

    // Calculate minimum width needed for all columns with enhanced desktop support
    double minRequiredWidth = 0;
    if (isMobile) {
      minRequiredWidth = 80 + 80 + 80 + 60 + 80 + 70 + 80;
      minRequiredWidth += columnSpacing * 6;
      minRequiredWidth += horizontalMargin * 2;
    } else if (isTablet) {
      double baseWidth = 100 + 100 + 100 + 80 + 100 + 80 + 90 + 100;
      baseWidth += columnSpacing * 7;
      baseWidth += horizontalMargin * 2;
      minRequiredWidth = baseWidth;
    } else if (isLargeDesktop) {
      double baseWidth = 150 + 150 + 150 + 120 + 150 + 120 + 120 + 150;
      baseWidth += columnSpacing * 7;
      baseWidth += horizontalMargin * 2;
      minRequiredWidth = baseWidth;
    } else {
      double baseWidth = 120 + 120 + 120 + 100 + 120 + 100 + 100 + 120;
      baseWidth += columnSpacing * 7;
      baseWidth += horizontalMargin * 2;
      minRequiredWidth = baseWidth;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: BoxConstraints(
          minWidth: minRequiredWidth,
          maxWidth: math.max(
            minRequiredWidth,
            constraints.maxWidth + (isLargeDesktop ? 400 : 200),
          ),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isLargeDesktop ? 12 : 8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: isLargeDesktop ? 6 : 4,
              offset: Offset(0, isLargeDesktop ? 3 : 2),
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dataTableTheme: DataTableThemeData(
              headingRowHeight: headerHeight,
              dataRowHeight: rowHeight,
              horizontalMargin: horizontalMargin,
              columnSpacing: columnSpacing,
              dividerThickness: 0.5,
            ),
          ),
          child: DataTable(
            showCheckboxColumn: false,
            columns: _buildColumns(),
            rows:
                products.map((product) {
                  return DataRow(cells: _buildCells(product, context));
                }).toList(),
          ),
        ),
      ),
    );
  }
}
