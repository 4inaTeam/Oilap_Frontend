import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/core/constants/consts.dart';
import 'package:oilab_frontend/features/bills/data/bill_statistics-repository.dart';
import 'package:oilab_frontend/features/dashboard/presentation/widgets/total_quantity_summarycard.dart';
import 'package:oilab_frontend/features/produits/data/product_repository.dart';
import 'package:oilab_frontend/features/produits/presentation/bloc/product_bloc.dart';
import 'package:oilab_frontend/features/produits/presentation/bloc/product_event.dart';
import 'package:oilab_frontend/shared/widgets/header_widget.dart';
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
        // CREATE REVENUE BLOC WITH UNIQUE EVENT
        BlocProvider<RevenueBloc>(
          create: (context) {
            final factureRepo = FactureRepository(
              baseUrl: BackendUrls.current,
              authRepo: context.read<AuthRepository>(),
            );

            final revenueBloc = RevenueBloc(factureRepository: factureRepo);

            // Use the NEW LoadRevenue event instead of LoadTotalRevenue
            revenueBloc.add(
              LoadRevenue(),
            ); // CHANGED: Use LoadRevenue instead of LoadTotalRevenue

            return revenueBloc;
          },
        ),
        // ADD BILL STATISTICS BLOC
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
  @override
  void initState() {
    super.initState();
    print('📱 Dashboard initState called');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDashboard();
    });
  }

  void _initializeDashboard() {
    try {
      print('🚀 Initializing dashboard data...');

      // Load revenue data
      final revenueBloc = context.read<RevenueBloc>();
      print('💰 Revenue bloc state: ${revenueBloc.state.runtimeType}');
      revenueBloc.add(LoadRevenue());

      // Load bill statistics
      final billStatsBloc = context.read<BillStatisticsBloc>();
      print('📊 Bill stats bloc state: ${billStatsBloc.state.runtimeType}');
      billStatsBloc.add(LoadBillStatistics());

      // Load total quantity data
      final productBloc = context.read<ProductBloc>();
      print('📦 Product bloc state: ${productBloc.state.runtimeType}');
      productBloc.add(LoadTotalQuantity());

      print('✅ All dashboard data loading triggered');
    } catch (e) {
      print('💥 Error initializing dashboard: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: '/dashboard',
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile =
                  MediaQuery.of(context).size.width <
                  AppLayout.desktopBreakpoint;

              return Column(
                children: [
                  if (isMobile)
                    AppHeader(
                      title: 'Dashboard',
                      showBackArrow: false,
                      showSearch: true,
                    ),
                  SizedBox(
                    height:
                        isMobile
                            ? MediaQuery.of(context).size.height - 140
                            : MediaQuery.of(context).size.height - 120,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final isDesktop = width >= 600;
                        final tableCards = [
                          const DataTableCard(),
                          const EmployeeTableCard(),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 7,
                                          child: Column(
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    flex: 3,
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: TotalClientsSummaryCard(
                                                                width:
                                                                    constraints
                                                                        .maxWidth *
                                                                    0.2,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 16,
                                                            ),
                                                            Expanded(
                                                              child: TotalQuantitySummaryCard(
                                                                width:
                                                                    constraints
                                                                        .maxWidth *
                                                                    0.2,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 16,
                                                        ),
                                                        Row(
                                                          children: [
                                                            // REVENUE CARD WITH DEBUG
                                                            Expanded(
                                                              child: _buildRevenueSummaryCard(
                                                                context,
                                                                constraints
                                                                        .maxWidth *
                                                                    0.2,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 16,
                                                            ),
                                                            // EXPENSES CARD - UPDATED
                                                            Expanded(
                                                              child: _buildExpensesSummaryCard(
                                                                context,
                                                                constraints
                                                                        .maxWidth *
                                                                    0.2,
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
                                                    child: QuantityDetailsCard(
                                                      width:
                                                          constraints.maxWidth *
                                                          0.25,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              const SizedBox(
                                                height: 300,
                                                child: LineChartCard(),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        Expanded(
                                          flex: 4,
                                          child: SizedBox(
                                            height: 600,
                                            child: DynamicPieChartCard(),
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    // Simplified layout for smaller screens
                                    return Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TotalClientsSummaryCard(
                                                width:
                                                    constraints.maxWidth * 0.45,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: TotalQuantitySummaryCard(
                                                width:
                                                    constraints.maxWidth * 0.45,
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
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueSummaryCard(BuildContext context, double width) {
    return BlocBuilder<RevenueBloc, RevenueState>(
      builder: (context, state) {
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
                      context.read<RevenueBloc>().add(
                        LoadRevenue(),
                      ); // CHANGED: Use LoadRevenue
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
                      context.read<RevenueBloc>().add(
                        LoadRevenue(),
                      ); // CHANGED: Use LoadRevenue
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
                      context.read<BillStatisticsBloc>().add(
                        LoadBillStatistics(),
                      );
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
                      context.read<BillStatisticsBloc>().add(
                        LoadBillStatistics(),
                      );
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
