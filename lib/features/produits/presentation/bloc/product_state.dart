import 'package:equatable/equatable.dart';
import '../../../../core/models/product_model.dart';

abstract class ProductState extends Equatable {
  @override
  List get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoadSuccess extends ProductState {
  final List<Product> products;
  final int currentPage;
  final int totalPages;
  final int totalProducts;
  final int pageSize;
  final String? currentSearchQuery;

  ProductLoadSuccess({
    required this.products,
    required this.currentPage,
    required this.totalPages,
    required this.totalProducts,
    required this.pageSize,
    this.currentSearchQuery,
  });

  @override
  List get props => [
    products,
    currentPage,
    totalPages,
    totalProducts,
    pageSize,
    currentSearchQuery,
  ];

  ProductLoadSuccess copyWith({
    List<Product>? products,
    int? currentPage,
    int? totalPages,
    int? totalProducts,
    int? pageSize,
    String? currentSearchQuery,
  }) {
    return ProductLoadSuccess(
      products: products ?? this.products,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalProducts: totalProducts ?? this.totalProducts,
      pageSize: pageSize ?? this.pageSize,
      currentSearchQuery: currentSearchQuery ?? this.currentSearchQuery,
    );
  }
}

class ProductOperationFailure extends ProductState {
  final String message;
  ProductOperationFailure(this.message);
  @override
  List get props => [message];
}

class ProductAddSuccess extends ProductState {}

class ProductUpdateSuccess extends ProductState {}