import 'package:flutter/material.dart';
import 'package:oilab_frontend/shared/widgets/app_layout.dart';
import 'package:oilab_frontend/core/constants/app_colors.dart';

class ClientProfileScreen extends StatelessWidget {
  const ClientProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data; replace with your real model
    final clientName = 'Moez Foulen';
    //final phone = '23 455 856';
    //final email = 'MoezFoulen@gmail.com';
    //final type = 'Particulier';
    final stats = {
      'Quantité entrée': '800 Kg',
      'Litres produits': '132,4 L',
      'Montant dépensé': '800 DT',
      'Dernière visite': '12/01/2025',
    };
    final history = [
      {
        'entrée': '12/01/2025\n09:45',
        'estimé': '30:05',
        'sortie': '12/01/2025\n10:15',
        'ville': 'Tunis',
        'statut': 'En cours',
        'quantité': '400 Kg',
        'prix': '400 DT',
      },
      {
        'entrée': '12/12/2024\n09:45',
        'estimé': '30:05',
        'sortie': '12/12/2024\n10:15',
        'ville': 'Sfax',
        'statut': 'Fini',
        'quantité': '400 Kg',
        'prix': '400 DT',
      },
    ];

    return AppLayout(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ← Header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Clients Profile',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ← Avatar + name + button
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.accentYellow,
                  child: const Icon(Icons.person, size: 48, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                Text(
                  clientName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.folder, size: 18),
                  label: const Text('Factures'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // TODO: navigate to this client's invoices
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ← Top stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
                  stats.entries.map((e) {
                    return Expanded(
                      child: Column(
                        children: [
                          Text(
                            e.value,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(e.key, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 32),

            // ← History table
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 12,
                  headingRowColor: MaterialStateProperty.all(
                    Colors.grey.shade100,
                  ),
                  columns: const [
                    DataColumn(label: Text('Temp d’entrée')),
                    DataColumn(label: Text('Temps estimé')),
                    DataColumn(label: Text('Temp de sortie')),
                    DataColumn(label: Text('Ville')),
                    DataColumn(label: Text('Statut')),
                    DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('Prix total')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows:
                      history.map((item) {
                        final isDone = item['statut'] == 'Fini';
                        final dotColor =
                            isDone
                                ? AppColors.accentGreen
                                : AppColors.accentYellow;
                        return DataRow(
                          cells: [
                            DataCell(Text(item['entrée']!)),
                            DataCell(Text(item['estimé']!)),
                            DataCell(Text(item['sortie']!)),
                            DataCell(Text(item['ville']!)),
                            DataCell(
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 6,
                                    backgroundColor: dotColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(item['statut']!),
                                ],
                              ),
                            ),
                            DataCell(Text(item['quantité']!)),
                            DataCell(Text(item['prix']!)),
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
                                      // TODO: edit this entry
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      // TODO: remove this entry
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
          ],
        ),
      ),
    );
  }
}
