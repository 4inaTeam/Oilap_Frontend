import 'package:flutter/material.dart';

class EmployeeTableCard extends StatelessWidget {
  const EmployeeTableCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Employés',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  headingRowHeight: 40,
                  dataRowHeight: 36,
                  columns: const [
                    DataColumn(label: Text("Nom de l'employé")),
                    DataColumn(label: Text('Numéro de téléphone')),
                    DataColumn(label: Text('État')),
                  ],
                  rows: List.generate(
                    5,
                    (_) => const DataRow(
                      cells: [
                        DataCell(Text('Moez')),
                        DataCell(Text('23954782')),
                        DataCell(Text('Occupé')),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
