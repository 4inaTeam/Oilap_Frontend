import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  final int page;
  final int pageSize;
  final String? searchQuery;

  const LoadProducts({this.page = 1, this.pageSize = 10, this.searchQuery});

  @override
  List<Object?> get props => [page, pageSize, searchQuery];
}

class SearchProducts extends ProductEvent {
  final String query;
  final int page;
  final int pageSize;

  const SearchProducts({
    required this.query,
    this.page = 1,
    this.pageSize = 10,
  });

  @override
  List<Object> get props => [query, page, pageSize];
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
  final int? estimationTime;

  AddProduct({
    required this.name,
    required this.description,
    required this.category,
    required this.sku,
    required this.barcode,
    required this.price,
    required this.quantity,
    this.estimationTime,
  });

  @override
  List get props => [
    name,
    description,
    category,
    sku,
    barcode,
    price,
    quantity,
    estimationTime,
  ];
}

class UpdateProduct extends ProductEvent {
  final int id;
  final String? quality;
  final String? origine;
  final double? price;
  final int? quantity;
  final String? clientCin;
  final String? status;
  final int? estimationTime;

  const UpdateProduct({
    required this.id,
    this.quality,
    this.origine,
    this.price,
    this.quantity,
    this.clientCin,
    this.status,
    this.estimationTime,
  });

  @override
  List<Object?> get props => [
    id,
    quality,
    origine,
    price,
    quantity,
    clientCin,
    status,
    estimationTime,
  ];
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

class CreateProduct extends ProductEvent {
  final String quality;
  final String origine;
  final double price;
  final double quantity;
  final String clientCin;
  final int estimationTime;

  const CreateProduct({
    required this.quality,
    required this.origine,
    required this.price,
    required this.quantity,
    required this.clientCin,
    required this.estimationTime,
  });

  @override
  List<Object> get props => [
    quality,
    origine,
    price,
    quantity,
    clientCin,
    estimationTime,
  ];
}

class CancelProduct extends ProductEvent {
  final dynamic product;

  const CancelProduct({required this.product});

  @override
  List<Object?> get props => [product];
}

class DownloadProductPDF extends ProductEvent {
  final int productId;

  const DownloadProductPDF({required this.productId});

  @override
  List<Object> get props => [productId];
}

class LoadTotalQuantity extends ProductEvent {}

class LoadOriginPercentages extends ProductEvent {}
