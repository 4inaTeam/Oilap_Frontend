import 'package:flutter/material.dart';

class DataTableCard extends StatelessWidget {
  const DataTableCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Clients récents',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 32,
                  headingRowHeight: 40,
                  dataRowHeight: 36,
                  columns: const [
                    DataColumn(label: Text('Nom de client')),
                    DataColumn(label: Text('Quantité')),
                    DataColumn(label: Text('Temps restant')),
                  ],
                  rows: List.generate(
                    5,
                    (_) => const DataRow(
                      cells: [
                        DataCell(Text('Moez')),
                        DataCell(Text('700 Kg')),
                        DataCell(Text('01:30:20')),
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
