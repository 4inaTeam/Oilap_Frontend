import 'dart:io';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class BillEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadBills extends BillEvent {
  final int page;
  final int pageSize;
  final String? searchQuery;
  final String? categoryFilter;

  LoadBills({
    this.page = 1,
    this.pageSize = 10,
    this.searchQuery,
    this.categoryFilter,
  });

  @override
  List<Object?> get props => [page, pageSize, searchQuery, categoryFilter];
}

// New event for dashboard - loads recent bills for dashboard display
class LoadDashboardBills extends BillEvent {
  final int limit;

  LoadDashboardBills({this.limit = 3});

  @override
  List<Object?> get props => [limit];
}

class SearchBills extends BillEvent {
  final String query;
  final int page;
  final int pageSize;
  final String? categoryFilter;

  SearchBills({
    required this.query,
    this.page = 1,
    this.pageSize = 10,
    this.categoryFilter,
  });

  @override
  List<Object?> get props => [query, page, pageSize, categoryFilter];
}

class FilterBillsByCategory extends BillEvent {
  final String? category;
  final int page;
  final int pageSize;
  final String? searchQuery;

  FilterBillsByCategory({
    this.category,
    this.page = 1,
    this.pageSize = 10,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [category, page, pageSize, searchQuery];
}

class ChangePage extends BillEvent {
  final int page;

  ChangePage(this.page);

  @override
  List<Object?> get props => [page];
}

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

class DeleteBill extends BillEvent {
  final int billId;

  DeleteBill(this.billId);

  @override
  List<Object?> get props => [billId];
}

class LoadBillById extends BillEvent {
  final int id;

  LoadBillById(this.id);

  @override
  List<Object?> get props => [id];
}

class ClearBillState extends BillEvent {}

class RefreshBills extends BillEvent {}


