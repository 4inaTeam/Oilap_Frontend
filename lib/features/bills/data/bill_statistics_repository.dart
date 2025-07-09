import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/data/auth_repository.dart';

class PaymentStatusStats {
  final PaymentStatus paid;
  final PaymentStatus unpaid;
  final PaymentStatus partial;

  PaymentStatusStats({
    required this.paid,
    required this.unpaid,
    required this.partial,
  });

  factory PaymentStatusStats.fromJson(Map<String, dynamic> json) {
    try {
      return PaymentStatusStats(
        paid: PaymentStatus.fromJson(json['paid'] ?? {}),
        unpaid: PaymentStatus.fromJson(json['unpaid'] ?? {}),
        partial: PaymentStatus.fromJson(json['partial'] ?? {}),
      );
    } catch (e) {
      return PaymentStatusStats(
        paid: PaymentStatus.empty(),
        unpaid: PaymentStatus.empty(),
        partial: PaymentStatus.empty(),
      );
    }
  }
}

class PaymentStatus {
  final int count;
  final double percentage;
  final double totalAmount;

  PaymentStatus({
    required this.count,
    required this.percentage,
    required this.totalAmount,
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    try {
      return PaymentStatus(
        count: BillStatistics._parseInt(json['count']),
        percentage: BillStatistics._parseDouble(json['percentage']),
        totalAmount: BillStatistics._parseDouble(json['total_amount']),
      );
    } catch (e) {
      return PaymentStatus.empty();
    }
  }

  factory PaymentStatus.empty() {
    return PaymentStatus(count: 0, percentage: 0.0, totalAmount: 0.0);
  }
}

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
  final PaymentStatusStats paymentStatusStats; // Added this field

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
    required this.paymentStatusStats, // Added this parameter
  });

  // Add convenience getter for backward compatibility
  double get combinedTotal => totalFinancialActivity;

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

        // For the expense distribution chart, we need percentages based on total expenses only
        final totalExpensesForChart = _parseDouble(json['total_expenses']);

        summary = SummaryStats(
          utilities:
              utilitiesData != null && utilitiesData is Map<String, dynamic>
                  ? CategoryStats.fromJson(utilitiesData).copyWith(
                    percentage:
                        totalExpensesForChart > 0
                            ? (_parseDouble(utilitiesData['total_amount']) /
                                    totalExpensesForChart) *
                                100
                            : 0.0,
                  )
                  : CategoryStats(
                    name: 'Utilities',
                    totalAmount: 0.0,
                    count: 0,
                    percentage: 0.0,
                  ),
          purchases:
              purchasesData != null && purchasesData is Map<String, dynamic>
                  ? CategoryStats.fromJson(purchasesData).copyWith(
                    percentage:
                        totalExpensesForChart > 0
                            ? (_parseDouble(purchasesData['total_amount']) /
                                    totalExpensesForChart) *
                                100
                            : 0.0,
                  )
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

      // Parse payment status stats
      final paymentStatusData = json['payment_status_stats'];
      PaymentStatusStats paymentStatusStats;

      if (paymentStatusData != null &&
          paymentStatusData is Map<String, dynamic>) {
        paymentStatusStats = PaymentStatusStats.fromJson(paymentStatusData);
      } else {
        paymentStatusStats = PaymentStatusStats(
          paid: PaymentStatus.empty(),
          unpaid: PaymentStatus.empty(),
          partial: PaymentStatus.empty(),
        );
      }

      // Get values from JSON
      final totalExpenses = _parseDouble(json['total_expenses']);
      final totalRevenue = _parseDouble(json['total_revenue']);
      final totalFinancialActivity =
          _parseDouble(json['combined_total']) > 0
              ? _parseDouble(json['combined_total'])
              : _parseDouble(json['total_financial_activity']);

      // Calculate percentages properly
      double expensesPercentage = 0.0;
      double revenuePercentage = 0.0;

      final breakdownByType = json['breakdown_by_type'];
      if (breakdownByType != null && breakdownByType is Map<String, dynamic>) {
        final expensesData = breakdownByType['expenses'];
        final revenueData = breakdownByType['revenue'];

        if (expensesData != null && revenueData != null) {
          final expensesTotal = _parseDouble(expensesData['total']);
          final revenueTotal = _parseDouble(revenueData['total']);
          final total = expensesTotal + revenueTotal;

          if (total > 0) {
            expensesPercentage = (expensesTotal / total) * 100;
            revenuePercentage = (revenueTotal / total) * 100;
          }
        }
      }

      // Fallback calculation
      if (expensesPercentage == 0.0 && revenuePercentage == 0.0) {
        final total = totalExpenses + totalRevenue;
        if (total > 0) {
          expensesPercentage = (totalExpenses / total) * 100;
          revenuePercentage = (totalRevenue / total) * 100;
        }
      }

      final result = BillStatistics(
        totalExpenses: totalExpenses,
        totalRevenue: totalRevenue,
        totalFinancialActivity: totalFinancialActivity,
        expensesPercentage: expensesPercentage,
        revenuePercentage: revenuePercentage,
        netResult: _parseDouble(json['net_result']),
        netResultType: json['net_result_type']?.toString() ?? 'unknown',
        totalBillsCount: _parseInt(json['total_bills_count']),
        totalFacturesCount: _parseInt(json['total_factures_count']),
        totalItemsCount: _parseInt(json['total_items_count']),
        categoryBreakdown: categoryBreakdownMap,
        summary: summary,
        paymentStatusStats: paymentStatusStats,
      );

      return result;
    } catch (e) {
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
        paymentStatusStats: PaymentStatusStats(
          paid: PaymentStatus.empty(),
          unpaid: PaymentStatus.empty(),
          partial: PaymentStatus.empty(),
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

  // Add copyWith method for updating percentages
  CategoryStats copyWith({
    String? name,
    double? totalAmount,
    int? count,
    double? percentage,
    String? type,
  }) {
    return CategoryStats(
      name: name ?? this.name,
      totalAmount: totalAmount ?? this.totalAmount,
      count: count ?? this.count,
      percentage: percentage ?? this.percentage,
      type: type ?? this.type,
    );
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
          paymentStatusStats: PaymentStatusStats(
            paid: PaymentStatus.empty(),
            unpaid: PaymentStatus.empty(),
            partial: PaymentStatus.empty(),
          ),
        );
      } else {
        throw Exception(
          'Failed to fetch statistics: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
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
