import 'package:flutter_bloc/flutter_bloc.dart';
import 'comptable_event.dart';
import 'comptable_state.dart';
import '../../data/comptable_repository.dart';

class ComptableBloc extends Bloc<ComptableEvent, ComptableState> {
  final ComptableRepository repo;

  ComptableBloc(this.repo) : super(ComptableInitial()) {
    on<LoadComptables>((event, emit) async {
      emit(ComptableLoading());
      try {
        final result = await repo.fetchComptables(
          page: event.page,
          pageSize: event.pageSize,
          searchQuery: event.searchQuery,
        );

        emit(ComptableLoadSuccess(
          comptables: result.comptables,
          currentPage: result.currentPage,
          totalPages: result.totalPages,
          totalComptables: result.totalCount,
          pageSize: event.pageSize,
          currentSearchQuery: event.searchQuery,
        ));
      } catch (err) {
        emit(ComptableOperationFailure(err.toString()));
      }
    });

    on<SearchComptables>((event, emit) async {
      emit(ComptableLoading());
      try {
        final result = await repo.fetchComptables(
          page: event.page,
          pageSize: event.pageSize,
          searchQuery: event.query,
        );

        emit(ComptableLoadSuccess(
          comptables: result.comptables,
          currentPage: result.currentPage,
          totalPages: result.totalPages,
          totalComptables: result.totalCount,
          pageSize: event.pageSize,
          currentSearchQuery: event.query,
        ));
      } catch (err) {
        emit(ComptableOperationFailure(err.toString()));
      }
    });

    on<ChangePage>((event, emit) async {
      if (state is ComptableLoadSuccess) {
        final currentState = state as ComptableLoadSuccess;
        emit(ComptableLoading());

        try {
          final result = await repo.fetchComptables(
            page: event.page,
            pageSize: currentState.pageSize,
            searchQuery: event.currentSearchQuery,
          );

          emit(ComptableLoadSuccess(
            comptables: result.comptables,
            currentPage: result.currentPage,
            totalPages: result.totalPages,
            totalComptables: result.totalCount,
            pageSize: currentState.pageSize,
            currentSearchQuery: event.currentSearchQuery,
          ));
        } catch (err) {
          emit(ComptableOperationFailure(err.toString()));
        }
      }
    });

    on<AddComptable>((event, emit) async {
      emit(ComptableLoading());
      try {
        await repo.createComptable(
          username: event.username,
          email: event.email,
          password: event.password,
          cin: event.cin,
          tel: event.tel,
          role: event.role,
        );
        emit(ComptableAddSuccess());

        // Reload the first page after adding
        final result = await repo.fetchComptables(page: 1, pageSize: 8);
        emit(ComptableLoadSuccess(
          comptables: result.comptables,
          currentPage: result.currentPage,
          totalPages: result.totalPages,
          totalComptables: result.totalCount,
          pageSize: 8,
        ));
      } catch (err) {
        emit(ComptableOperationFailure(err.toString()));
      }
    });

    on<UpdateComptableRole>((event, emit) async {
      if (state is ComptableLoadSuccess) {
        final currentState = state as ComptableLoadSuccess;
        try {
          emit(ComptableLoading());
          await repo.updateRole(event.userId, event.newRole);

          final result = await repo.fetchComptables(
            page: currentState.currentPage,
            pageSize: currentState.pageSize,
            searchQuery: currentState.currentSearchQuery,
          );

          emit(ComptableLoadSuccess(
            comptables: result.comptables,
            currentPage: result.currentPage,
            totalPages: result.totalPages,
            totalComptables: result.totalCount,
            pageSize: currentState.pageSize,
            currentSearchQuery: currentState.currentSearchQuery,
          ));
        } catch (e) {
          emit(ComptableOperationFailure(e.toString()));
        }
      }
    });

    on<DeleteComptable>((event, emit) async {
      if (state is ComptableLoadSuccess) {
        final currentState = state as ComptableLoadSuccess;
        emit(ComptableLoading());
        try {
          await repo.deleteComptable(event.userId);

          int targetPage = currentState.currentPage;
          if (currentState.comptables.length == 1 && currentState.currentPage > 1) {
            targetPage = currentState.currentPage - 1;
          }

          final result = await repo.fetchComptables(
            page: targetPage,
            pageSize: currentState.pageSize,
            searchQuery: currentState.currentSearchQuery,
          );

          emit(ComptableLoadSuccess(
            comptables: result.comptables,
            currentPage: result.currentPage,
            totalPages: result.totalPages,
            totalComptables: result.totalCount,
            pageSize: currentState.pageSize,
            currentSearchQuery: currentState.currentSearchQuery,
          ));
        } catch (err) {
          emit(ComptableOperationFailure(err.toString()));
        }
      }
    });

    on<UpdateComptable>((event, emit) async {
      emit(ComptableLoading());
      try {
        await repo.updateComptable(
          id: event.id,
          username: event.username,
          email: event.email,
          password: event.password,
          cin: event.cin,
          tel: event.tel,
          role: event.role,
        );
        
        emit(ComptableUpdateSuccess());

        final currentState = state;
        int currentPage = 1;
        int pageSize = 8;
        String? searchQuery;

        if (currentState is ComptableLoadSuccess) {
          currentPage = currentState.currentPage;
          pageSize = currentState.pageSize;
          searchQuery = currentState.currentSearchQuery;
        }

        final result = await repo.fetchComptables(
          page: currentPage,
          pageSize: pageSize,
          searchQuery: searchQuery,
        );
        
        emit(ComptableLoadSuccess(
          comptables: result.comptables,
          currentPage: result.currentPage,
          totalPages: result.totalPages,
          totalComptables: result.totalCount,
          pageSize: pageSize,
          currentSearchQuery: searchQuery,
        ));
      } catch (err) {
        emit(ComptableOperationFailure(err.toString()));
      }
    });
  }
}