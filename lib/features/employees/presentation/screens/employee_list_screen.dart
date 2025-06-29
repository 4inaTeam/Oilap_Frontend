import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/core/constants/app_colors.dart';
import 'package:oilab_frontend/features/employees/presentation/bloc/employee_bloc.dart';
import 'package:oilab_frontend/features/employees/presentation/bloc/employee_event.dart';
import 'package:oilab_frontend/features/employees/presentation/bloc/employee_state.dart';
import 'package:oilab_frontend/features/employees/presentation/screens/employee_add_dialog.dart';
import 'package:oilab_frontend/features/employees/presentation/screens/employee_update_dialog.dart';
import 'package:oilab_frontend/shared/dialogs/error_dialog.dart';
import 'package:oilab_frontend/shared/dialogs/success_dialog.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<EmployeeBloc>().add(LoadEmployees());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (!mounted) return;
    setState(() => _currentSearchQuery = query);

    final event =
        query.isEmpty ? LoadEmployees() : SearchEmployees(query: query);
    context.read<EmployeeBloc>().add(event);
  }

  void _changePage(int page) {
    if (!mounted) return;
    context.read<EmployeeBloc>().add(
      ChangePage(
        page,
        currentSearchQuery:
            _currentSearchQuery.isEmpty ? null : _currentSearchQuery,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: '/employees', 
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          return Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Column(
              children: [
                SizedBox(height: isMobile ? 12 : 16),
                _SearchSection(
                  controller: _searchController,
                  onSearch: _performSearch,
                  currentQuery: _currentSearchQuery,
                  isMobile: isMobile,
                ),
                SizedBox(height: isMobile ? 16 : 24),
                Expanded(child: _EmployeeContent(isMobile: isMobile)),
                _PaginationFooter(
                  isMobile: isMobile,
                  onPageChange: _changePage,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Rest of your existing code remains the same...
class _SearchSection extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final String currentQuery;
  final bool isMobile;

  const _SearchSection({
    required this.controller,
    required this.onSearch,
    required this.currentQuery,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final searchField = TextField(
      controller: controller,
      onChanged: (value) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (controller.text == value) onSearch(value.trim());
        });
      },
      onSubmitted: (value) => onSearch(value.trim()),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Rechercher par CIN',
        prefixIcon: const Icon(Icons.search),
        suffixIcon:
            currentQuery.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    onSearch('');
                  },
                )
                : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    final addButton = SizedBox(
      width: isMobile ? double.infinity : null,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          iconColor: Colors.white,
          backgroundColor: AppColors.accentGreen,
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 14 : 12,
            horizontal: 16,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed:
            () => showDialog(
              context: context,
              builder: (context) => const EmployeeAddDialog(),
            ),
        icon: Image.asset('assets/icons/Vector.png', width: 16, height: 16),
        label: const Text(
          'Ajouter un nouveau',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

    return isMobile
        ? Column(children: [searchField, const SizedBox(height: 12), addButton])
        : Row(
          children: [
            Expanded(flex: 3, child: searchField),
            const SizedBox(width: 16),
            addButton,
          ],
        );
  }
}

class _EmployeeContent extends StatelessWidget {
  final bool isMobile;

  const _EmployeeContent({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeBloc, EmployeeState>(
      builder: (context, state) {
        if (state is EmployeeInitial || state is EmployeeLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is EmployeeLoadSuccess) {
          return state.employees.isEmpty
              ? const _EmptyState()
              : _EmployeeTable(employees: state.employees, isMobile: isMobile);
        }

        if (state is EmployeeOperationFailure) {
          return _ErrorState(message: state.message);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Aucun employé trouvé',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Erreur: $message',
            style: TextStyle(fontSize: 16, color: Colors.red.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<EmployeeBloc>().add(LoadEmployees()),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

class _EmployeeTable extends StatelessWidget {
  final List<dynamic> employees;
  final bool isMobile;

  const _EmployeeTable({required this.employees, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox.expand(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  columnSpacing: isMobile ? 10 : 56.0,
                  horizontalMargin: isMobile ? 8 : 24,
                  headingRowHeight: isMobile ? 48 : 60,
                  dataRowHeight: isMobile ? 48 : 60,
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Nom',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Tél',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Email',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'CIN',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Statut',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Action',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows:
                      employees.map((employee) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                employee.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DataCell(
                              Text(
                                employee.tel ?? '',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DataCell(
                              Text(
                                employee.email,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DataCell(
                              Text(
                                employee.cin,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          employee.isActive
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    employee.isActive ? 'Active' : 'Inactive',
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              _ActionButtons(
                                employee: employee,
                                isMobile: isMobile,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final dynamic employee;
  final bool isMobile;

  const _ActionButtons({required this.employee, this.isMobile = false});

  void _confirmDeletion(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => ErrorDialog(
            title: 'Confirmation de suppression',
            message: 'Êtes-vous sûr de vouloir supprimer cet employé ?',
            onConfirm: () {
              context.read<EmployeeBloc>().add(DeleteEmployee(employee.id));
              Navigator.pop(context);
              showDialog(
                context: context,
                builder:
                    (context) => const SuccessDialog(
                      title: 'Succès',
                      message: 'L\'employé a été supprimé avec succès',
                    ),
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = isMobile ? 20.0 : 24.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit, color: Colors.green, size: iconSize),
          onPressed:
              () => showDialog(
                context: context,
                builder: (context) => EmployeeUpdateDialog(employee: employee),
              ),
        ),
        if (!isMobile) ...[
          const SizedBox(width: 5),
          Text('|', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(width: 5),
        ],
        IconButton(
          icon: Icon(Icons.delete, color: AppColors.delete, size: iconSize),
          onPressed: () => _confirmDeletion(context),
        ),
      ],
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  final bool isMobile;
  final Function(int) onPageChange;

  const _PaginationFooter({required this.isMobile, required this.onPageChange});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeBloc, EmployeeState>(
      builder: (context, state) {
        if (state is! EmployeeLoadSuccess || state.totalPages <= 1) {
          return const SizedBox.shrink();
        }

        final startItem = (state.currentPage - 1) * state.pageSize + 1;
        final endItem = (state.currentPage * state.pageSize).clamp(
          0,
          state.totalEmployees,
        );

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child:
              isMobile
                  ? Column(
                    children: [
                      Text(
                        'Page ${state.currentPage} sur ${state.totalPages}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      _PaginationControls(
                        state: state,
                        onPageChange: onPageChange,
                      ),
                    ],
                  )
                  : Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Affichage $startItem à $endItem sur ${state.totalEmployees} employés',
                          style: TextStyle(
                            color: AppColors.parametereColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      _PaginationControls(
                        state: state,
                        onPageChange: onPageChange,
                      ),
                    ],
                  ),
        );
      },
    );
  }
}

class _PaginationControls extends StatelessWidget {
  final EmployeeLoadSuccess state;
  final Function(int) onPageChange;

  const _PaginationControls({required this.state, required this.onPageChange});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed:
              state.currentPage > 1
                  ? () => onPageChange(state.currentPage - 1)
                  : null,
          icon: const Icon(Icons.chevron_left),
        ),
        ...List.generate((state.totalPages).clamp(0, 5), (index) {
          final pageNum = index + 1;
          final isActive = pageNum == state.currentPage;

          return GestureDetector(
            onTap: () => onPageChange(pageNum),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? AppColors.mainColor : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border:
                    !isActive ? Border.all(color: Colors.grey.shade300) : null,
              ),
              child: Text(
                '$pageNum',
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.textColor,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
        IconButton(
          onPressed:
              state.currentPage < state.totalPages
                  ? () => onPageChange(state.currentPage + 1)
                  : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
