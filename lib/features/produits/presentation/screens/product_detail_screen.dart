import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oilab_frontend/shared/widgets/app_layout.dart';

class ProductDetailScreen extends StatelessWidget {
  final dynamic product;

  const ProductDetailScreen({Key? key, required this.product})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button and download
                Row(
                  children: [
                    if (!isMobile) ...[
                      IconButton(
                        icon: const Icon(Icons.arrow_back, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                    ],
                    const Expanded(
                      child: Text(
                        'Détails de produit',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Téléchargement en cours...'),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.download,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          'Télécharger',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 16 : 24),

                // NEW: Table layout for mobile instead of card
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
                                  product.clientName ?? product.client ?? '-',
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
                                  product.status?.toLowerCase() == 'done'
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
          );
        },
      ),
    );
  }

  // NEW: Mobile table layout
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

  // NEW: Table row builder
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
    final statuses = [
      {'status': 'pending', 'label': 'En attente', 'color': Colors.grey},
      {'status': 'doing', 'label': 'En cours', 'color': Colors.green},
      {'status': 'done', 'label': 'Fini', 'color': Colors.blue},
    ];

    final currentStatus = product.status?.toLowerCase() ?? 'pending';
    int currentIndex = statuses.indexWhere((s) => s['status'] == currentStatus);

    if (currentIndex == -1) {
      currentIndex = 0;
    }

    return Column(
      children:
          statuses.asMap().entries.map((entry) {
            final index = entry.key;
            final statusInfo = entry.value;
            final isCompleted = index <= currentIndex;
            final isActive = index == currentIndex;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isCompleted
                              ? statusInfo['color'] as Color
                              : Colors.grey.shade300,
                    ),
                    child:
                        isCompleted
                            ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            )
                            : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color:
                            isCompleted
                                ? statusInfo['color'] as Color
                                : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    statusInfo['label'] as String,
                    style: TextStyle(
                      color: isCompleted ? Colors.black : Colors.grey,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isCompleted
                              ? statusInfo['color'] as Color
                              : Colors.grey.shade300,
                    ),
                    child:
                        isCompleted
                            ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            )
                            : null,
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}

// Product model remains the same
class Product {
  final String? client;
  final String? clientName;
  final String? clientCin;
  final String? quality;
  final double? quantity;
  final String? origine;
  final double? price;
  final DateTime? createdAt;
  final DateTime? estimationDate;
  final int? estimationTime;
  final DateTime? end_time;
  final String? createdBy;
  final String? status;
  final String? photo;

  Product({
    this.client,
    this.clientName,
    this.clientCin,
    this.quality,
    this.quantity,
    this.origine,
    this.price,
    this.createdAt,
    this.estimationDate,
    this.estimationTime,
    this.end_time,
    this.createdBy,
    this.status,
    this.photo,
  });

  String get formattedCreatedAt => _formatDateTime(createdAt);
  String get formattedEstimationDate => _formatDateTime(estimationDate);
  String get formattedEndTime => _formatDateTime(end_time);

  String _formatDateTime(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      client: json['client']?.toString(),
      clientName: json['clientName']?.toString(),
      clientCin: json['clientCin']?.toString(),
      quality: json['quality']?.toString(),
      quantity: double.tryParse(json['quantity']?.toString() ?? ''),
      origine: json['origine']?.toString(),
      price: double.tryParse(json['price']?.toString() ?? ''),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      estimationDate:
          json['estimationDate'] != null
              ? DateTime.parse(json['estimationDate'])
              : null,
      estimationTime: int.tryParse(json['estimationTime']?.toString() ?? ''),
      end_time:
          json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      createdBy: json['createdBy']?.toString(),
      status: json['status']?.toString(),
      photo: json['photo']?.toString(),
    );
  }
}
