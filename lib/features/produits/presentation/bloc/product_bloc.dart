import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_event.dart';
import 'product_state.dart';
import '../../data/product_repository.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repo;

  ProductBloc(this.repo) : super(ProductInitial()) {
    on<LoadProducts>((event, emit) async {
      emit(ProductLoading());
      try {
        final result = await repo.fetchProducts(
          page: event.page,
          pageSize: event.pageSize,
          searchQuery: event.searchQuery,
        );

        emit(
          ProductLoadSuccess(
            products: result.products,
            currentPage: result.currentPage,
            totalPages: result.totalPages,
            totalProducts: result.totalCount,
            pageSize: event.pageSize,
            currentSearchQuery: event.searchQuery,
          ),
        );
      } catch (err) {
        emit(ProductOperationFailure(err.toString()));
      }
    });

    on<SearchProducts>((event, emit) async {
      emit(ProductLoading());
      try {
        final result = await repo.fetchProducts(
          page: event.page,
          pageSize: event.pageSize,
          searchQuery: event.query,
        );

        emit(
          ProductLoadSuccess(
            products: result.products,
            currentPage: result.currentPage,
            totalPages: result.totalPages,
            totalProducts: result.totalCount,
            pageSize: event.pageSize,
            currentSearchQuery: event.query,
          ),
        );
      } catch (err) {
        emit(ProductOperationFailure(err.toString()));
      }
    });

    on<ChangePage>((event, emit) async {
      if (state is ProductLoadSuccess) {
        final currentState = state as ProductLoadSuccess;
        emit(ProductLoading());

        try {
          final result = await repo.fetchProducts(
            page: event.page,
            pageSize: currentState.pageSize,
            searchQuery: event.currentSearchQuery,
          );

          emit(
            ProductLoadSuccess(
              products: result.products,
              currentPage: result.currentPage,
              totalPages: result.totalPages,
              totalProducts: result.totalCount,
              pageSize: currentState.pageSize,
              currentSearchQuery: event.currentSearchQuery,
            ),
          );
        } catch (err) {
          emit(ProductOperationFailure(err.toString()));
        }
      }
    });

    on<AddProduct>((event, emit) async {
      emit(ProductLoading());
      try {
        await repo.createProduct(
          quality: event.name, 
          quantity: event.quantity.toDouble(),
          origine: event.description,
          price: event.price,
          status: 'pending',
          clientCin: event.sku,
        );
        emit(ProductAddSuccess());

        final result = await repo.fetchProducts(page: 1, pageSize: 8);
        emit(
          ProductLoadSuccess(
            products: result.products,
            currentPage: result.currentPage,
            totalPages: result.totalPages,
            totalProducts: result.totalCount,
            pageSize: 8,
          ),
        );
      } catch (err) {
        emit(ProductOperationFailure(err.toString()));
      }
    });

    on<CreateProduct>((event, emit) async {
      emit(ProductLoading());
      try {
        await repo.createProduct(
          quality: event.quality,
          origine: event.origine,
          price: event.price,
          quantity: event.quantity,
          clientCin: event.clientCin,
          status: 'pending',
        );

        final result = await repo.fetchProducts(page: 1, pageSize: 6);
        emit(
          ProductLoadSuccess(
            products: result.products,
            currentPage: 1,
            totalPages: result.totalPages,
            totalProducts: result.totalCount,
            pageSize: 6,
          ),
        );
      } catch (e) {
        emit(ProductOperationFailure(e.toString()));
      }
    });

    on<UpdateProduct>((event, emit) async {
      emit(ProductLoading());
      try {
        await repo.updateProduct(
          id: event.id,
          quality: event.quality,
          origine: event.origine,
          price: event.price,
          quantity: event.quantity?.toDouble(),
          clientCin: event.clientCin,
          status: event.status,
        );

        emit(ProductUpdateSuccess());

        if (state is ProductLoadSuccess) {
          final currentState = state as ProductLoadSuccess;
          final result = await repo.fetchProducts(
            page: currentState.currentPage,
            pageSize: currentState.pageSize,
            searchQuery: currentState.currentSearchQuery,
          );

          emit(
            ProductLoadSuccess(
              products: result.products,
              currentPage: result.currentPage,
              totalPages: result.totalPages,
              totalProducts: result.totalCount,
              pageSize: currentState.pageSize,
              currentSearchQuery: currentState.currentSearchQuery,
            ),
          );
        }
      } catch (err) {
        emit(ProductOperationFailure(err.toString()));
      }
    });

    on<UpdateProductStatus>((event, emit) async {
      if (state is ProductLoadSuccess) {
        final currentState = state as ProductLoadSuccess;
        try {
          emit(ProductLoading());
          await repo.updateProductStatus(event.productId, event.newStatus);

          final result = await repo.fetchProducts(
            page: currentState.currentPage,
            pageSize: currentState.pageSize,
            searchQuery: currentState.currentSearchQuery,
          );

          emit(
            ProductLoadSuccess(
              products: result.products,
              currentPage: result.currentPage,
              totalPages: result.totalPages,
              totalProducts: result.totalCount,
              pageSize: currentState.pageSize,
              currentSearchQuery: currentState.currentSearchQuery,
            ),
          );
        } catch (e) {
          emit(ProductOperationFailure(e.toString()));
        }
      }
    });

    on<DeleteProduct>((event, emit) async {
      if (state is ProductLoadSuccess) {
        final currentState = state as ProductLoadSuccess;
        emit(ProductLoading());
        try {
          await repo.deleteProduct(event.productId);

          int targetPage = currentState.currentPage;
          if (currentState.products.length == 1 &&
              currentState.currentPage > 1) {
            targetPage = currentState.currentPage - 1;
          }

          final result = await repo.fetchProducts(
            page: targetPage,
            pageSize: currentState.pageSize,
            searchQuery: currentState.currentSearchQuery,
          );

          emit(
            ProductLoadSuccess(
              products: result.products,
              currentPage: result.currentPage,
              totalPages: result.totalPages,
              totalProducts: result.totalCount,
              pageSize: currentState.pageSize,
              currentSearchQuery: currentState.currentSearchQuery,
            ),
          );
        } catch (err) {
          emit(ProductOperationFailure(err.toString()));
        }
      }
    });
  }
}
