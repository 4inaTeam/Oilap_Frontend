import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:oilab_frontend/shared/widgets/app_layout.dart';
import 'package:oilab_frontend/core/constants/app_colors.dart';

import 'package:oilab_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:oilab_frontend/features/auth/presentation/bloc/auth_state.dart';

import 'package:oilab_frontend/features/employees/presentation/bloc/employee_bloc.dart';

import 'package:oilab_frontend/features/employees/presentation/bloc/employee_state.dart';
import 'package:oilab_frontend/features/employees/presentation/screens/emplouee_add_dialoge.dart';

import 'package:oilab_frontend/features/dashboard/presentation/screens/dashboard_screen.dart';

class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthLoadSuccess) {
      return const Scaffold(
        body: Center(child: Text('Veuillez vous connecter.')),
      );
    }

    return _EmployeeListView();
  }
}

class _EmployeeListView extends StatelessWidget {
  const _EmployeeListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return AppLayout(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isMobile)
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 28),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const DashboardScreen(),
                        ),
                      );
                    },
                  ),
                if (!isMobile) const SizedBox(width: 8),
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

            Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                if (!isMobile) const SizedBox(width: 16),
                if (isMobile) const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    iconColor: Colors.white,
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
                    showDialog(
                      context: context,
                      builder: (_) => const EmployeeAddDialog(),
                    );
                  },
                  icon: Image.asset(
                    'assets/icons/Vector.png',
                    width: 16,
                    height: 16,
                  ),
                  label: const Text(
                    'Ajouter un nouveau',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child: BlocBuilder<EmployeeBloc, EmployeeState>(
                builder: (ctx, state) {
                  if (state is EmployeeLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is EmployeeLoadSuccess) {
                    final rows =
                        state.employees.map((u) {
                          return DataRow(
                            cells: [
                              DataCell(Text(u.username)),
                              DataCell(Text(u.tel)),
                              DataCell(Text(u.email)),
                              DataCell(Text(u.cin)),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {},
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '|',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList();

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Nom')),
                          DataColumn(label: Text('Tél')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('CIN')),
                          DataColumn(label: Text('Action')),
                        ],
                        rows: rows,
                      ),
                    );
                  } else if (state is EmployeeOperationFailure) {
                    return Center(child: Text('Erreur: ${state.message}'));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Affichage des données 1 à 8 sur 200 000 employés',
                      style: TextStyle(
                        color: AppColors.parametereColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      IconButton(
                        onPressed: null,
                        icon: Icon(Icons.chevron_left),
                      ),
                      _PageNumber(1, isActive: true),
                      _PageNumber(2),
                      _PageNumber(3),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text('…', style: TextStyle(fontSize: 16)),
                      ),
                      _PageNumber(40),
                      IconButton(
                        onPressed: null,
                        icon: Icon(Icons.chevron_right),
                      ),
                    ],
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
  const _PageNumber(this.number, {this.isActive = false, Key? key})
    : super(key: key);

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
