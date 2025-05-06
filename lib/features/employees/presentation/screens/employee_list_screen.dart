import 'package:flutter/material.dart';
import 'package:oilab_frontend/shared/widgets/app_layout.dart';
import 'package:oilab_frontend/core/constants/app_colors.dart';

class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Employés',
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

            // ← Search + Add
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
                    // TODO: open add-employee form
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter un nouveau'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ← Employee table
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 24,
                  headingRowColor: MaterialStateProperty.all(
                    Colors.grey.shade100,
                  ),
                  columns: const [
                    DataColumn(label: Text('Nom de l\'employé')),
                    DataColumn(label: Text('Numéro de téléphone')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Ville')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: List.generate(8, (i) {
                    // Sample data — replace with real model
                    final names = [
                      'Moez',
                      'Ahmed',
                      'Nour',
                      'Jihed',
                      'Takwa',
                      'Hamza',
                      'Asma',
                      'Fatma',
                    ];
                    final phones = [
                      '23954780',
                      '54980024',
                      '54951007',
                      '20781994',
                      '98641000',
                      '50492267',
                      '24763128',
                      '23945761',
                    ];
                    final emails =
                        names
                            .map((n) => '${n.toLowerCase()}@gmail.com')
                            .toList();
                    final cities = [
                      'Tunis',
                      'Mahdia',
                      'Tunis',
                      'Djerba',
                      'Monastir',
                      'Tataouine',
                      'Beja',
                      'Bizerte',
                    ];
                    return DataRow(
                      cells: [
                        DataCell(Text(names[i])),
                        DataCell(Text(phones[i])),
                        DataCell(Text(emails[i])),
                        DataCell(Text(cities[i])),
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
                                  // TODO: edit action
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  // TODO: delete action
                                },
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
