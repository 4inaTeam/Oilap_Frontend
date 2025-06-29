import 'package:flutter/material.dart';
import 'package:oilab_frontend/shared/widgets/header_widget.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_layout.dart';
import '../widgets/index.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

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
                                  final isTablet =
                                      constraints.maxWidth >= 700 &&
                                      constraints.maxWidth < 1000;

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
                                                              child: SummaryCard(
                                                                title:
                                                                    'Clients',
                                                                value: '781',
                                                                change:
                                                                    '+11.01%',
                                                                color:
                                                                    AppColors
                                                                        .greenLight,
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
                                                              child: SummaryCard(
                                                                title:
                                                                    'Quantité',
                                                                value: '1219 T',
                                                                change:
                                                                    '-0.03%',
                                                                color:
                                                                    AppColors
                                                                        .yellowDark,
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
                                                            Expanded(
                                                              child: SummaryCard(
                                                                title: 'Revenu',
                                                                value: '695 DT',
                                                                change:
                                                                    '+15.03%',
                                                                color:
                                                                    AppColors
                                                                        .yellowLight,
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
                                                              child: SummaryCard(
                                                                title:
                                                                    'Dépenses',
                                                                value: '305 DT',
                                                                change:
                                                                    '+6.08%',
                                                                color:
                                                                    AppColors
                                                                        .greenDark,
                                                                width:
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
                                            child: PieChartCard(),
                                          ),
                                        ),
                                      ],
                                    );
                                  } else if (isTablet) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
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
                                                        child: SummaryCard(
                                                          title: 'Clients',
                                                          value: '781',
                                                          change: '+11.01%',
                                                          color:
                                                              AppColors
                                                                  .greenLight,
                                                          width:
                                                              constraints
                                                                  .maxWidth *
                                                              0.3,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: SummaryCard(
                                                          title: 'Quantité',
                                                          value: '1219 T',
                                                          change: '-0.03%',
                                                          color:
                                                              AppColors
                                                                  .yellowDark,
                                                          width:
                                                              constraints
                                                                  .maxWidth *
                                                              0.3,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: SummaryCard(
                                                          title: 'Revenu',
                                                          value: '695 DT',
                                                          change: '+15.03%',
                                                          color:
                                                              AppColors
                                                                  .yellowLight,
                                                          width:
                                                              constraints
                                                                  .maxWidth *
                                                              0.3,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: SummaryCard(
                                                          title: 'Dépenses',
                                                          value: '305 DT',
                                                          change: '+6.08%',
                                                          color:
                                                              AppColors
                                                                  .greenDark,
                                                          width:
                                                              constraints
                                                                  .maxWidth *
                                                              0.3,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              flex: 2,
                                              child: QuantityDetailsCard(
                                                width:
                                                    constraints.maxWidth * 0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          height: 350,
                                          child: PieChartCard(),
                                        ),
                                        const SizedBox(height: 16),
                                        const SizedBox(
                                          height: 250,
                                          child: LineChartCard(),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: SummaryCard(
                                                            title: 'Clients',
                                                            value: '781',
                                                            change: '+11.01%',
                                                            color:
                                                                AppColors
                                                                    .greenLight,
                                                            width:
                                                                constraints
                                                                    .maxWidth *
                                                                0.3,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        Expanded(
                                                          child: SummaryCard(
                                                            title: 'Quantité',
                                                            value: '1219 T',
                                                            change: '-0.03%',
                                                            color:
                                                                AppColors
                                                                    .yellowDark,
                                                            width:
                                                                constraints
                                                                    .maxWidth *
                                                                0.3,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: SummaryCard(
                                                            title: 'Revenu',
                                                            value: '695 DT',
                                                            change: '+15.03%',
                                                            color:
                                                                AppColors
                                                                    .yellowLight,
                                                            width:
                                                                constraints
                                                                    .maxWidth *
                                                                0.3,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        Expanded(
                                                          child: SummaryCard(
                                                            title: 'Dépenses',
                                                            value: '305 DT',
                                                            change: '+6.08%',
                                                            color:
                                                                AppColors
                                                                    .greenDark,
                                                            width:
                                                                constraints
                                                                    .maxWidth *
                                                                0.3,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                height:
                                                    150,
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color:
                                                        AppColors.accentGreen,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    Text(
                                                      'Détails des quantités',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            12,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          _buildCompactDetailRow(
                                                            context,
                                                            "Quantité d'olives",
                                                            '72 Kg',
                                                          ),
                                                          _buildCompactDetailRow(
                                                            context,
                                                            'Huile produite',
                                                            '39 L',
                                                          ),
                                                          _buildCompactDetailRow(
                                                            context,
                                                            'Déchets vendus',
                                                            '25 Kg',
                                                          ),
                                                          _buildCompactDetailRow(
                                                            context,
                                                            'Déchets finaux',
                                                            '61 Kg',
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
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          height: 350,
                                          child: PieChartCard(),
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          height: 250,
                                          child: LineChartCard(),
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

  Widget _buildCompactDetailRow(
    BuildContext context,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
