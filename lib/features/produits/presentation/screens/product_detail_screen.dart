import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/shared/widgets/app_layout.dart';
import 'package:oilab_frontend/core/constants/app_colors.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';


class ProductDetailScreen extends StatelessWidget {
  final dynamic product;

  const ProductDetailScreen({Key? key, required this.product})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: '/produits/detail',
      child: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          // Remove all SnackBar notifications
          // PDF download will happen silently
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: isMobile ? double.infinity : null,
                      child: BlocBuilder<ProductBloc, ProductState>(
                        builder: (context, state) {
                          final isLoading = state is ProductPDFDownloadLoading;

                          return ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              iconColor: Colors.white,
                              backgroundColor: AppColors.accentGreen,
                              padding: EdgeInsets.symmetric(
                                vertical: isMobile ? 14 : 12,
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed:
                                isLoading
                                    ? null
                                    : () {
                                      // Trigger PDF download
                                      context.read<ProductBloc>().add(
                                        DownloadProductPDF(
                                          productId: product.id,
                                        ),
                                      );
                                    },
                            icon:
                                isLoading
                                    ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : const Icon(Icons.download, size: 16),
                            label: Text(
                              isLoading
                                  ? 'Téléchargement...'
                                  : 'Télécharger PDF',
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: isMobile ? 16 : 24),

                  // Content section
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Table layout for mobile, card layout for larger screens
                          if (isMobile) ...[
                            _buildMobileTable(),
                            const SizedBox(height: 24),
                          ] else ...[
                            // Existing card layout for larger screens
                            Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    // First row
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildFormField(
                                            'Nom de Client',
                                            product.clientName ??
                                                product.client ??
                                                '-',
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        Expanded(
                                          child: _buildFormField(
                                            'Ville',
                                            product.origine ?? '-',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),

                                    // Second row
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildFormField(
                                            'Mode de livraison',
                                            product.quality ?? '-',
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        Expanded(
                                          child: _buildFormField(
                                            'Quantité',
                                            product.quantity != null
                                                ? '${product.quantity} Kg'
                                                : '-',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),

                                    // Third row
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildFormField(
                                            'Temps d\'entrée',
                                            product.formattedCreatedAt ?? '-',
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        Expanded(
                                          child: _buildFormField(
                                            'Sortie',
                                            product.status?.toLowerCase() ==
                                                    'done'
                                                ? 'Oui'
                                                : 'Non',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),

                                    // Fourth row
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildFormField(
                                            'Prix unitaire',
                                            product.price != null
                                                ? '${product.price} DT'
                                                : '-',
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        const Expanded(child: SizedBox()),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Status tracking section matching the screenshot
                          Card(
                            elevation: isMobile ? 0 : 2,
                            child: Padding(
                              padding: EdgeInsets.all(isMobile ? 0 : 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: isMobile ? 0 : 0,
                                      bottom: isMobile ? 16 : 24,
                                      top: isMobile ? 0 : 0,
                                    ),
                                    child: const Text(
                                      'Suivi de commande',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  _buildStatusTracker(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Mobile table layout
  Widget _buildMobileTable() {
    return Table(
      columnWidths: const {0: FlexColumnWidth(1.5), 1: FlexColumnWidth(2)},
      border: TableBorder.all(
        color: Colors.grey.shade300,
        width: 1.0,
        borderRadius: BorderRadius.circular(8),
      ),
      children: [
        _buildTableRow(
          'Nom de Client',
          product.clientName ?? product.client ?? '-',
        ),
        _buildTableRow('Ville', product.origine ?? '-'),
        _buildTableRow('Mode de livraison', product.quality ?? '-'),
        _buildTableRow(
          'Quantité',
          product.quantity != null ? '${product.quantity} Kg' : '-',
        ),
        _buildTableRow('Temps d\'entrée', product.formattedCreatedAt ?? '-'),
        _buildTableRow(
          'Sortie',
          product.status?.toLowerCase() == 'done' ? 'Oui' : 'Non',
        ),
        _buildTableRow(
          'Prix unitaire',
          product.price != null ? '${product.price} DT' : '-',
        ),
      ],
    );
  }

  // Table row builder
  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade50),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey.shade50,
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTracker() {
    // Define status list
    final List<Map<String, dynamic>> statuses = [
      {'status': 'pending', 'label': 'En attente', 'color': Colors.grey},
      {'status': 'doing', 'label': 'En cours', 'color': Colors.green},
      {'status': 'done', 'label': 'Fini', 'color': Colors.blue},
    ];

    // Get current status with null safety
    final String currentStatus = product?.status?.toLowerCase() ?? 'pending';

    // Find current index
    int currentIndex = statuses.indexWhere((s) => s['status'] == currentStatus);
    if (currentIndex == -1) {
      currentIndex = 0; // Default to first status if not found
    }

    // Build status items
    final List<Widget> statusWidgets = [];

    for (int index = 0; index < statuses.length; index++) {
      final statusInfo = statuses[index];
      final isCompleted = index <= currentIndex;
      final isActive = index == currentIndex;

      statusWidgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              // Left circle
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isCompleted
                          ? (statusInfo['color'] as Color)
                          : Colors.grey.shade300,
                ),
                child:
                    isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
              ),
              const SizedBox(width: 12),

              // Progress line
              Expanded(
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color:
                        isCompleted
                            ? (statusInfo['color'] as Color)
                            : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Status label
              Text(
                statusInfo['label'] as String,
                style: TextStyle(
                  color: isCompleted ? Colors.black : Colors.grey,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 12),

              // Right circle
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isCompleted
                          ? (statusInfo['color'] as Color)
                          : Colors.grey.shade300,
                ),
                child:
                    isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
              ),
            ],
          ),
        ),
      );
    }

    return Column(children: statusWidgets);
  }
}
