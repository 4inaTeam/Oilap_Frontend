import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/core/constants/app_colors.dart';
import 'package:oilab_frontend/core/models/user_model.dart';
import 'package:oilab_frontend/features/clients/presentation/bloc/client_bloc.dart';
import 'package:oilab_frontend/features/clients/presentation/bloc/client_event.dart';
import 'package:oilab_frontend/features/clients/presentation/bloc/client_state.dart';
import 'package:oilab_frontend/shared/widgets/app_layout.dart';

class ClientProfileScreen extends StatefulWidget {
  final int clientId;
  const ClientProfileScreen({Key? key, required this.clientId})
    : super(key: key);

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ClientBloc>().add(ViewClientProfile(widget.clientId));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;
    final isDesktop = screenWidth > 1200;

    final stats = {
      'Quantité entrée': '800 Kg',
      'Litres produits': '132,4 L',
      'Montant dépensé': '800 DT',
      'Dernière visite': '12/01/2025',
    };

    final history = [
      {
        'entrée': '12/01/2025\n09:45',
        'estimé': '30:05',
        'sortie': '12/01/2025\n10:15',
        'ville': 'Tunis',
        'statut': 'En cours',
        'quantité': '400 Kg',
        'prix': '400 DT',
      },
      {
        'entrée': '12/12/2024\n09:45',
        'estimé': '30:05',
        'sortie': '12/12/2024\n10:15',
        'ville': 'Sfax',
        'statut': 'Fini',
        'quantité': '400 Kg',
        'prix': '400 DT',
      },
    ];

    return BlocConsumer<ClientBloc, ClientState>(
      listener: (context, state) {
        if (state is ClientOperationFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is ClientProfileLoaded) {
          return _buildContent(
            state.client,
            stats,
            history,
            isMobile,
            isTablet,
            isDesktop,
          );
        }

        if (state is ClientOperationFailure) {
          return AppLayout(
            child: Center(child: Text('Error: ${state.message}')),
          );
        }

        return AppLayout(child: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _buildContent(
    User user,
    Map<String, String> stats,
    List<Map<String, String>> history,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    return AppLayout(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : (isTablet ? 24 : 16),
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, isMobile, isTablet),
                  SizedBox(height: isMobile ? 20 : (isTablet ? 28 : 32)),
                  _buildProfileSection(user, isMobile, isTablet, isDesktop),
                  SizedBox(height: isMobile ? 24 : (isTablet ? 32 : 40)),
                  _buildStatsSection(stats, isMobile, isTablet, isDesktop),
                  SizedBox(height: isMobile ? 24 : (isTablet ? 32 : 40)),
                  _buildHistorySection(
                    context,
                    history,
                    isMobile,
                    isTablet,
                    constraints,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile, bool isTablet) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: isMobile ? 24 : (isTablet ? 28 : 32),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Client Profile',
            style: TextStyle(
              fontSize: isMobile ? 18 : (isTablet ? 22 : 28),
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.notifications_none,
            size: isMobile ? 20 : (isTablet ? 24 : 28),
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildProfileSection(
    User user,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.folder, size: isMobile ? 16 : 18, color: Colors.white,),
                    label: Text(
                      'Factures',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGreen,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : (isTablet ? 20 : 24),
                        vertical: isMobile ? 8 : (isTablet ? 12 : 14),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // TODO: navigate to invoices
                    },
                  ),
                ],
              ),
              CircleAvatar(
                radius: isDesktop ? 50 : (isTablet ? 45 : 32),
                backgroundColor: AppColors.accentYellow,
                backgroundImage:
                    user.profileImageUrl != null
                        ? NetworkImage(user.profileImageUrl!)
                        : null,
                child:
                    user.profileImageUrl == null
                        ? Icon(
                          Icons.person,
                          size: isDesktop ? 60 : (isTablet ? 54 : 38),
                          color: Colors.grey,
                        )
                        : null,
              ),
              SizedBox(height: 16),
              Text(
                user.name,
                style: TextStyle(
                  fontSize: isDesktop ? 28 : (isTablet ? 20 : 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tel: ${user.tel}',
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'CIN: ${user.cin}',
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
      ],
    );
  }

  Widget _buildStatsSection(
    Map<String, String> stats,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    if (isDesktop) {
      return Row(
        children:
            stats.entries
                .map(
                  (e) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _buildStatCard(e, isMobile, isTablet, isDesktop),
                    ),
                  ),
                )
                .toList(),
      );
    } else if (isTablet) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children:
            stats.entries
                .map((e) => _buildStatCard(e, isMobile, isTablet, isDesktop))
                .toList(),
      );
    } else {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 2.0,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children:
            stats.entries
                .map((e) => _buildStatCard(e, isMobile, isTablet, isDesktop))
                .toList(),
      );
    }
  }

  Widget _buildStatCard(
    MapEntry<String, String> stat,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 6 : (isTablet ? 10 : 12)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            child: Text(
              stat.value,
              style: TextStyle(
                fontSize: isMobile ? 12 : (isTablet ? 16 : 18),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: isMobile ? 2 : (isTablet ? 4 : 6)),
          Text(
            stat.key,
            style: TextStyle(
              fontSize: isMobile ? 8 : (isTablet ? 10 : 12),
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(
    BuildContext context,
    List<Map<String, String>> history,
    bool isTablet,
    bool isDesktop,
    BoxConstraints constraints,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historique des visites',
          style: TextStyle(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (isDesktop)
          _buildDesktopTable(history)
        else if (isTablet)
          _buildTabletTable(history)
        else
          _buildMobileCards(history),
      ],
    );
  }

  // Keep all table and card building methods exactly as in your original code
  // ...
}

Widget _buildDesktopTable(List<Map<String, String>> history) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      columnSpacing: 20,
      headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
      columns: const [
        DataColumn(label: Text('Temp d\'entrée')),
        DataColumn(label: Text('Temps estimé')),
        DataColumn(label: Text('Temp de sortie')),
        DataColumn(label: Text('Ville')),
        DataColumn(label: Text('Statut')),
        DataColumn(label: Text('Quantity')),
        DataColumn(label: Text('Prix total')),
        DataColumn(label: Text('Action')),
      ],
      rows: history.map((item) => _buildDataRow(item, false)).toList(),
    ),
  );
}

