import 'package:flutter_bloc/flutter_bloc.dart';
import 'employee_event.dart';
import 'employee_state.dart';
import '../../data/employee_repository.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final EmployeeRepository repo;
  EmployeeBloc(this.repo) : super(EmployeeInitial()) {
    on<LoadEmployees>((e, emit) async {
      emit(EmployeeLoading());
      try {
        final list = await repo.fetchEmployees();
        emit(EmployeeLoadSuccess(list));
      } catch (err) {
        emit(EmployeeOperationFailure(err.toString()));
      }
    });
    on<AddEmployee>((e, emit) async {
      emit(EmployeeLoading());
      try {
        await repo.createEmployee(
          username: e.username,
          email: e.email,
          password: e.password,
          cin: e.cin,
          tel: e.tel,
          role: e.role,
        );
        emit(EmployeeAddSuccess());
        final list = await repo.fetchEmployees();
        emit(EmployeeLoadSuccess(list));
      } catch (err) {
        emit(EmployeeOperationFailure(err.toString()));
      }
    });

    on<UpdateEmployeeRole>((event, emit) async {
      try {
        emit(EmployeeLoading());
        await repo.updateRole(event.userId, event.newRole);
        final updatedList = await repo.fetchEmployees();
        emit(EmployeeLoadSuccess(updatedList));
      } catch (e) {
        emit(EmployeeOperationFailure(e.toString()));
      }
    });

    on<DeleteEmployee>((event, emit) async {
      emit(EmployeeLoading());
      try {
        await repo.deleteEmployee(event.userId);
        final list = await repo.fetchEmployees();
        emit(EmployeeLoadSuccess(list));
      } catch (err) {
        emit(EmployeeOperationFailure(err.toString()));
      }
    });
  }
}
