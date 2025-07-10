import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/core/constants/consts.dart';
import 'package:oilab_frontend/features/bills/data/bill_statistics_repository.dart';
import 'package:oilab_frontend/features/clients/presentation/bloc/client_event.dart';
import 'package:oilab_frontend/features/clients/presentation/bloc/client_state.dart';
import 'package:oilab_frontend/features/dashboard/presentation/widgets/total_quantity_summarycard.dart';
import 'package:oilab_frontend/features/produits/data/product_repository.dart';
import 'package:oilab_frontend/features/produits/presentation/bloc/product_bloc.dart';
import 'package:oilab_frontend/features/produits/presentation/bloc/product_event.dart';
import 'package:oilab_frontend/features/produits/presentation/bloc/product_state.dart';
import 'package:oilab_frontend/features/clients/presentation/bloc/client_bloc.dart';
import 'package:oilab_frontend/features/clients/data/client_repository.dart';
import 'package:oilab_frontend/features/factures/presentation/bloc/facture_bloc.dart';
import 'package:oilab_frontend/features/factures/data/facture_repository.dart';

import 'package:oilab_frontend/features/dashboard/presentation/bloc/revenuBloc.dart';
import 'package:oilab_frontend/features/dashboard/presentation/bloc/revenuEvent.dart';
import 'package:oilab_frontend/features/dashboard/presentation/bloc/revenuState.dart';

import 'package:oilab_frontend/features/bills/presentation/bloc/bill_statistics_bloc.dart';
import 'package:oilab_frontend/features/bills/presentation/bloc/bill_statistics_event.dart';
import 'package:oilab_frontend/features/bills/presentation/bloc/bill_statistics_state.dart';

