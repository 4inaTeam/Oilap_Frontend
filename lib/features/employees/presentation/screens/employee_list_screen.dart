import 'package:flutter/material.dart';
import 'package:oilab_frontend/shared/widgets/app_layout.dart';
import 'package:oilab_frontend/core/constants/app_colors.dart';
import 'package:oilab_frontend/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:oilab_frontend/features/employees/presentation/screens/emplouee_add_screen.dart';

class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return AppLayout(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isMobile)
                      IconButton(
                        icon: const Icon(Icons.arrow_back, size: 28),
                        onPressed: () {
                          Future.microtask(() {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const DashboardScreen(),
                              ),
                            );
                          });
                        },
                      ),
                    if (!isMobile) const SizedBox(width: 8),
                    const Text(
                      'Employés',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.notifications_none),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Search + Add Row
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
                        Future.microtask(() {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const EmployeeAddScreen(),
                            ),
                          );
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'Ajouter un nouveau',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Employee Table
                SizedBox(
                  height:
                      constraints.maxHeight -
                      (isMobile
                          ? 240
                          : 200), // Adjust for header/search/pagination
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: isMobile ? 12 : 24,
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
                            final names = List.filled(8, 'Moez');
                            final phones = List.filled(8, '23954780');
                            final emails =
                                names
                                    .map((n) => '${n.toLowerCase()}@gmail.com')
                                    .toList();
                            final cities = List.filled(8, 'Tunis');
                            return DataRow(
                              cells: [
                                DataCell(Text(names[i])),
                                DataCell(Text(phones[i])),
                                DataCell(Text(emails[i])),
                                DataCell(Text(cities[i])),
                                DataCell(
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Image.asset(
                                          'assets/icons/edit.png',
                                        ),
                                        onPressed: () {
                                          // TODO: edit action
                                        },
                                      ),
                                      IconButton(
                                        icon: Image.asset(
                                          'assets/icons/trash.png',
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
                  ),
                ),

                // Pagination
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
            );
          },
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
