import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  @override
  List get props => [];
}

class LoadProducts extends ProductEvent {
  final int page;
  final int pageSize;
  final String? searchQuery;

  LoadProducts({
    this.page = 1,
    this.pageSize = 6,
    this.searchQuery,
  });

  @override
  List get props => [page, pageSize, searchQuery];
}

class SearchProducts extends ProductEvent {
  final String query;
  final int page;
  final int pageSize;

  SearchProducts({
    required this.query,
    this.page = 1,
    this.pageSize = 6,
  });

  @override
  List get props => [query, page, pageSize];
}

class ChangePage extends ProductEvent {
  final int page;
  final String? currentSearchQuery;

  ChangePage(this.page, {this.currentSearchQuery});

  @override
  List get props => [page, currentSearchQuery];
}

class AddProduct extends ProductEvent {
  final String name, description, category, sku, barcode;
  final double price;
  final int quantity;

  AddProduct({
    required this.name,
    required this.description,
    required this.category,
    required this.sku,
    required this.barcode,
    required this.price,
    required this.quantity,
  });

  @override
  List get props => [name, description, category, sku, barcode, price, quantity];
}

class UpdateProduct extends ProductEvent {
  final int id;
  final String name;
  final String description;
  final String category;
  final String sku;
  final String barcode;
  final double price;
  final int quantity;

  UpdateProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.sku,
    required this.barcode,
    required this.price,
    required this.quantity,
  });

  @override
  List get props => [id, name, description, category, sku, barcode, price, quantity];
}

class UpdateProductStatus extends ProductEvent {
  final int productId;
  final String newStatus;

  UpdateProductStatus(this.productId, this.newStatus);

  @override
  List get props => [productId, newStatus];
}

class DeleteProduct extends ProductEvent {
  final int productId;

  DeleteProduct(this.productId);

  @override
  List get props => [productId];
}