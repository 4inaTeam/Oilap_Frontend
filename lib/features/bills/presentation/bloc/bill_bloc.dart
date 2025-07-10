import 'package:flutter_bloc/flutter_bloc.dart';
import 'bill_event.dart';
import 'bill_state.dart';
import '../../data/bill_repository.dart';

class BillBloc extends Bloc<BillEvent, BillState> {
  final BillRepository repo;

  BillBloc(this.repo) : super(BillInitial()) {
    on<LoadBills>((event, emit) async {
      emit(BillLoading());
      try {
        final result = await repo.fetchBills(
          page: event.page,
          pageSize: event.pageSize,
          searchQuery: event.searchQuery,
          categoryFilter: event.categoryFilter,
        );

        emit(
          BillLoadSuccess(
            bills: result.bills,
            currentPage: result.currentPage,
            totalPages: result.totalPages,
            totalBills: result.totalCount,
            pageSize: event.pageSize,
            currentSearchQuery: event.searchQuery,
            currentCategoryFilter: event.categoryFilter,
          ),
        );
      } catch (error) {
        emit(BillOperationFailure(error.toString()));
      }
    });

    on<SearchBills>((event, emit) async {
      emit(BillLoading());
      try {
        final result = await repo.fetchBills(
          page: event.page,
          pageSize: event.pageSize,
          searchQuery: event.query,
          categoryFilter: event.categoryFilter,
        );

        emit(
          BillLoadSuccess(
            bills: result.bills,
            currentPage: result.currentPage,
            totalPages: result.totalPages,
            totalBills: result.totalCount,
            pageSize: event.pageSize,
            currentSearchQuery: event.query,
            currentCategoryFilter: event.categoryFilter,
          ),
        );
      } catch (error) {
        emit(BillOperationFailure(error.toString()));
      }
    });

    on<FilterBillsByCategory>((event, emit) async {
      emit(BillLoading());
      try {
        final result = await repo.fetchBills(
          page: event.page,
          pageSize: event.pageSize,
          searchQuery: event.searchQuery,
          categoryFilter: event.category,
        );

        emit(
          BillLoadSuccess(
            bills: result.bills,
            currentPage: result.currentPage,
            totalPages: result.totalPages,
            totalBills: result.totalCount,
            pageSize: event.pageSize,
            currentSearchQuery: event.searchQuery,
            currentCategoryFilter: event.category,
          ),
        );
      } catch (error) {
        emit(BillOperationFailure(error.toString()));
      }
    });

    on<ChangePage>((event, emit) async {
      if (state is BillLoadSuccess) {
        final currentState = state as BillLoadSuccess;
        emit(BillLoading());

        try {
          final result = await repo.fetchBills(
            page: event.page,
            pageSize: currentState.pageSize,
            searchQuery: currentState.currentSearchQuery,
            categoryFilter: currentState.currentCategoryFilter,
          );

          emit(
            BillLoadSuccess(
              bills: result.bills,
              currentPage: result.currentPage,
              totalPages: result.totalPages,
              totalBills: result.totalCount,
              pageSize: currentState.pageSize,
              currentSearchQuery: currentState.currentSearchQuery,
              currentCategoryFilter: currentState.currentCategoryFilter,
            ),
          );
        } catch (error) {
          emit(BillOperationFailure(error.toString()));
        }
      }
    });

    on<CreateBill>((event, emit) async {
      emit(BillLoading());
      try {
        if (event.imageFile == null && event.webImage == null) {
          throw Exception('No image provided');
        }

        await repo.createBill(
          owner: event.owner,
          category: event.category,
          amount: event.amount,
          paymentDate: event.paymentDate,
          consumption: event.consumption,
          items: event.items,
          imageFile: event.imageFile,
          webImageBytes: event.webImage,
        );

        emit(BillCreateSuccess());

        final result = await repo.fetchBills(page: 1, pageSize: 10);
        emit(
          BillLoadSuccess(
            bills: result.bills,
            currentPage: result.currentPage,
            totalPages: result.totalPages,
            totalBills: result.totalCount,
            pageSize: 10,
          ),
        );
      } catch (error) {
        emit(BillOperationFailure(error.toString()));
      }
    });

    // Update an existing bill
    on<UpdateBill>((event, emit) async {
      emit(BillLoading());
      try {
        await repo.updateBill(
          id: event.id,
          owner: event.owner,
          category: event.category,
          amount: event.amount,
          paymentDate: event.paymentDate,
          consumption: event.consumption,
          items: event.items,
        );

        emit(BillUpdateSuccess());

        // Preserve current state when reloading
        int currentPage = 1;
        int pageSize = 10; // Changed default to 10
        String? searchQuery;
        String? categoryFilter;

        if (state is BillLoadSuccess) {
          final currentState = state as BillLoadSuccess;
          currentPage = currentState.currentPage;
          pageSize = currentState.pageSize;
          searchQuery = currentState.currentSearchQuery;
          categoryFilter = currentState.currentCategoryFilter;
        }

        final result = await repo.fetchBills(
          page: currentPage,
          pageSize: pageSize,
          searchQuery: searchQuery,
          categoryFilter: categoryFilter,
        );

        emit(
          BillLoadSuccess(
            bills: result.bills,
            currentPage: result.currentPage,
            totalPages: result.totalPages,
            totalBills: result.totalCount,
            pageSize: pageSize,
            currentSearchQuery: searchQuery,
            currentCategoryFilter: categoryFilter,
          ),
        );
      } catch (error) {
        emit(BillOperationFailure(error.toString()));
      }
    });

    // Delete a bill
    on<DeleteBill>((event, emit) async {
      if (state is BillLoadSuccess) {
        final currentState = state as BillLoadSuccess;
        emit(BillLoading());

        try {
          await repo.deleteBill(event.billId);

          // Adjust page if current page becomes empty after deletion
          int targetPage = currentState.currentPage;
          if (currentState.bills.length == 1 && currentState.currentPage > 1) {
            targetPage = currentState.currentPage - 1;
          }

          final result = await repo.fetchBills(
            page: targetPage,
            pageSize: currentState.pageSize,
            searchQuery: currentState.currentSearchQuery,
            categoryFilter: currentState.currentCategoryFilter,
          );

          emit(
            BillLoadSuccess(
              bills: result.bills,
              currentPage: result.currentPage,
              totalPages: result.totalPages,
              totalBills: result.totalCount,
              pageSize: currentState.pageSize,
              currentSearchQuery: currentState.currentSearchQuery,
              currentCategoryFilter: currentState.currentCategoryFilter,
            ),
          );
        } catch (error) {
          emit(BillOperationFailure(error.toString()));
        }
      }
    });

    on<LoadBillById>((event, emit) async {
      emit(BillLoading());
      try {
        final bill = await repo.fetchBillById(event.id);
        emit(BillDetailLoadSuccess(bill));
      } catch (error) {
        emit(BillOperationFailure(error.toString()));
      }
    });

    on<ClearBillState>((event, emit) {
      emit(BillInitial());
    });

    on<LoadDashboardBills>((event, emit) async {
      emit(BillLoading());
      try {
        final result = await repo.fetchBills(page: 1, pageSize: event.limit);

        emit(
          BillLoadSuccess(
            bills: result.bills,
            currentPage: result.currentPage,
            totalPages: result.totalPages,
            totalBills: result.totalCount,
            pageSize: event.limit,
          ),
        );
      } catch (error) {
        emit(BillOperationFailure(error.toString()));
      }
    });
  }
}
