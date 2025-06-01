import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/core/constants/app_colors.dart';
import 'package:oilab_frontend/core/models/user_model.dart';
import 'package:oilab_frontend/core/models/product_model.dart';
import 'package:oilab_frontend/features/clients/presentation/bloc/client_bloc.dart';
import 'package:oilab_frontend/features/clients/presentation/bloc/client_event.dart';
import 'package:oilab_frontend/features/clients/presentation/bloc/client_state.dart';
import 'package:oilab_frontend/features/clients/presentation/screens/client_list_screen.dart';
import 'package:oilab_frontend/features/clients/presentation/widgets/client_history_widget.dart';
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
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;
    final isDesktop = screenWidth > 1200;

    return BlocConsumer<ClientBloc, ClientState>(
      listener: (context, state) {
        if (state is ClientOperationFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        // Show loading state
        if (state is ClientLoading) {
          return AppLayout(child: Center(child: CircularProgressIndicator()));
        }

        // Show the actual profile content
        if (state is ClientProfileLoaded) {
          print('Building profile screen for client: ${state.client.name}');
          print('Products available: ${state.products?.length ?? 0}');

          final clientProducts = state.products ?? [];

          // Debug logging with null safety
          clientProducts.forEach((product) {
            print(
              'Product ${product.id}: client=${product.client}, details=${product.clientDetails}',
            );
          });

          return _buildContent(
            state.client,
            clientProducts,
            isMobile,
            isTablet,
            isDesktop,
          );
        }

        // Show error state
        if (state is ClientOperationFailure) {
          return AppLayout(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Error Loading Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ClientBloc>().add(
                        ViewClientProfile(widget.clientId),
                      );
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return AppLayout(child: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _buildContent(
    User user,
    List<Product> products,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    final stats = _calculateStatsFromProducts(products);

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
                  _buildProductsSection(
                    context,
                    products,
                    isMobile,
                    isTablet,
                    isDesktop,
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
          onPressed: () {
            // Ensure data is reloaded when returning
            context.read<ClientBloc>()
              ..add(LoadClients())
              ..add(ViewClientProfile(widget.clientId));

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ClientListScreen()),
            );
          },
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Profil Client',
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

  Map<String, String> _calculateStatsFromProducts(List<Product> products) {
    if (products.isEmpty) {
      return {
        'Total des produits': '0',
        'Valeur totale': '0 DT',
        'En cours': '0',
        'Terminé': '0',
      };
    }

    final totalProducts = products.length;
    final totalValue = products.fold<double>(
      0,
      (sum, product) => sum + (product.price ?? 0),
    );

    final pendingCount =
        products
            .where(
              (p) =>
                  p.status?.toLowerCase() == 'en cours' ||
                  p.status?.toLowerCase() == 'pending',
            )
            .length;

    final completedCount =
        products
            .where(
              (p) =>
                  p.status?.toLowerCase() == 'terminé' ||
                  p.status?.toLowerCase() == 'fini' ||
                  p.status?.toLowerCase() == 'completed' ||
                  p.status?.toLowerCase() == 'done',
            )
            .length;

    return {
      'Total des produits': totalProducts.toString(),
      'Valeur totale': '${totalValue.toStringAsFixed(2)} DT',
      'En cours': pendingCount.toString(),
      'Terminé': completedCount.toString(),
    };
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun produit trouvé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ce client n\'a pas encore de produits dans le système.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
        // Factures button positioned at top right
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              icon: Icon(
                Icons.folder,
                size: isMobile ? 16 : 18,
                color: Colors.white,
              ),
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
        SizedBox(height: 16),

        // Profile avatar and info centered
        Center(
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: isDesktop ? 50 : (isTablet ? 45 : 40),
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage:
                        user.profilePhotoUrl != null
                            ? NetworkImage(user.profilePhotoUrl!)
                            : null,
                    child:
                        user.profilePhotoUrl == null
                            ? Icon(
                              Icons.person,
                              size: isDesktop ? 60 : (isTablet ? 54 : 48),
                              color: Colors.grey.shade600,
                            )
                            : null,
                  ),
                  // Yellow border ring
                  Positioned.fill(
                    child: CircleAvatar(
                      radius: isDesktop ? 50 : (isTablet ? 45 : 40),
                      backgroundColor: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.accentYellow,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                user.name,
                style: TextStyle(
                  fontSize: isDesktop ? 24 : (isTablet ? 20 : 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),

              // Contact info in a row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user.tel ?? 'N/A',
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(width: 24),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(width: 24),
                  Text(
                    user.role,
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(
    Map<String, String> stats,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    return Row(
      children:
          stats.entries
              .map(
                (e) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _buildStatCard(e, isMobile, isTablet, isDesktop),
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildStatCard(
    MapEntry<String, String> stat,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : (isTablet ? 16 : 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            stat.value,
            style: TextStyle(
              fontSize: isMobile ? 16 : (isTablet ? 18 : 20),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            stat.key,
            style: TextStyle(
              fontSize: isMobile ? 11 : (isTablet ? 12 : 13),
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

  Widget _buildProductsSection(
    BuildContext context,
    List<Product> products,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
    BoxConstraints constraints,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historique des produits',
          style: TextStyle(
            fontSize: isMobile ? 18 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (products.isEmpty)
          _buildEmptyState()
        else
          ClientHistoryWidget(
            products: products,
            constraints: constraints,
            isMobile: isMobile,
            isTablet: isTablet,
            isDesktop: isDesktop,
          ),
      ],
    );
  }
}
