import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:oilab_frontend/features/produits/data/product_repository.dart';
import 'package:oilab_frontend/features/produits/presentation/bloc/product_bloc.dart';
import 'package:oilab_frontend/features/produits/presentation/bloc/product_event.dart';
import 'package:oilab_frontend/features/produits/presentation/bloc/product_state.dart';
import '../../../../core/constants/app_colors.dart';
import 'legend_item.dart';

class DynamicPieChartCard extends StatefulWidget {
  const DynamicPieChartCard({Key? key}) : super(key: key);

  @override
  State<DynamicPieChartCard> createState() => _DynamicPieChartCardState();
}

class _DynamicPieChartCardState extends State<DynamicPieChartCard> {
  OriginPercentageData? originData;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(LoadOriginPercentages());
  }

  // Define colors for different origins
  List<Color> get chartColors => [
    AppColors.accentGreen,
    Colors.lightGreen.shade200,
    AppColors.accentYellow,
    Colors.lightGreen.shade400,
    Colors.orange.shade300,
    Colors.blue.shade300,
    Colors.purple.shade300,
    Colors.red.shade300,
    Colors.teal.shade300,
    Colors.indigo.shade300,
  ];

  void _updateFromOriginState(OriginPercentagesLoaded state) {
    setState(() {
      originData = state.data;
      isLoading = false;
      errorMessage = null;
    });
  }

  void _updateFromLoadingState() {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
  }

  void _updateFromErrorState(String error) {
    setState(() {
      isLoading = false;
      errorMessage = error;
      originData = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is OriginPercentagesLoaded) {
          _updateFromOriginState(state);
        } else if (state is ProductLoading) {
          _updateFromLoadingState();
        } else if (state is ProductOperationFailure) {
          _updateFromErrorState(state.message);
        }
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Principales régions fournissant des olives',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () {
                      context.read<ProductBloc>().add(LoadOriginPercentages());
                    },
                    icon: const Icon(Icons.refresh),
                    iconSize: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 32),
            const SizedBox(height: 8),
            Text(
              'Failed to load data',
              style: TextStyle(color: Colors.red[400], fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              errorMessage!,
              style: TextStyle(color: Colors.red[300], fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                context.read<ProductBloc>().add(LoadOriginPercentages());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (originData == null) {
      return const Center(child: Text('No data available'));
    }

    return _buildChart(originData!);
  }

  Widget _buildChart(OriginPercentageData data) {
    if (data.originPercentages.isEmpty) {
      return const Center(child: Text('No origin data available'));
    }

    final displayOrigins = data.originPercentages.take(4).toList();
    final otherOrigins = data.originPercentages.skip(4).toList();

    List<PieChartSectionData> sections = [];
    List<Widget> legendItems = [];

    for (int i = 0; i < displayOrigins.length; i++) {
      final origin = displayOrigins[i];
      final color = chartColors[i % chartColors.length];

      sections.add(
        PieChartSectionData(
          value: origin.percentage,
          color: color,
          title: '${origin.percentage.toStringAsFixed(1)}%',
          radius: 80,
          titleStyle: TextStyle(
            color: origin.percentage > 10 ? Colors.white : Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      legendItems.add(
        LegendItem(
          color: color,
          label: origin.origin,
          percentage: origin.percentage,
          count: origin.count,
        ),
      );
    }

    // Add "Others" if there are more origins
    if (otherOrigins.isNotEmpty) {
      final othersPercentage = otherOrigins.fold<double>(
        0,
        (sum, origin) => sum + origin.percentage,
      );
      final othersCount = otherOrigins.fold<int>(
        0,
        (sum, origin) => sum + origin.count,
      );

      if (othersPercentage > 0) {
        final color = chartColors[displayOrigins.length % chartColors.length];

        sections.add(
          PieChartSectionData(
            value: othersPercentage,
            color: color,
            title: '${othersPercentage.toStringAsFixed(1)}%',
            radius: 80,
            titleStyle: TextStyle(
              color: othersPercentage > 10 ? Colors.white : Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

        legendItems.add(
          LegendItem(
            color: color,
            label: 'Others',
            percentage: othersPercentage,
            count: othersCount,
          ),
        );
      }
    }

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 0,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Column(
              children:
                  legendItems
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: item,
                        ),
                      )
                      .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
