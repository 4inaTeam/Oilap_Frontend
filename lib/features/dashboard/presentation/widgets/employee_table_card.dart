import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/features/employees/presentation/bloc/employee_bloc.dart';
import 'package:oilab_frontend/features/employees/presentation/bloc/employee_event.dart';
import 'package:oilab_frontend/features/employees/presentation/bloc/employee_state.dart';

class EmployeeTableCard extends StatefulWidget {
  const EmployeeTableCard({Key? key}) : super(key: key);

  @override
  State<EmployeeTableCard> createState() => _EmployeeTableCardState();
}

class _EmployeeTableCardState extends State<EmployeeTableCard> {
  @override
  void initState() {
    super.initState();
    context.read<EmployeeBloc>().add(LoadEmployees());
  }

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
              child: BlocBuilder<EmployeeBloc, EmployeeState>(
                builder: (context, state) {
                  if (state is EmployeeLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is EmployeeLoadSuccess) {
                    final random5 =
                        (state.employees..shuffle()).take(5).toList();

                    return SingleChildScrollView(
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
                        rows:
                            random5
                                .map(
                                  (employee) => DataRow(
                                    cells: [
                                      DataCell(Text(employee.name)),
                                      DataCell(Text(employee.tel ?? '')),
                                      const DataCell(Text('Occupé')),
                                    ],
                                  ),
                                )
                                .toList(),
                      ),
                    );
                  }

                  return const Center(child: Text('Error loading employees'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
