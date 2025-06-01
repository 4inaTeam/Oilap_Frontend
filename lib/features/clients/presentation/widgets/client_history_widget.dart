import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oilab_frontend/core/models/product_model.dart';

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: BoxConstraints(minWidth: constraints.maxWidth - 32),
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
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              dataTextStyle: const TextStyle(fontSize: 12),
              headingRowHeight: 48,
              dataRowHeight: 52,
              horizontalMargin: 16,
              columnSpacing: 20,
            ),
          ),
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Qualité')),
              DataColumn(label: Text('Quantité')),
              DataColumn(label: Text('Origine')),
              DataColumn(label: Text('Date d\'entrée')),
              DataColumn(label: Text('Date de sortie')),
              DataColumn(label: Text('Statut')),
            ],
            rows:
                products.map((product) {
                  final status = product.status?.toLowerCase() ?? '';
                  final quantity =
                      product.quantity != null ? '${product.quantity} Kg' : '-';

                  // Format dates safely
                  String formatDateTime(String? dateStr) {
                    if (dateStr == null || dateStr.isEmpty) return '-';
                    try {
                      final date = DateTime.parse(dateStr);
                      return DateFormat('dd/MM/yyyy HH:mm').format(date);
                    } catch (e) {
                      return '-';
                    }
                  }

                  return DataRow(
                    cells: [
                      DataCell(Text(product.quality ?? '-')),
                      DataCell(Text(quantity)),
                      DataCell(Text(product.origine ?? '-')),
                      DataCell(Text(formatDateTime(product.createdAt))),
                      DataCell(
                        Text(
                          product.exitDate != null
                              ? DateFormat(
                                'dd/MM/yyyy HH:mm',
                              ).format(product.exitDate!)
                              : '-',
                        ),
                      ),
                      DataCell(_buildStatusCell(status)),
                    ],
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCell(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'completed':
      case 'fini':
      case 'done':
      case 'terminé':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case 'pending':
      case 'en cours':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      default:
        bgColor = Colors.grey.shade50;
        textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.isEmpty ? '-' : status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
