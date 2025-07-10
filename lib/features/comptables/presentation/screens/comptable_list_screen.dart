import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/core/constants/app_colors.dart';
import 'package:oilab_frontend/features/comptables/presentation/bloc/comptable_bloc.dart';
import 'package:oilab_frontend/features/comptables/presentation/bloc/comptable_event.dart';
import 'package:oilab_frontend/features/comptables/presentation/bloc/comptable_state.dart';
import 'package:oilab_frontend/features/comptables/presentation/screens/comptable_add_dialoge.dart';
import 'package:oilab_frontend/features/comptables/presentation/screens/comptable_update_dialoge.dart';
import 'package:oilab_frontend/shared/widgets/app_layout.dart';

class ComptableListScreen extends StatelessWidget {
  const ComptableListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _ComptableListView();
  }
}

class _ComptableListView extends StatefulWidget {
  const _ComptableListView({Key? key}) : super(key: key);

  @override
  __ComptableListViewState createState() => __ComptableListViewState();
}

class __ComptableListViewState extends State<_ComptableListView> {
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ComptableBloc>().add(LoadComptables());
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
        query.isEmpty ? LoadComptables() : SearchComptables(query: query);
    context.read<ComptableBloc>().add(event);
  }

  void _changePage(int page) {
    if (!mounted) return;
    context.read<ComptableBloc>().add(
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
      currentRoute: '/comptables',
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
                Expanded(child: _ComptableContent(isMobile: isMobile)),
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
              builder: (context) => const ComptableAddDialog(),
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

class _ComptableContent extends StatelessWidget {
  final bool isMobile;

  const _ComptableContent({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ComptableBloc, ComptableState>(
      builder: (context, state) {
        if (state is ComptableInitial || state is ComptableLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ComptableLoadSuccess) {
          return state.comptables.isEmpty
              ? const _EmptyState()
              : _ComptableTable(
                comptables: state.comptables,
                isMobile: isMobile,
              );
        }

        if (state is ComptableOperationFailure) {
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
            'Aucun comptable trouvé',
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
            onPressed:
                () => context.read<ComptableBloc>().add(LoadComptables()),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

class _ComptableTable extends StatelessWidget {
  final List<dynamic> comptables;
  final bool isMobile;

  const _ComptableTable({required this.comptables, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      // Mobile-optimized table with selective columns
      return _buildMobileTable(context);
    } else {
      // Desktop table with all columns
      return _buildDesktopTable(context);
    }
  }

  Widget _buildMobileTable(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                maxWidth:
                    constraints.maxWidth * 1.2, // Allow some horizontal scroll
              ),
              child: DataTable(
                columnSpacing: 12,
                horizontalMargin: 8,
                headingRowHeight: 36,
                dataRowHeight: 48,
                showCheckboxColumn: false,
                columns: const [
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'Nom',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'CIN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'Tél',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'Actions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                rows:
                    comptables.map((comptable) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Tooltip(
                              message: comptable.name,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: constraints.maxWidth * 0.3,
                                ),
                                child: Text(
                                  comptable.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth * 0.25,
                              ),
                              child: Text(
                                comptable.cin,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth * 0.25,
                              ),
                              child: Text(
                                comptable.tel ?? '-',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                          DataCell(
                            _CompactMobileActionButtons(comptable: comptable),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(BuildContext context) {
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
                  columnSpacing: 56.0,
                  horizontalMargin: 24,
                  headingRowHeight: 60,
                  dataRowHeight: 60,
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Nom',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Tél',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Email',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'CIN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Statut',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Action',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                  rows:
                      comptables.map((comptable) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                comptable.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            DataCell(
                              Text(
                                comptable.tel ?? '',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            DataCell(
                              Text(
                                comptable.email,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            DataCell(
                              Text(
                                comptable.cin,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            DataCell(
                              _buildStatusChip(comptable.isActive, false),
                            ),
                            DataCell(
                              _ActionButtons(
                                comptable: comptable,
                                isMobile: false,
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

  Widget _buildStatusChip(bool isActive, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 6 : 8,
        vertical: isMobile ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color:
            isActive
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.green : Colors.red,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isMobile ? 4 : 6,
            height: isMobile ? 4 : 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.green : Colors.red,
            ),
          ),
          SizedBox(width: isMobile ? 3 : 4),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: isMobile ? 9 : 12,
              color: isActive ? Colors.green[700] : Colors.red[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactMobileActionButtons extends StatelessWidget {
  final dynamic comptable;

  const _CompactMobileActionButtons({required this.comptable});

  void _confirmDeletion(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: const Text(
              'Êtes-vous sûr de vouloir supprimer ce comptable?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  context.read<ComptableBloc>().add(
                    DeleteComptable(comptable.id),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap:
              () => showDialog(
                context: context,
                builder:
                    (context) => ComptableUpdateDialog(comptable: comptable),
              ),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.all(6),
            child: const Icon(Icons.edit, color: Colors.green, size: 16),
          ),
        ),
        const SizedBox(width: 4),
        InkWell(
          onTap: () => _confirmDeletion(context),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.all(6),
            child: Icon(Icons.delete, color: AppColors.delete, size: 16),
          ),
        ),
      ],
    );
  }
}

// ignore: unused_element
class _MobileActionButtons extends StatelessWidget {
  final dynamic comptable;

  const _MobileActionButtons({required this.comptable});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18),
      onSelected: (value) {
        if (value == 'edit') {
          showDialog(
            context: context,
            builder: (context) => ComptableUpdateDialog(comptable: comptable),
          );
        } else if (value == 'delete') {
          _confirmDeletion(context);
        }
      },
      itemBuilder:
          (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Text('Modifier', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppColors.delete, size: 16),
                  const SizedBox(width: 8),
                  const Text('Supprimer', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
    );
  }

  void _confirmDeletion(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: const Text(
              'Êtes-vous sûr de vouloir supprimer ce comptable?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  context.read<ComptableBloc>().add(
                    DeleteComptable(comptable.id),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final dynamic comptable;
  final bool isMobile;

  const _ActionButtons({required this.comptable, this.isMobile = false});

  void _confirmDeletion(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: const Text(
              'Êtes-vous sûr de vouloir supprimer ce comptable?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  context.read<ComptableBloc>().add(
                    DeleteComptable(comptable.id),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = isMobile ? 18.0 : 24.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          constraints:
              isMobile
                  ? const BoxConstraints(minWidth: 32, minHeight: 32)
                  : const BoxConstraints(minWidth: 48, minHeight: 48),
          padding: isMobile ? const EdgeInsets.all(4) : const EdgeInsets.all(8),
          icon: Icon(Icons.edit, color: Colors.green, size: iconSize),
          onPressed:
              () => showDialog(
                context: context,
                builder:
                    (context) => ComptableUpdateDialog(comptable: comptable),
              ),
        ),
        if (!isMobile) ...[
          const SizedBox(width: 5),
          Text('|', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(width: 5),
        ],
        IconButton(
          constraints:
              isMobile
                  ? const BoxConstraints(minWidth: 32, minHeight: 32)
                  : const BoxConstraints(minWidth: 48, minHeight: 48),
          padding: isMobile ? const EdgeInsets.all(4) : const EdgeInsets.all(8),
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
    return BlocBuilder<ComptableBloc, ComptableState>(
      builder: (context, state) {
        if (state is! ComptableLoadSuccess || state.totalPages <= 1) {
          return const SizedBox.shrink();
        }

        final startItem = (state.currentPage - 1) * state.pageSize + 1;
        final endItem = (state.currentPage * state.pageSize).clamp(
          0,
          state.totalComptables,
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
                        isMobile: true,
                      ),
                    ],
                  )
                  : Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Affichage $startItem à $endItem sur ${state.totalComptables} comptables',
                          style: TextStyle(
                            color: AppColors.parametereColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      _PaginationControls(
                        state: state,
                        onPageChange: onPageChange,
                        isMobile: false,
                      ),
                    ],
                  ),
        );
      },
    );
  }
}

class _PaginationControls extends StatelessWidget {
  final ComptableLoadSuccess state;
  final Function(int) onPageChange;
  final bool isMobile;

  const _PaginationControls({
    required this.state,
    required this.onPageChange,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final maxPages = isMobile ? 3 : 5; // Show fewer pages on mobile

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed:
              state.currentPage > 1
                  ? () => onPageChange(state.currentPage - 1)
                  : null,
          icon: const Icon(Icons.chevron_left),
          iconSize: isMobile ? 20 : 24,
        ),
        ...List.generate((state.totalPages).clamp(0, maxPages), (index) {
          final pageNum = index + 1;
          final isActive = pageNum == state.currentPage;

          return GestureDetector(
            onTap: () => onPageChange(pageNum),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: isMobile ? 2 : 4),
              width: isMobile ? 28 : 32,
              height: isMobile ? 28 : 32,
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
                  fontSize: isMobile ? 11 : 14,
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
          iconSize: isMobile ? 20 : 24,
        ),
      ],
    );
  }
}
