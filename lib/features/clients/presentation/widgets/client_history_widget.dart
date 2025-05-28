import 'package:flutter/material.dart';
import 'package:oilab_frontend/core/models/product_model.dart';
import 'package:oilab_frontend/core/constants/app_colors.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        if (products.isEmpty)
          _buildEmptyState()
        else if (isDesktop || isTablet)
          _buildDesktopTable(products)
        else
          _buildMobileCards(products),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'No Products Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This client has no products in the system yet.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(List<Product> products) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
          headingTextStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
          dataTextStyle: TextStyle(fontSize: 12, color: Colors.black87),
          columns: const [
            DataColumn(label: Text('Product ID')),
            DataColumn(label: Text('Quality')),
            DataColumn(label: Text('Origin')),
            DataColumn(label: Text('Price')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: products.map((product) => _buildDataRow(product)).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileCards(List<Product> products) {
    return Column(
      children: products.map((product) => _buildMobileCard(product)).toList(),
    );
  }

  Widget _buildMobileCard(Product product) {
    final isCompleted =
        product.status.toLowerCase() == 'completed' ||
        product.status.toLowerCase() == 'fini';
    final isPending = product.status.toLowerCase() == 'pending';

    Color statusColor;
    if (isCompleted) {
      statusColor = AppColors.accentGreen;
    } else if (isPending) {
      statusColor = AppColors.accentYellow;
    } else {
      statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Product #${product.id}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    CircleAvatar(radius: 6, backgroundColor: statusColor),
                    const SizedBox(width: 6),
                    Text(product.status),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quality: ${product.quality}'),
                    SizedBox(height: 4),
                    Text('Origin: ${product.origine}'),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${product.price.toStringAsFixed(2)} DT',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: Colors.green),
                  onPressed: () {
                    // TODO: edit this product
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: () {
                    // TODO: delete this product
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.visibility,
                    size: 18,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    // TODO: view product details
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(Product product) {
    final isCompleted =
        product.status.toLowerCase() == 'completed' ||
        product.status.toLowerCase() == 'fini';
    final isPending = product.status.toLowerCase() == 'pending';

    Color statusColor;
    if (isCompleted) {
      statusColor = AppColors.accentGreen;
    } else if (isPending) {
      statusColor = AppColors.accentYellow;
    } else {
      statusColor = Colors.grey;
    }

    return DataRow(
      cells: [
        DataCell(Text('#${product.id}', style: const TextStyle(fontSize: 12))),
        DataCell(Text(product.quality, style: const TextStyle(fontSize: 12))),
        DataCell(Text(product.origine, style: const TextStyle(fontSize: 12))),
        DataCell(
          Text(
            '${product.price.toStringAsFixed(2)} DT',
            style: const TextStyle(fontSize: 12),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 4, backgroundColor: statusColor),
              const SizedBox(width: 6),
              Text(product.status, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        DataCell(_buildActionButtons()),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          icon: Icon(Icons.edit, size: 16, color: Colors.green),
          onPressed: () {
            // TODO: edit this product
          },
        ),
        const SizedBox(width: 8),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          icon: Icon(Icons.delete, size: 16, color: Colors.red),
          onPressed: () {
            // TODO: delete this product
          },
        ),
        const SizedBox(width: 8),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          icon: Icon(Icons.visibility, size: 16, color: Colors.blue),
          onPressed: () {
            // TODO: view product details
          },
        ),
      ],
    );
  }
}