Widget _buildTabletTable(List<Map<String, String>> history) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      columnSpacing: 16,
      headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
      columns: const [
        DataColumn(label: Text('Entrée')),
        DataColumn(label: Text('Ville')),
        DataColumn(label: Text('Statut')),
        DataColumn(label: Text('Quantité')),
        DataColumn(label: Text('Prix')),
        DataColumn(label: Text('Action')),
      ],
      rows: history.map((item) => _buildSimplifiedDataRow(item)).toList(),
    ),
  );
}

Widget _buildMobileCards(List<Map<String, String>> history) {
  return Column(
    children: history.map((item) => _buildMobileCard(item)).toList(),
  );
}

Widget _buildMobileCard(Map<String, String> item) {
  final isDone = item['statut'] == 'Fini';
  final dotColor = isDone ? AppColors.accentGreen : AppColors.accentYellow;

  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item['ville']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  CircleAvatar(radius: 6, backgroundColor: dotColor),
                  const SizedBox(width: 6),
                  Text(item['statut']!),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Entrée: ${item['entrée']!.split('\n')[0]}'),
              Text('Quantité: ${item['quantité']!}'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sortie: ${item['sortie']!.split('\n')[0]}'),
              Text('Prix: ${item['prix']!}'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18, color: Colors.green),
                onPressed: () {
                  // TODO: edit this entry
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                onPressed: () {
                  // TODO: remove this entry
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.visibility,
                  size: 18,
                  color: Colors.blue,
                ),
                onPressed: () {
                  // TODO: view details
                },
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

DataRow _buildDataRow(Map<String, String> item, bool isCompact) {
  final isDone = item['statut'] == 'Fini';
  final dotColor = isDone ? AppColors.accentGreen : AppColors.accentYellow;

  return DataRow(
    cells: [
      DataCell(
        SizedBox(
          width: 80,
          child: Text(
            item['entrée']!,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ),
      DataCell(Text(item['estimé']!, style: const TextStyle(fontSize: 12))),
      DataCell(
        SizedBox(
          width: 80,
          child: Text(
            item['sortie']!,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ),
      DataCell(Text(item['ville']!, style: const TextStyle(fontSize: 12))),
      DataCell(
        SizedBox(
          width: 80,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 4, backgroundColor: dotColor),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  item['statut']!,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
      DataCell(Text(item['quantité']!, style: const TextStyle(fontSize: 12))),
      DataCell(Text(item['prix']!, style: const TextStyle(fontSize: 12))),
      DataCell(SizedBox(width: 120, child: _buildActionButtons())),
    ],
  );
}

DataRow _buildSimplifiedDataRow(Map<String, String> item) {
  final isDone = item['statut'] == 'Fini';
  final dotColor = isDone ? AppColors.accentGreen : AppColors.accentYellow;

  return DataRow(
    cells: [
      DataCell(
        SizedBox(
          width: 70,
          child: Text(
            item['entrée']!.split('\n')[0],
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      DataCell(
        SizedBox(
          width: 60,
          child: Text(
            item['ville']!,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      DataCell(
        SizedBox(
          width: 70,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 4, backgroundColor: dotColor),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  item['statut']!,
                  style: const TextStyle(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
      DataCell(
        SizedBox(
          width: 60,
          child: Text(
            item['quantité']!,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      DataCell(
        SizedBox(
          width: 50,
          child: Text(
            item['prix']!,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      DataCell(SizedBox(width: 100, child: _buildActionButtons(compact: true))),
    ],
  );
}

Widget _buildActionButtons({bool compact = false}) {
  final iconSize = compact ? 14.0 : 16.0;
  final padding = compact ? 4.0 : 8.0;

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        width: iconSize + padding,
        height: iconSize + padding,
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(Icons.edit, size: iconSize, color: Colors.green),
          onPressed: () {
            // TODO: edit this entry
          },
        ),
      ),
      SizedBox(
        width: iconSize + padding,
        height: iconSize + padding,
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(Icons.delete, size: iconSize, color: Colors.red),
          onPressed: () {
            // TODO: remove this entry
          },
        ),
      ),
      SizedBox(
        width: iconSize + padding,
        height: iconSize + padding,
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(Icons.visibility, size: iconSize, color: Colors.blue),
          onPressed: () {
            // TODO: view details
          },
        ),
      ),
    ],
  );
}
