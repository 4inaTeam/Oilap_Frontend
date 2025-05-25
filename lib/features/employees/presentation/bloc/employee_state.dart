import 'package:equatable/equatable.dart';
import '../../../../core/models/user_model.dart';

abstract class EmployeeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EmployeeInitial extends EmployeeState {}

class EmployeeLoading extends EmployeeState {}

class EmployeeLoadSuccess extends EmployeeState {
  final List<User> employees;
  final int currentPage;
  final int totalPages;
  final int totalEmployees;
  final int pageSize;
  final String? currentSearchQuery;

  EmployeeLoadSuccess({
    required this.employees,
    required this.currentPage,
    required this.totalPages,
    required this.totalEmployees,
    required this.pageSize,
    this.currentSearchQuery,
  });

  @override
  List<Object?> get props => [
    employees,
    currentPage,
    totalPages,
    totalEmployees,
    pageSize,
    currentSearchQuery,
  ];

  EmployeeLoadSuccess copyWith({
    List<User>? employees,
    int? currentPage,
    int? totalPages,
    int? totalEmployees,
    int? pageSize,
    String? currentSearchQuery,
  }) {
    return EmployeeLoadSuccess(
      employees: employees ?? this.employees,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalEmployees: totalEmployees ?? this.totalEmployees,
      pageSize: pageSize ?? this.pageSize,
      currentSearchQuery: currentSearchQuery ?? this.currentSearchQuery,
    );
  }
}

class EmployeeOperationFailure extends EmployeeState {
  final String message;
  EmployeeOperationFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class EmployeeAddSuccess extends EmployeeState {}

class EmployeeUpdateSuccess extends EmployeeState {}