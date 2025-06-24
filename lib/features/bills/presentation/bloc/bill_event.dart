import 'dart:io';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class BillEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Load bills with pagination and filtering
class LoadBills extends BillEvent {
  final int page;
  final int pageSize;
  final String? searchQuery;
  final String? categoryFilter;

  LoadBills({
    this.page = 1,
    this.pageSize = 6,
    this.searchQuery,
    this.categoryFilter,
  });

  @override
  List<Object?> get props => [page, pageSize, searchQuery, categoryFilter];
}

/// Search bills by query
class SearchBills extends BillEvent {
  final String query;
  final int page;
  final int pageSize;
  final String? categoryFilter;

  SearchBills({
    required this.query,
    this.page = 1,
    this.pageSize = 6,
    this.categoryFilter,
  });

  @override
  List<Object?> get props => [query, page, pageSize, categoryFilter];
}

/// Filter bills by category
class FilterBillsByCategory extends BillEvent {
  final String? category;
  final int page;
  final int pageSize;
  final String? searchQuery;

  FilterBillsByCategory({
    this.category,
    this.page = 1,
    this.pageSize = 6,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [category, page, pageSize, searchQuery];
}

/// Change pagination page
class ChangePage extends BillEvent {
  final int page;

  ChangePage(this.page);

  @override
  List<Object?> get props => [page];
}

/// Create a new bill with image file or web image bytes
class CreateBill extends BillEvent {
  final String owner;
  final String category;
  final double amount;
  final DateTime paymentDate;
  final double? consumption;
  final List<Map<String, dynamic>>? items;
  final File? imageFile;
  final Uint8List? webImage;

  CreateBill({
    required this.owner,
    required this.category,
    required this.amount,
    required this.paymentDate,
    this.consumption,
    this.items,
    this.imageFile,
    this.webImage,
  });

  @override
  List<Object?> get props => [
        owner,
        category,
        amount,
        paymentDate,
        consumption,
        items,
        imageFile,
        webImage,
      ];
}

/// Update an existing bill (excluding image fields)
class UpdateBill extends BillEvent {
  final int id;
  final String owner;
  final String category;
  final double amount;
  final DateTime paymentDate;
  final double? consumption;
  final List<Map<String, dynamic>>? items;

  UpdateBill({
    required this.id,
    required this.owner,
    required this.category,
    required this.amount,
    required this.paymentDate,
    this.consumption,
    this.items,
  });

  @override
  List<Object?> get props => [
        id,
        owner,
        category,
        amount,
        paymentDate,
        consumption,
        items,
      ];
}

/// Delete a bill
class DeleteBill extends BillEvent {
  final int billId;

  DeleteBill(this.billId);

  @override
  List<Object?> get props => [billId];
}

/// Load a specific bill by ID
class LoadBillById extends BillEvent {
  final int id;

  LoadBillById(this.id);

  @override
  List<Object?> get props => [id];
}

/// Clear current bill state
class ClearBillState extends BillEvent {}

/// Refresh bills (reload current page with current filters)
class RefreshBills extends BillEvent {}
