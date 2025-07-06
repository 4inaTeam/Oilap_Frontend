import 'package:equatable/equatable.dart';
import 'package:oilab_frontend/features/produits/data/product_repository.dart';
import '../../../../core/models/product_model.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
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

  const ProductLoadSuccess({
    required this.products,
    required this.currentPage,
    required this.totalPages,
    required this.totalProducts,
    required this.pageSize,
    this.currentSearchQuery,
  });

  @override
  List<Object?> get props => [
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

  const ProductOperationFailure(this.message);

  @override
  List<Object> get props => [message];
}

class ProductAddSuccess extends ProductState {}

class ProductCreateSuccess extends ProductState {}

class ProductUpdateSuccess extends ProductState {}

class ProductDeleteSuccess extends ProductState {}

// PDF Download States
class ProductPDFDownloadLoading extends ProductState {}

class ProductPDFDownloadSuccess extends ProductState {
  final String filePath;

  const ProductPDFDownloadSuccess({required this.filePath});

  @override
  List<Object> get props => [filePath];
}

class ProductPDFDownloadFailure extends ProductState {
  final String message;

  const ProductPDFDownloadFailure(this.message);

  @override
  List<Object> get props => [message];
}

class TotalQuantityLoaded extends ProductState {
  final TotalQuantityData data;

  const TotalQuantityLoaded(this.data);

  @override
  List<Object> get props => [data];
}

class OriginPercentagesLoaded extends ProductState {
  final OriginPercentageData data;

  const OriginPercentagesLoaded(this.data);

  @override
  List<Object> get props => [data];
}
