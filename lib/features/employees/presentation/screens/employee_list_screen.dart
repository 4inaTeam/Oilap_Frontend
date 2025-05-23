import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/core/constants/app_colors.dart';
import 'package:oilab_frontend/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:oilab_frontend/features/employees/presentation/bloc/employee_bloc.dart';
import 'package:oilab_frontend/features/employees/presentation/bloc/employee_event.dart';
import 'package:oilab_frontend/features/employees/presentation/bloc/employee_state.dart';
import 'package:oilab_frontend/features/employees/presentation/screens/employee_add_dialoge.dart';
import 'package:oilab_frontend/features/employees/presentation/screens/employee_update_dialoge.dart';
import 'package:oilab_frontend/shared/widgets/app_layout.dart';

class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _EmployeeListView();
  }
}

class _EmployeeListView extends StatefulWidget {
  const _EmployeeListView({Key? key}) : super(key: key);

  @override
  __EmployeeListViewState createState() => __EmployeeListViewState();
}

class __EmployeeListViewState extends State<_EmployeeListView> {
  @override
  void initState() {
    super.initState();
    context.read<EmployeeBloc>().add(LoadEmployees());
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return AppLayout(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAppBar(isMobile, context),
            const SizedBox(height: 16),
            _buildSearchAndAddButton(isMobile),
            const SizedBox(height: 24),
            _buildEmployeeTable(),
            const SizedBox(height: 16),
            _buildPaginationFooter(),
          ],
        ),
      ),
    );
  }

  void _confirmDeletion(int userId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text(
              'Are you sure you want to delete this employee?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.read<EmployeeBloc>().add(DeleteEmployee(userId));
                  Navigator.pop(context);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  Widget _buildAppBar(bool isMobile, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!isMobile)
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 28),
            onPressed:
                () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                ),
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
    );
  }

  Widget _buildSearchAndAddButton(bool isMobile) {
    return Flex(
      direction: isMobile ? Axis.vertical : Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          // Use Flexible instead of Expanded
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
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed:
              () => showDialog(
                context: context,
                builder: (context) {
                  return const EmployeeAddDialog();
                },
              ),

          icon: Image.asset('assets/icons/Vector.png', width: 16, height: 16),
          label: const Text(
            'Ajouter un nouveau',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeTable() {
    return Expanded(
      child: BlocBuilder<EmployeeBloc, EmployeeState>(
        builder: (ctx, state) {
          if (state is EmployeeInitial || state is EmployeeLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is EmployeeLoadSuccess) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth,
                      minHeight: 100,
                    ),
                    child: DataTable(
                      columnSpacing: 20,
                      columns: const [
                        DataColumn(label: Text('Nom de l\'employé')),
                        DataColumn(label: Text('Numéro de téléphone')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('CIN')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows:
                          state.employees
                              .map(
                                (u) => DataRow(
                                  cells: [
                                    DataCell(Text(u.name)),
                                    DataCell(Text(u.tel ?? '')),
                                    DataCell(Text(u.email)),
                                    DataCell(Text(u.cin)),
                                    DataCell(_buildActionButtons(u.id)),
                                  ],
                                ),
                              )
                              .toList(),
                    ),
                  ),
                );
              },
            );
          }
          if (state is EmployeeOperationFailure) {
            return Center(child: Text('Erreur: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildActionButtons(int userId) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.green),
          onPressed:
              () => showDialog(
                context: context,
                builder: (context) {
                  return const EmployeeUpdateDialog();
                },
              ),
        ),
        const SizedBox(width: 5),
        Text('|', style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(width: 5),
        IconButton(
          icon: const Icon(Icons.delete, color: AppColors.delete),
          onPressed: () => _confirmDeletion(userId),
        ),
      ],
    );
  }

  Widget _buildPaginationFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Affichage des données 1 à 8 sur 200 000 employés',
              style: TextStyle(color: AppColors.parametereColor, fontSize: 12),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              IconButton(onPressed: null, icon: Icon(Icons.chevron_left)),
              _PageNumber(1, isActive: true),
              _PageNumber(2),
              _PageNumber(3),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('…', style: TextStyle(fontSize: 16)),
              ),
              _PageNumber(40),
              IconButton(onPressed: null, icon: Icon(Icons.chevron_right)),
            ],
          ),
        ],
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
