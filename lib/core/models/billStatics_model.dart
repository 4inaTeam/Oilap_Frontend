import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:oilab_frontend/features/auth/data/auth_repository.dart';

class BillStatistics {
  final double totalExpenses;
  final double totalRevenue;
  final double totalFinancialActivity;
  final double expensesPercentage;
  final double revenuePercentage;
  final double netResult;
  final String netResultType;
  final int totalBillsCount;
  final int totalFacturesCount;
  final int totalItemsCount;
  final Map<String, CategoryStats> categoryBreakdown;
  final SummaryStats summary;

  BillStatistics({
    required this.totalExpenses,
    required this.totalRevenue,
    required this.totalFinancialActivity,
    required this.expensesPercentage,
    required this.revenuePercentage,
    required this.netResult,
    required this.netResultType,
    required this.totalBillsCount,
    required this.totalFacturesCount,
    required this.totalItemsCount,
    required this.categoryBreakdown,
    required this.summary,
  });

  factory BillStatistics.fromJson(Map<String, dynamic> json) {
    try {
      final categoryBreakdownMap = <String, CategoryStats>{};

      // Parse category_breakdown
      final categoryBreakdownData = json['category_breakdown'];
      if (categoryBreakdownData != null &&
          categoryBreakdownData is Map<String, dynamic>) {
        categoryBreakdownData.forEach((key, value) {
          if (value != null && value is Map<String, dynamic>) {
            categoryBreakdownMap[key] = CategoryStats.fromJson(value);
          }
        });
      }

      // Parse expense_summary for utilities and purchases
      final expenseSummaryData = json['expense_summary'];
      SummaryStats summary;

      if (expenseSummaryData != null &&
          expenseSummaryData is Map<String, dynamic>) {
        final utilitiesData = expenseSummaryData['utilities'];
        final purchasesData = expenseSummaryData['purchases'];

        summary = SummaryStats(
          utilities:
              utilitiesData != null && utilitiesData is Map<String, dynamic>
                  ? CategoryStats.fromJson(utilitiesData)
                  : CategoryStats(
                    name: 'Utilities',
                    totalAmount: 0.0,
                    count: 0,
                    percentage: 0.0,
                  ),
          purchases:
              purchasesData != null && purchasesData is Map<String, dynamic>
                  ? CategoryStats.fromJson(purchasesData)
                  : CategoryStats(
                    name: 'Purchases',
                    totalAmount: 0.0,
                    count: 0,
                    percentage: 0.0,
                  ),
        );
      } else {
        // Create default summary
        summary = SummaryStats(
          utilities: CategoryStats(
            name: 'Utilities',
            totalAmount: 0.0,
            count: 0,
            percentage: 0.0,
          ),
          purchases: CategoryStats(
            name: 'Purchases',
            totalAmount: 0.0,
            count: 0,
            percentage: 0.0,
          ),
        );
      }

      final result = BillStatistics(
        totalExpenses: _parseDouble(json['total_expenses']),
        totalRevenue: _parseDouble(json['total_revenue']),
        totalFinancialActivity: _parseDouble(json['total_financial_activity']),
        expensesPercentage: _parseDouble(json['expenses_percentage']),
        revenuePercentage: _parseDouble(json['revenue_percentage']),
        netResult: _parseDouble(json['net_result']),
        netResultType: json['net_result_type']?.toString() ?? 'unknown',
        totalBillsCount: _parseInt(json['total_bills_count']),
        totalFacturesCount: _parseInt(json['total_factures_count']),
        totalItemsCount: _parseInt(json['total_items_count']),
        categoryBreakdown: categoryBreakdownMap,
        summary: summary,
      );

      return result;
    } catch (e) {
      print('Error parsing BillStatistics: $e');
      // Return default object on error
      return BillStatistics(
        totalExpenses: 0.0,
        totalRevenue: 0.0,
        totalFinancialActivity: 0.0,
        expensesPercentage: 0.0,
        revenuePercentage: 0.0,
        netResult: 0.0,
        netResultType: 'unknown',
        totalBillsCount: 0,
        totalFacturesCount: 0,
        totalItemsCount: 0,
        categoryBreakdown: {},
        summary: SummaryStats(
          utilities: CategoryStats(
            name: 'Utilities',
            totalAmount: 0.0,
            count: 0,
            percentage: 0.0,
          ),
          purchases: CategoryStats(
            name: 'Purchases',
            totalAmount: 0.0,
            count: 0,
            percentage: 0.0,
          ),
        ),
      );
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}

class CategoryStats {
  final String name;
  final double totalAmount;
  final int count;
  final double percentage;
  final String? type;

  CategoryStats({
    required this.name,
    required this.totalAmount,
    required this.count,
    required this.percentage,
    this.type,
  });

  factory CategoryStats.fromJson(Map<String, dynamic> json) {
    try {
      return CategoryStats(
        name: json['name']?.toString() ?? '',
        totalAmount: BillStatistics._parseDouble(json['total_amount']),
        count: BillStatistics._parseInt(json['count']),
        percentage: BillStatistics._parseDouble(json['percentage']),
        type: json['type']?.toString(),
      );
    } catch (e) {
      return CategoryStats(
        name: '',
        totalAmount: 0.0,
        count: 0,
        percentage: 0.0,
      );
    }
  }
}

class SummaryStats {
  final CategoryStats utilities;
  final CategoryStats purchases;

  SummaryStats({required this.utilities, required this.purchases});

  factory SummaryStats.fromJson(Map<String, dynamic> json) {
    try {
      final utilitiesData = json['utilities'];
      final purchasesData = json['purchases'];

      return SummaryStats(
        utilities:
            utilitiesData != null && utilitiesData is Map<String, dynamic>
                ? CategoryStats.fromJson(utilitiesData)
                : CategoryStats(
                  name: 'Utilities',
                  totalAmount: 0.0,
                  count: 0,
                  percentage: 0.0,
                ),
        purchases:
            purchasesData != null && purchasesData is Map<String, dynamic>
                ? CategoryStats.fromJson(purchasesData)
                : CategoryStats(
                  name: 'Purchases',
                  totalAmount: 0.0,
                  count: 0,
                  percentage: 0.0,
                ),
      );
    } catch (e) {
      return SummaryStats(
        utilities: CategoryStats(
          name: 'Utilities',
          totalAmount: 0.0,
          count: 0,
          percentage: 0.0,
        ),
        purchases: CategoryStats(
          name: 'Purchases',
          totalAmount: 0.0,
          count: 0,
          percentage: 0.0,
        ),
      );
    }
  }
}

class BillStatisticsRepository {
  final String baseUrl;
  final AuthRepository authRepo;

  BillStatisticsRepository({required this.baseUrl, required this.authRepo});

  Future<BillStatistics> fetchBillStatistics() async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/bills/statistics/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('BillStatistics API Response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final statistics = BillStatistics.fromJson(data);
        return statistics;
      } else if (response.statusCode == 404) {
        return BillStatistics(
          totalExpenses: 0.0,
          totalRevenue: 0.0,
          totalFinancialActivity: 0.0,
          expensesPercentage: 0.0,
          revenuePercentage: 0.0,
          netResult: 0.0,
          netResultType: 'unknown',
          totalBillsCount: 0,
          totalFacturesCount: 0,
          totalItemsCount: 0,
          categoryBreakdown: {},
          summary: SummaryStats(
            utilities: CategoryStats(
              name: 'Utilities',
              totalAmount: 0.0,
              count: 0,
              percentage: 0.0,
            ),
            purchases: CategoryStats(
              name: 'Purchases',
              totalAmount: 0.0,
              count: 0,
              percentage: 0.0,
            ),
          ),
        );
      } else {
        throw Exception(
          'Failed to fetch statistics: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Error in fetchBillStatistics: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        throw Exception('Network error: Please check your connection');
      } else if (e.toString().contains('FormatException')) {
        throw Exception('Invalid response format from server');
      } else {
        rethrow;
      }
    }
  }
}
