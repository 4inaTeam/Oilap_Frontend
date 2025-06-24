import 'package:equatable/equatable.dart';
import '../../../../core/models/bill_model.dart';

abstract class BillState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state
class BillInitial extends BillState {}

/// Loading state
class BillLoading extends BillState {}

/// Bills loaded successfully with pagination info
class BillLoadSuccess extends BillState {
  final List<Bill> bills;
  final int currentPage;
  final int totalPages;
  final int totalBills;
  final int pageSize;
  final String? currentSearchQuery;
  final String? currentCategoryFilter;

  BillLoadSuccess({
    required this.bills,
    required this.currentPage,
    required this.totalPages,
    required this.totalBills,
    required this.pageSize,
    this.currentSearchQuery,
    this.currentCategoryFilter,
  });

  @override
  List<Object?> get props => [
        bills,
        currentPage,
        totalPages,
        totalBills,
        pageSize,
        currentSearchQuery,
        currentCategoryFilter,
      ];

  /// Create a copy with updated values
  BillLoadSuccess copyWith({
    List<Bill>? bills,
    int? currentPage,
    int? totalPages,
    int? totalBills,
    int? pageSize,
    String? currentSearchQuery,
    String? currentCategoryFilter,
  }) {
    return BillLoadSuccess(
      bills: bills ?? this.bills,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalBills: totalBills ?? this.totalBills,
      pageSize: pageSize ?? this.pageSize,
      currentSearchQuery: currentSearchQuery ?? this.currentSearchQuery,
      currentCategoryFilter: currentCategoryFilter ?? this.currentCategoryFilter,
    );
  }

  // Helper getters
  bool get hasBills => bills.isNotEmpty;
  bool get hasSearch => currentSearchQuery != null && currentSearchQuery!.isNotEmpty;
  bool get hasFilter => currentCategoryFilter != null && currentCategoryFilter!.isNotEmpty;
  bool get hasMultiplePages => totalPages > 1;
  bool get canGoToNextPage => currentPage < totalPages;
  bool get canGoToPreviousPage => currentPage > 1;

  /// Get bills by category from current bills
  List<Bill> getBillsByCategory(String category) {
    return bills.where((bill) => bill.category == category).toList();
  }

  /// Get total amount of current bills
  double get totalAmount => bills.fold(0.0, (sum, bill) => sum + bill.amount);

  /// Get bills count by category from current bills
  Map<String, int> get billsCountByCategory {
    final Map<String, int> counts = {};
    for (final bill in bills) {
      counts[bill.category] = (counts[bill.category] ?? 0) + 1;
    }
    return counts;
  }

  /// Get pagination info as string
  String get paginationInfo {
    final start = ((currentPage - 1) * pageSize) + 1;
    final end = (currentPage * pageSize > totalBills) ? totalBills : currentPage * pageSize;
    return 'Showing $start-$end of $totalBills bills';
  }
}

/// Single bill loaded successfully (for detail view)
class BillDetailLoadSuccess extends BillState {
  final Bill bill;

  BillDetailLoadSuccess(this.bill);

  @override
  List<Object?> get props => [bill];
}

/// Bill operation failed
class BillOperationFailure extends BillState {
  final String message;

  BillOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Bill created successfully
class BillCreateSuccess extends BillState {}

/// Bill updated successfully
class BillUpdateSuccess extends BillState {}

/// Bill deleted successfully
class BillDeleteSuccess extends BillState {}