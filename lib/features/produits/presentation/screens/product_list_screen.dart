import 'package:flutter/material.dart';
import 'package:oilab_frontend/shared/widgets/app_layout.dart';
import 'package:oilab_frontend/core/constants/app_colors.dart';
import 'package:oilab_frontend/features/dashboard/presentation/screens/dashboard_screen.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample data; replace with real model
    final history = List.generate(8, (i) {
      final status = [Colors.lightGreen, Colors.blue, Colors.red][i % 3];
      return {
        'owner': 'Moez',
        'in': '12/02/2024\n09:45',
        'out': '12/02/2024\n12:15',
        'qty': '800 Kg',
        'origin': 'Tunis',
        'status': status,
      };
    });

    return AppLayout(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ← Header row
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 28),
                  onPressed:
                      () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const DashboardScreen(),
                        ),
                      ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Produits',
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

            // ← Search + filter
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Recherche',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // TODO: open filter dialog
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ← Legend
            Row(
              children: [
                _LegendDot(color: Colors.lightGreen, label: 'Fini'),
                const SizedBox(width: 12),
                _LegendDot(color: Colors.blue, label: 'En cours'),
                const SizedBox(width: 12),
                _LegendDot(color: Colors.red, label: 'En attente'),
              ],
            ),
            const SizedBox(height: 16),

            // ← Table
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 24,
                  headingRowColor: MaterialStateProperty.all(
                    Colors.grey.shade100,
                  ),
                  columns: const [
                    DataColumn(label: Text('Propriétaire')),
                    DataColumn(label: Text('Temp d’entrée')),
                    DataColumn(label: Text('Temps de sortie')),
                    DataColumn(label: Text('Quantité')),
                    DataColumn(label: Text('Origine')),
                    DataColumn(label: Text('Statut')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows:
                      history.map((item) {
                        return DataRow(
                          cells: [
                            DataCell(Text(item['owner'] as String)),
                            DataCell(Text(item['in'] as String)),
                            DataCell(Text(item['out'] as String)),
                            DataCell(Text(item['qty'] as String)),
                            DataCell(Text(item['origin'] as String)),
                            DataCell(
                              CircleAvatar(
                                radius: 6,
                                backgroundColor: item['status'] as Color,
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: Colors.green,
                                    ),
                                    onPressed: () {
                                      Navigator.of(
                                        context,
                                      ).pushNamed('/produits/detail');
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      // TODO: delete
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.visibility,
                                      size: 18,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      // TODO: view details
                                    },
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

            // ← Pagination
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  _PageNumber(1, isActive: true),
                  _PageNumber(2),
                  _PageNumber(3),
                  const Text('…'),
                  _PageNumber(40),
                  IconButton(
                    onPressed: null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

class _PageNumber extends StatelessWidget {
  final int number;
  final bool isActive;
  const _PageNumber(this.number, {this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive ? AppColors.mainColor : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$number',
        style: TextStyle(
          color: isActive ? Colors.white : AppColors.textColor,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