import 'package:oilab_frontend/features/auth/data/auth_repository.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_layout.dart';
import '../widgets/index.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ClientBloc>(
          create: (context) {
            return ClientBloc(
              ClientRepository(
                baseUrl: BackendUrls.current,
                authRepo: context.read<AuthRepository>(),
              ),
            );
          },
        ),
        BlocProvider<ProductBloc>(
          create: (context) {
            return ProductBloc(
              ProductRepository(
                baseUrl: BackendUrls.current,
                authRepo: context.read<AuthRepository>(),
              ),
            );
          },
        ),
        BlocProvider<FactureBloc>(
          create: (context) {
            return FactureBloc(
              factureRepository: FactureRepository(
                baseUrl: BackendUrls.current,
                authRepo: context.read<AuthRepository>(),
              ),
            );
          },
        ),
        BlocProvider<RevenueBloc>(
          create: (context) {
            final factureRepo = FactureRepository(
              baseUrl: BackendUrls.current,
              authRepo: context.read<AuthRepository>(),
            );
            final revenueBloc = RevenueBloc(factureRepository: factureRepo);
            revenueBloc.add(LoadRevenue());
            return revenueBloc;
          },
        ),
        BlocProvider<BillStatisticsBloc>(
          create: (context) {
            final statisticsRepo = BillStatisticsRepository(
              baseUrl: BackendUrls.current,
              authRepo: context.read<AuthRepository>(),
            );
            return BillStatisticsBloc(repository: statisticsRepo);
          },
        ),
      ],
      child: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeDashboard();
      }
    });
  }

  void _initializeDashboard() {
    if (!mounted) return;

    try {
      // Load client data
      final clientBloc = context.read<ClientBloc>();
      clientBloc.add(LoadTotalClients()); // Make sure this event exists

      final revenueBloc = context.read<RevenueBloc>();
      revenueBloc.add(LoadRevenue());

      final billStatsBloc = context.read<BillStatisticsBloc>();
      billStatsBloc.add(LoadBillStatistics());

      final productBloc = context.read<ProductBloc>();
      productBloc.add(LoadTotalQuantity());

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: '/dashboard',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile =
              MediaQuery.of(context).size.width < AppLayout.desktopBreakpoint;

          return Column(
            children: [
              Expanded(
                child:
                    _isInitialized
                        ? _buildContent(isMobile)
                        : _buildLoadingScreen(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading Dashboard...'),
        ],
      ),
    );
  }

  Widget _buildContent(bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 600;
        final isMobileLayout = width < 600;

        if (isMobileLayout) {
          return _buildMobileLayout(constraints);
        } else {
          return _buildDesktopLayout(constraints, isDesktop);
        }
      },
    );
  }

  Widget _buildMobileLayout(BoxConstraints constraints) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Summary Cards and Details in same row - FIXED LAYOUT
          SizedBox(
            height: 180, // Fixed height to prevent overflow
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards in 2x2 Grid (Left side)
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      // Row 1
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildCompactSummaryCardWithBLoC(
                                'Clients',
                                AppColors.greenLight,
                                _buildClientValue(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildCompactSummaryCardWithBLoC(
                                'Quantité',
                                AppColors.accentYellow,
                                _buildQuantityValue(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Row 2
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildCompactSummaryCardWithBLoC(
                                'Revenu',
                                AppColors.yellowLight,
                                _buildRevenueValue(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildCompactSummaryCardWithBLoC(
                                'Dépenses',
                                AppColors.greenDark,
                                _buildExpensesValue(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Details des quantités section (Right side)
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Détails des quantités',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildDetailRow(
                                'Quantité d\'olives',
                                _getOlivesQuantity(),
                              ),
                              _buildDetailRow(
                                'Huile produite',
                                _getOilProduced(),
                              ),
                              _buildDetailRow(
                                'Déchets vendus',
                                _getWasteSold(),
                              ),
                              _buildDetailRow(
                                'Déchets finaux',
                                _getFinalWaste(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Pie Chart
          _buildSafeWidget(
            () => SizedBox(height: 400, child: DynamicPieChartCard()),
          ),
          const SizedBox(height: 20),

          // Line Chart
          _buildSafeWidget(() => SizedBox(height: 300, child: LineChartCard())),
          const SizedBox(height: 20),

          // Data Tables
          _buildSafeWidget(() => SizedBox(height: 300, child: DataTableCard())),
          const SizedBox(height: 20),

          _buildSafeWidget(
            () => SizedBox(height: 300, child: EmployeeTableCard()),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BoxConstraints constraints, bool isDesktop) {
    final tableCards = [
      _buildSafeWidget(() => const DataTableCard()),
      _buildSafeWidget(() => const EmployeeTableCard()),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1000;

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7,
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildSafeWidget(
                                            () => TotalClientsSummaryCard(
                                              width: constraints.maxWidth * 0.2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildSafeWidget(
                                            () => TotalQuantitySummaryCard(
                                              width: constraints.maxWidth * 0.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildRevenueSummaryCard(
                                            context,
                                            constraints.maxWidth * 0.2,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildExpensesSummaryCard(
                                            context,
                                            constraints.maxWidth * 0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 2,
                                child: _buildSafeWidget(
                                  () => QuantityDetailsCard(
                                    width: constraints.maxWidth * 0.25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildSafeWidget(
                            () => const SizedBox(
                              height: 300,
                              child: LineChartCard(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 4,
                      child: _buildSafeWidget(
                        () =>
                            SizedBox(height: 600, child: DynamicPieChartCard()),
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildSafeWidget(
                            () => TotalClientsSummaryCard(
                              width: constraints.maxWidth * 0.45,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSafeWidget(
                            () => TotalQuantitySummaryCard(
                              width: constraints.maxWidth * 0.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildRevenueSummaryCard(
                            context,
                            constraints.maxWidth * 0.45,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildExpensesSummaryCard(
                            context,
                            constraints.maxWidth * 0.45,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isDesktop ? 2 : 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isDesktop ? 1.2 : 1,
            children: tableCards,
          ),
        ],
      ),
    );
  }

  // Compact Summary Card for Mobile Grid Layout with BLoC integration - FIXED
  Widget _buildCompactSummaryCardWithBLoC(
    String title,
    Color color,
    Widget valueWidget,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Center(child: _buildCompactValue(valueWidget, title)),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: const Text(
              '+11%',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 9,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Build compact value widget specifically for mobile cards
  Widget _buildCompactValue(Widget originalWidget, String title) {
    switch (title) {
      case 'Clients':
        return _buildCompactClientValue();
      case 'Quantité':
        return _buildCompactQuantityValue();
      case 'Revenu':
        return _buildCompactRevenueValue();
      case 'Dépenses':
        return _buildCompactExpensesValue();
      default:
        return const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        );
    }
  }

  // Compact BLoC value builders for mobile cards - FIXED WITH FittedBox
  Widget _buildCompactClientValue() {
    return BlocBuilder<ClientBloc, ClientState>(
      builder: (context, state) {
        if (!mounted) return Container();

        if (state is TotalClientsLoaded) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${state.totalClients}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          );
        } else if (state is ClientLoadSuccess) {
          // Handle ClientLoadSuccess state
          return FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${state.totalClients}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          );
        } else if (state is ClientLoading) {
          return const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 1.5),
          );
        } else if (state is ClientOperationFailure) {
          return const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Error',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          );
        }
        return const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '0',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactQuantityValue() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (!mounted) return Container();

        if (state is TotalQuantityLoaded) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${state.data.totalQuantityInt}kg',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          );
        } else if (state is ProductLoading) {
          return const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 1.5),
          );
        } else if (state is ProductOperationFailure) {
          return const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Error',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          );
        }
        return const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '0kg',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactRevenueValue() {
    return BlocBuilder<RevenueBloc, RevenueState>(
      builder: (context, state) {
        if (!mounted) return Container();

        if (state is RevenueLoaded) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${state.totalRevenue.toStringAsFixed(0)}DT',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          );
        } else if (state is RevenueLoading) {
          return const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 1.5),
          );
        } else if (state is RevenueError) {
          return const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Error',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          );
        }
        return const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '0DT',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactExpensesValue() {
    return BlocBuilder<BillStatisticsBloc, BillStatisticsState>(
      builder: (context, state) {
        if (!mounted) return Container();

        if (state is BillStatisticsLoaded) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${state.statistics.totalExpenses.toStringAsFixed(0)}DT',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          );
        } else if (state is BillStatisticsLoading) {
          return const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 1.5),
          );
        } else if (state is BillStatisticsError) {
          return const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Error',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          );
        }
        return const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '0DT',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        );
      },
    );
  }

  // Helper method to build detail rows - FIXED WITH Flexible
  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 1,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  // Safe widget wrapper to handle layout issues
  Widget _buildSafeWidget(Widget Function() builder) {
    try {
      return builder();
    } catch (e) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.grey[600]),
              const SizedBox(height: 8),
              Text(
                'Widget Error',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }
  }

  // BLoC value builders for consistent data across mobile and desktop
  Widget _buildClientValue() {
    return BlocBuilder<ClientBloc, ClientState>(
      builder: (context, state) {
        if (!mounted) return Container();

        if (state is TotalClientsLoaded) {
          return Text(
            '${state.totalClients}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          );
        } else if (state is ClientLoading) {
          return const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }
        return const Text(
          '...',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        );
      },
    );
  }

  Widget _buildQuantityValue() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (!mounted) return Container();

        if (state is TotalQuantityLoaded) {
          return Text(
            '${state.data.totalQuantityInt} kg',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          );
        } else if (state is ProductLoading) {
          return const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }
        return const Text(
          '... kg',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        );
      },
    );
  }

  Widget _buildRevenueValue() {
    return BlocBuilder<RevenueBloc, RevenueState>(
      builder: (context, state) {
        if (!mounted) return Container();

        if (state is RevenueLoaded) {
          return Text(
            '${state.totalRevenue.toStringAsFixed(0)} DT',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          );
        } else if (state is RevenueLoading) {
          return const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }
        return const Text(
          '... DT',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        );
      },
    );
  }

  Widget _buildExpensesValue() {
    return BlocBuilder<BillStatisticsBloc, BillStatisticsState>(
      builder: (context, state) {
        if (!mounted) return Container();

        if (state is BillStatisticsLoaded) {
          return Text(
            '${state.statistics.totalExpenses.toStringAsFixed(0)} DT',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          );
        } else if (state is BillStatisticsLoading) {
          return const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }
        return const Text(
          '... DT',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        );
      },
    );
  }

  // Detail quantities - you can replace these with actual BLoC data
  String _getOlivesQuantity() {
    // Replace with actual data from your BLoC
    return '724kg';
  }

  String _getOilProduced() {
    // Replace with actual data from your BLoC
    return '39L';
  }

  String _getWasteSold() {
    // Replace with actual data from your BLoC
    return '296kg';
  }

  String _getFinalWaste() {
    // Replace with actual data from your BLoC
    return '614kg';
  }

  Widget _buildRevenueSummaryCard(BuildContext context, double width) {
    return BlocBuilder<RevenueBloc, RevenueState>(
      builder: (context, state) {
        if (!mounted) return Container();

        if (state is RevenueLoaded) {
          final revenueValue = state.totalRevenue.toStringAsFixed(2);
          const changePercentage = '+12.5%';

          return SummaryCard(
            title: 'Revenu',
            value: '$revenueValue DT',
            change: changePercentage,
            color: AppColors.yellowLight,
            width: width,
          );
        } else if (state is RevenueLoading) {
          return Container(
            width: width,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.yellowLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.yellowLight),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.yellowLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Loading revenue...',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        } else if (state is RevenueError) {
          return Container(
            width: width,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: () {
                      if (mounted) {
                        context.read<RevenueBloc>().add(LoadRevenue());
                      }
                    },
                    child: const Text('Retry', style: TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container(
            width: width,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.yellowLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.yellowLight),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Revenu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '0.00 DT',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: () {
                      if (mounted) {
                        context.read<RevenueBloc>().add(LoadRevenue());
                      }
                    },
                    child: const Text('Load', style: TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildExpensesSummaryCard(BuildContext context, double width) {
    return BlocBuilder<BillStatisticsBloc, BillStatisticsState>(
      builder: (context, state) {
        if (!mounted) return Container();

        if (state is BillStatisticsLoaded) {
          final expensesValue = state.statistics.totalExpenses.toStringAsFixed(
            2,
          );
          const changePercentage = '+6.08%';

          return SummaryCard(
            title: 'Dépenses',
            value: '$expensesValue DT',
            change: changePercentage,
            color: AppColors.greenDark,
            width: width,
          );
        } else if (state is BillStatisticsLoading) {
          return Container(
            width: width,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.greenDark.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.greenDark),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.greenDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Loading expenses...',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        } else if (state is BillStatisticsError) {
          return Container(
            width: width,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: () {
                      if (mounted) {
                        context.read<BillStatisticsBloc>().add(
                          LoadBillStatistics(),
                        );
                      }
                    },
                    child: const Text('Retry', style: TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container(
            width: width,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.greenDark.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.greenDark),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Dépenses',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '0.00 DT',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: () {
                      if (mounted) {
                        context.read<BillStatisticsBloc>().add(
                          LoadBillStatistics(),
                        );
                      }
                    },
                    child: const Text('Load', style: TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
