import 'package:equatable/equatable.dart';
import '../../data/user_model.dart';

abstract class EmployeeState extends Equatable {
  @override List<Object?> get props => [];
}

class EmployeeInitial extends EmployeeState {}
class EmployeeLoading extends EmployeeState {}
class EmployeeLoadSuccess extends EmployeeState {
  final List<User> employees;
  EmployeeLoadSuccess(this.employees);
  @override List<Object?> get props => [employees];
}
class EmployeeOperationFailure extends EmployeeState {
  final String message;
  EmployeeOperationFailure(this.message);
  @override List<Object?> get props => [message];
}
class EmployeeAddSuccess extends EmployeeState {}
