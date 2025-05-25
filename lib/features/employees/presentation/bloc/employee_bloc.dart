import 'package:flutter_bloc/flutter_bloc.dart';
import 'employee_event.dart';
import 'employee_state.dart';
import '../../data/employee_repository.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final EmployeeRepository repo;

  EmployeeBloc(this.repo) : super(EmployeeInitial()) {
    on<LoadEmployees>((event, emit) async {
      emit(EmployeeLoading());
      try {
        final result = await repo.fetchEmployees(
          page: event.page,
          pageSize: event.pageSize,
          searchQuery: event.searchQuery,
        );

        emit(EmployeeLoadSuccess(
          employees: result.employees,
          currentPage: result.currentPage,
          totalPages: result.totalPages,
          totalEmployees: result.totalCount,
          pageSize: event.pageSize,
          currentSearchQuery: event.searchQuery,
        ));
      } catch (err) {
        emit(EmployeeOperationFailure(err.toString()));
      }
    });

    on<SearchEmployees>((event, emit) async {
      emit(EmployeeLoading());
      try {
        final result = await repo.fetchEmployees(
          page: event.page,
          pageSize: event.pageSize,
          searchQuery: event.query,
        );

        emit(EmployeeLoadSuccess(
          employees: result.employees,
          currentPage: result.currentPage,
          totalPages: result.totalPages,
          totalEmployees: result.totalCount,
          pageSize: event.pageSize,
          currentSearchQuery: event.query,
        ));
      } catch (err) {
        emit(EmployeeOperationFailure(err.toString()));
      }
    });

    on<ChangePage>((event, emit) async {
      if (state is EmployeeLoadSuccess) {
        final currentState = state as EmployeeLoadSuccess;
        emit(EmployeeLoading());

        try {
          final result = await repo.fetchEmployees(
            page: event.page,
            pageSize: currentState.pageSize,
            searchQuery: event.currentSearchQuery,
          );

          emit(EmployeeLoadSuccess(
            employees: result.employees,
            currentPage: result.currentPage,
            totalPages: result.totalPages,
            totalEmployees: result.totalCount,
            pageSize: currentState.pageSize,
            currentSearchQuery: event.currentSearchQuery,
          ));
        } catch (err) {
          emit(EmployeeOperationFailure(err.toString()));
        }
      }
    });

    on<AddEmployee>((event, emit) async {
      emit(EmployeeLoading());
      try {
        await repo.createEmployee(
          username: event.username,
          email: event.email,
          password: event.password,
          cin: event.cin,
          tel: event.tel,
          role: event.role,
        );
        emit(EmployeeAddSuccess());

        // Reload the first page after adding
        final result = await repo.fetchEmployees(page: 1, pageSize: 8);
        emit(EmployeeLoadSuccess(
          employees: result.employees,
          currentPage: result.currentPage,
          totalPages: result.totalPages,
          totalEmployees: result.totalCount,
          pageSize: 8,
        ));
      } catch (err) {
        emit(EmployeeOperationFailure(err.toString()));
      }
    });

    // *** NEW: UpdateEmployee handler ***
    on<UpdateEmployee>((event, emit) async {
      emit(EmployeeLoading());
      try {
        await repo.updateEmployee(
          id: event.id,
          username: event.username,
          email: event.email,
          password: event.password,
          cin: event.cin,
          tel: event.tel,
          role: event.role,
        );
        
        emit(EmployeeUpdateSuccess());

        // Reload current page after updating
        final currentState = state;
        int currentPage = 1;
        int pageSize = 8;
        String? searchQuery;

        if (currentState is EmployeeLoadSuccess) {
          currentPage = currentState.currentPage;
          pageSize = currentState.pageSize;
          searchQuery = currentState.currentSearchQuery;
        }

        final result = await repo.fetchEmployees(
          page: currentPage,
          pageSize: pageSize,
          searchQuery: searchQuery,
        );
        
        emit(EmployeeLoadSuccess(
          employees: result.employees,
          currentPage: result.currentPage,
          totalPages: result.totalPages,
          totalEmployees: result.totalCount,
          pageSize: pageSize,
          currentSearchQuery: searchQuery,
        ));
      } catch (err) {
        emit(EmployeeOperationFailure(err.toString()));
      }
    });

    on<UpdateEmployeeRole>((event, emit) async {
      if (state is EmployeeLoadSuccess) {
        final currentState = state as EmployeeLoadSuccess;
        try {
          emit(EmployeeLoading());
          await repo.updateRole(event.userId, event.newRole);

          final result = await repo.fetchEmployees(
            page: currentState.currentPage,
            pageSize: currentState.pageSize,
            searchQuery: currentState.currentSearchQuery,
          );

          emit(EmployeeLoadSuccess(
            employees: result.employees,
            currentPage: result.currentPage,
            totalPages: result.totalPages,
            totalEmployees: result.totalCount,
            pageSize: currentState.pageSize,
            currentSearchQuery: currentState.currentSearchQuery,
          ));
        } catch (e) {
          emit(EmployeeOperationFailure(e.toString()));
        }
      }
    });

    on<DeleteEmployee>((event, emit) async {
      if (state is EmployeeLoadSuccess) {
        final currentState = state as EmployeeLoadSuccess;
        emit(EmployeeLoading());
        try {
          await repo.deleteEmployee(event.userId);

          // Check if we need to go to previous page after deletion
          int targetPage = currentState.currentPage;
          if (currentState.employees.length == 1 && currentState.currentPage > 1) {
            targetPage = currentState.currentPage - 1;
          }

          final result = await repo.fetchEmployees(
            page: targetPage,
            pageSize: currentState.pageSize,
            searchQuery: currentState.currentSearchQuery,
          );

          emit(EmployeeLoadSuccess(
            employees: result.employees,
            currentPage: result.currentPage,
            totalPages: result.totalPages,
            totalEmployees: result.totalCount,
            pageSize: currentState.pageSize,
            currentSearchQuery: currentState.currentSearchQuery,
          ));
        } catch (err) {
          emit(EmployeeOperationFailure(err.toString()));
        }
      }
    });
  }
}