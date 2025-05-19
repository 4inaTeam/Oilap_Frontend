import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_layout.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';

class ClientListScreen extends StatelessWidget {
  const ClientListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ← Clients header
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
                  'Clients',
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

            // Search & Add button
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
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // TODO: open client creation form
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter un nouveau'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Legend
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

            // Table header + rows
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 24,
                  headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                  columns: const [
                    DataColumn(label: Text('Nom de client')),
                    DataColumn(label: Text('Temp d’entrée')),
                    DataColumn(label: Text('Temps de sortie')),
                    DataColumn(label: Text('Quantité')),
                    DataColumn(label: Text('Origine')),
                    DataColumn(label: Text('Statut')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: List.generate(8, (i) {
                    // Example data; replace with your model
                    final status =
                        [Colors.lightGreen, Colors.blue, Colors.red][i % 3];
                    return DataRow(
                      cells: [
                        const DataCell(Text('Moez')),
                        const DataCell(Text('12/02/2024\n09:45')),
                        const DataCell(Text('12/02/2024\n12:15')),
                        const DataCell(Text('800 Kg')),
                        const DataCell(Text('Tunis')),
                        DataCell(
                          CircleAvatar(radius: 6, backgroundColor: status),
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
                                  ).pushNamed('/clients/profile');
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.visibility,
                                  size: 18,
                                  color: Colors.blue,
                                ),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),

            // Pagination
            Padding(
              padding: const EdgeInsets.only(top: 16),
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

/// Little helper for the colored legend dots
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

/// Pagination button
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
