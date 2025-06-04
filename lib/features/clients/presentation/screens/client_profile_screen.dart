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

  // Enhanced breakpoint definitions
  bool _isMobile(double width) => width < 768;
  bool _isTablet(double width) => width >= 768 && width < 1024;
  bool _isDesktop(double width) => width >= 1024;

  // Responsive padding helper
  EdgeInsets _getResponsivePadding(double screenWidth) {
    if (_isMobile(screenWidth)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    } else if (_isTablet(screenWidth)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    }
  }

  // Responsive font size helper
  double _getResponsiveFontSize(
    double screenWidth, {
    double mobile = 14,
    double tablet = 16,
    double desktop = 18,
  }) {
    if (_isMobile(screenWidth)) return mobile;
    if (_isTablet(screenWidth)) return tablet;
    return desktop;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClientBloc, ClientState>(
      listener: (context, state) {
        if (state is ClientOperationFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;

            // Show loading state
            if (state is ClientLoading) {
              return AppLayout(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            // Show the actual profile content
            if (state is ClientProfileLoaded) {
              final clientProducts = state.products ?? [];
              return _buildContent(
                state.client,
                clientProducts,
                screenWidth,
                constraints,
              );
            }

            // Show error state
            if (state is ClientOperationFailure) {
              return AppLayout(
                child: _buildErrorState(state.message, screenWidth),
              );
            }

            return AppLayout(child: Center(child: CircularProgressIndicator()));
          },
        );
      },
    );
  }

  Widget _buildErrorState(String message, double screenWidth) {
    return Center(
      child: Padding(
        padding: _getResponsivePadding(screenWidth),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: _isMobile(screenWidth) ? 48 : 64,
              color: Colors.red.shade400,
            ),
            SizedBox(height: _isMobile(screenWidth) ? 12 : 16),
            Text(
              'Error Loading Profile',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(
                  screenWidth,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: _getResponsiveFontSize(
                  screenWidth,
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
              ),
            ),
            SizedBox(height: _isMobile(screenWidth) ? 12 : 16),
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

  Widget _buildContent(
    User user,
    List<Product> products,
    double screenWidth,
    BoxConstraints constraints,
  ) {
    final stats = _calculateStatsFromProducts(products);

    return AppLayout(
      child: SingleChildScrollView(
        child: Padding(
          padding: _getResponsivePadding(screenWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, screenWidth),
              SizedBox(height: _isMobile(screenWidth) ? 16 : 24),
              _buildProfileSection(user, screenWidth),
              SizedBox(height: _isMobile(screenWidth) ? 20 : 32),
              _buildStatsSection(stats, screenWidth),
              SizedBox(height: _isMobile(screenWidth) ? 20 : 32),
              _buildProductsSection(
                context,
                products,
                screenWidth,
                constraints,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double screenWidth) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: _getResponsiveFontSize(
              screenWidth,
              mobile: 24,
              tablet: 28,
              desktop: 32,
            ),
          ),
          onPressed: () {
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
              fontSize: _getResponsiveFontSize(
                screenWidth,
                mobile: 18,
                tablet: 22,
                desktop: 28,
              ),
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.notifications_none,
            size: _getResponsiveFontSize(
              screenWidth,
              mobile: 20,
              tablet: 24,
              desktop: 28,
            ),
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

  Widget _buildEmptyState(double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_isMobile(screenWidth) ? 24 : 40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: _isMobile(screenWidth) ? 48 : 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: _isMobile(screenWidth) ? 12 : 16),
          Text(
            'Aucun produit trouvé',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                screenWidth,
                mobile: 16,
                tablet: 18,
                desktop: 18,
              ),
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Ce client n\'a pas encore de produits dans le système.',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                screenWidth,
                mobile: 12,
                tablet: 14,
                desktop: 14,
              ),
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(User user, double screenWidth) {
    return Column(
      children: [
        // Factures button - responsive positioning
        if (_isDesktop(screenWidth))
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [_buildFacturesButton(screenWidth)],
          )
        else
          Center(child: _buildFacturesButton(screenWidth)),

        SizedBox(height: _isMobile(screenWidth) ? 12 : 16),

        // Profile avatar and info
        Center(
          child: Column(
            children: [
              _buildProfileAvatar(user, screenWidth),
              SizedBox(height: _isMobile(screenWidth) ? 12 : 16),
              _buildUserName(user, screenWidth),
              SizedBox(height: _isMobile(screenWidth) ? 8 : 12),
              _buildContactInfo(user, screenWidth),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFacturesButton(double screenWidth) {
    return ElevatedButton.icon(
      icon: Icon(
        Icons.folder,
        size: _isMobile(screenWidth) ? 16 : 18,
        color: Colors.white,
      ),
      label: Text(
        'Factures',
        style: TextStyle(
          fontSize: _getResponsiveFontSize(
            screenWidth,
            mobile: 12,
            tablet: 14,
            desktop: 14,
          ),
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentGreen,
        padding: EdgeInsets.symmetric(
          horizontal: _isMobile(screenWidth) ? 12 : 20,
          vertical: _isMobile(screenWidth) ? 8 : 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {
        // TODO: navigate to invoices
      },
    );
  }

  Widget _buildProfileAvatar(User user, double screenWidth) {
    final avatarSize =
        _isMobile(screenWidth)
            ? 70.0
            : _isTablet(screenWidth)
            ? 85.0
            : 100.0;

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.accentGreen, AppColors.accentYellow],
        ),
        border: Border.all(color: Colors.transparent, width: 3),
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        child: ClipOval(
          child:
              user.profilePhotoUrl != null
                  ? Image.network(
                    'http://127.0.0.1:8000${user.profilePhotoUrl}',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        size: avatarSize * 0.6,
                        color: Colors.grey.shade600,
                      );
                    },
                  )
                  : Icon(
                    Icons.person,
                    size: avatarSize * 0.6,
                    color: Colors.grey.shade600,
                  ),
        ),
      ),
    );
  }

  Widget _buildUserName(User user, double screenWidth) {
    return Text(
      user.name,
      style: TextStyle(
        fontSize: _getResponsiveFontSize(
          screenWidth,
          mobile: 18,
          tablet: 22,
          desktop: 24,
        ),
        fontWeight: FontWeight.w900,
        color: AppColors.textColor,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildContactInfo(User user, double screenWidth) {
    final contactInfoStyle = TextStyle(
      fontSize: _getResponsiveFontSize(
        screenWidth,
        mobile: 11,
        tablet: 12,
        desktop: 14,
      ),
      color: Colors.grey.shade600,
    );

    // Stack contact info vertically on mobile for better readability
    if (_isMobile(screenWidth)) {
      return Column(
        children: [
          Text(user.tel ?? 'N/A', style: contactInfoStyle),
          SizedBox(height: 4),
          Text(user.email, style: contactInfoStyle),
          SizedBox(height: 4),
          Text(user.role, style: contactInfoStyle),
        ],
      );
    }

    // Horizontal layout for tablet and desktop
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: _isTablet(screenWidth) ? 16 : 24,
      runSpacing: 8,
      children: [
        Text(user.tel ?? 'N/A', style: contactInfoStyle),
        Text(user.email, style: contactInfoStyle),
        Text(user.role, style: contactInfoStyle),
      ],
    );
  }

  Widget _buildStatsSection(Map<String, String> stats, double screenWidth) {
    // On mobile, use 2x2 grid instead of single row
    if (_isMobile(screenWidth)) {
      final statEntries = stats.entries.toList();
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: _buildStatCard(statEntries[0], screenWidth),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: _buildStatCard(statEntries[1], screenWidth),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: _buildStatCard(statEntries[2], screenWidth),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: _buildStatCard(statEntries[3], screenWidth),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Single row for tablet and desktop
    return Row(
      children:
          stats.entries
              .map(
                (e) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildStatCard(e, screenWidth),
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildStatCard(MapEntry<String, String> stat, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(_isMobile(screenWidth) ? 12 : 16),
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              stat.value,
              style: TextStyle(
                fontSize: _getResponsiveFontSize(
                  screenWidth,
                  mobile: 14,
                  tablet: 16,
                  desktop: 18,
                ),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 6),
          Text(
            stat.key,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                screenWidth,
                mobile: 10,
                tablet: 11,
                desktop: 12,
              ),
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
    double screenWidth,
    BoxConstraints constraints,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historique des produits',
          style: TextStyle(
            fontSize: _getResponsiveFontSize(
              screenWidth,
              mobile: 16,
              tablet: 20,
              desktop: 22,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: _isMobile(screenWidth) ? 12 : 16),
        if (products.isEmpty)
          _buildEmptyState(screenWidth)
        else
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: EdgeInsets.all(_isMobile(screenWidth) ? 8 : 16),
              child: ClientHistoryWidget(
                products: products,
                constraints: BoxConstraints(
                  maxWidth:
                      constraints.maxWidth - (_isMobile(screenWidth) ? 48 : 64),
                ),
                isMobile: _isMobile(screenWidth),
                isTablet: _isTablet(screenWidth),
                isDesktop: _isDesktop(screenWidth),
              ),
            ),
          ),
      ],
    );
  }
}
