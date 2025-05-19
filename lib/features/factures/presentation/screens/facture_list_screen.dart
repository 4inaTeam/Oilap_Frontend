import 'package:flutter/material.dart';
import 'package:oilab_frontend/shared/widgets/app_layout.dart';
import 'package:oilab_frontend/core/constants/app_colors.dart';
import 'package:oilab_frontend/features/dashboard/presentation/screens/dashboard_screen.dart';

class FactureListScreen extends StatelessWidget {
  const FactureListScreen({Key? key}) : super(key: key);

  void _openDetail(BuildContext context, String reference) {
    Navigator.of(context).pushNamed('/factures/detail', arguments: reference);
  }

  @override
  Widget build(BuildContext context) {
    // Example data
    final factures = [
      {
        'ref': '2395478',
        'owner': 'Moez',
        'price': '200 DT',
        'status': true,
        'time': '12/02/2024\n09:45',
      },
      {
        'ref': '5498002',
        'owner': 'Ahmed',
        'price': '200 DT',
        'status': false,
        'time': '12/01/2025\n13:55',
      },
      {
        'ref': '5495100',
        'owner': 'Nour',
        'price': '200 DT',
        'status': true,
        'time': '30/11/2024\n10:25',
      },
      {
        'ref': '2078199',
        'owner': 'Jihed',
        'price': '200 DT',
        'status': true,
        'time': '22/07/2024\n11:52',
      },
      {
        'ref': '9864100',
        'owner': 'Takwa',
        'price': '200 DT',
        'status': true,
        'time': '14/09/2024\n08:20',
      },
      {
        'ref': '5049226',
        'owner': 'Hamza',
        'price': '200 DT',
        'status': false,
        'time': '20/12/2024\n09:40',
      },
      {
        'ref': '2476312',
        'owner': 'Asma',
        'price': '200 DT',
        'status': false,
        'time': '02/01/2025\n14:43',
      },
      {
        'ref': '2394576',
        'owner': 'Fatma',
        'price': '200 DT',
        'status': true,
        'time': '04/10/2024\n08:40',
      },
    ];

    return AppLayout(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header row
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed:
                      () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const DashboardScreen(),
                        ),
                      ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Factures',
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

            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Recherche',
                      isDense: true,
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
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/factures/upload');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter une facture'),
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
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Legend
            Row(
              children: const [
                LegendDot(color: Colors.green, label: 'Payé'),
                SizedBox(width: 16),
                LegendDot(color: Colors.red, label: 'Non payé'),
              ],
            ),

            const SizedBox(height: 16),

            // Facture table
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 24,
                  headingRowHeight: 40,
                  dataRowHeight: 56,
                  columns: const [
                    DataColumn(label: Text('Référence')),
                    DataColumn(label: Text('Propriétaire')),
                    DataColumn(label: Text('Prix')),
                    DataColumn(label: Text('Statut')),
                    DataColumn(label: Text('Temps')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows:
                      factures.map((f) {
                        return DataRow(
                          cells: [
                            DataCell(Text(f['ref'] as String)),
                            DataCell(Text(f['owner'] as String)),
                            DataCell(Text(f['price'] as String)),
                            DataCell(
                              CircleAvatar(
                                radius: 6,
                                backgroundColor:
                                    (f['status'] as bool)
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            ),
                            DataCell(Text(f['time'] as String)),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.green,
                                    ),
                                    onPressed: () {
                                      // TODO: edit facture
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      // TODO: delete facture
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.remove_red_eye),
                                    onPressed:
                                        () => _openDetail(
                                          context,
                                          f['ref'] as String,
                                        ),
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
                  PageNumber(1, isActive: true),
                  PageNumber(2),
                  PageNumber(3),
                  const Text('…'),
                  PageNumber(40),
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

class LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const LegendDot({required this.color, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}

class PageNumber extends StatelessWidget {
  final int number;
  final bool isActive;
  const PageNumber(this.number, {this.isActive = false, super.key});

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
