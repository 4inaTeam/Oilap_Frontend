import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/core/constants/app_colors.dart';
import 'package:oilab_frontend/features/dashboard/presentation/screens/dashboard_screen.dart';
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          return Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Column(
              children: [
                _AppBar(isMobile: isMobile),
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

class _AppBar extends StatelessWidget {
  final bool isMobile;

  const _AppBar({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!isMobile) ...[
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 28),
            onPressed:
                () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            'Comptables',
            style: TextStyle(
              fontSize: isMobile ? 20 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {},
        ),
      ],
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeDesktop = screenWidth > 1200;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: isMobile ? 10 : (isLargeDesktop ? 100.0 : 80.0),
          horizontalMargin: isMobile ? 8 : (isLargeDesktop ? 40 : 32),
          headingRowHeight: isMobile ? 48 : (isLargeDesktop ? 70 : 60),
          dataRowHeight: isMobile ? 48 : (isLargeDesktop ? 70 : 60),
          columns: [
            DataColumn(
              label: Text(
                'Nom',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 14 : (isLargeDesktop ? 18 : 16),
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Tél',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 14 : (isLargeDesktop ? 18 : 16),
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Email',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 14 : (isLargeDesktop ? 18 : 16),
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'CIN',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 14 : (isLargeDesktop ? 18 : 16),
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Action',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 14 : (isLargeDesktop ? 18 : 16),
                ),
              ),
            ),
          ],
          rows:
              comptables
                  .map(
                    (comptable) => DataRow(
                      cells: [
                        DataCell(
                          Text(comptable.name, overflow: TextOverflow.ellipsis),
                        ),
                        DataCell(
                          Text(
                            comptable.tel ?? '',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DataCell(
                          Text(
                            comptable.email,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DataCell(
                          Text(comptable.cin, overflow: TextOverflow.ellipsis),
                        ),
                        DataCell(
                          _ActionButtons(
                            comptable: comptable,
                            isMobile: isMobile,
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
        ),
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
    final iconSize = isMobile ? 20.0 : 24.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
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
