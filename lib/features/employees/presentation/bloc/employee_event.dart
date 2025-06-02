import 'package:equatable/equatable.dart';

abstract class EmployeeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadEmployees extends EmployeeEvent {
  final int page;
  final int pageSize;
  final String? searchQuery;

  LoadEmployees({this.page = 1, this.pageSize = 6, this.searchQuery});

  @override
  List<Object?> get props => [page, pageSize, searchQuery];
}

class SearchEmployees extends EmployeeEvent {
  final String query;
  final int page;
  final int pageSize;

  SearchEmployees({required this.query, this.page = 1, this.pageSize = 6});

  @override
  List<Object?> get props => [query, page, pageSize];
}

class ChangePage extends EmployeeEvent {
  final int page;
  final String? currentSearchQuery;

  ChangePage(this.page, {this.currentSearchQuery});

  @override
  List<Object?> get props => [page, currentSearchQuery];
}

class AddEmployee extends EmployeeEvent {
  final String username, email, password, cin, tel, role;

  AddEmployee({
    required this.username,
    required this.email,
    required this.password,
    required this.cin,
    required this.tel,
    required this.role,
  });

  @override
  List<Object?> get props => [username, email, password, cin, tel, role];
}

class UpdateEmployee extends EmployeeEvent {
  final int id;
  final String username;
  final String email;
  final String? password;
  final String cin;
  final String tel;
  final String role;

  UpdateEmployee({
    required this.id,
    required this.username,
    required this.email,
    this.password,
    required this.cin,
    required this.tel,
    required this.role,
  });

  @override
  List<Object?> get props => [id, username, email, password, cin, tel, role];
}

class UpdateEmployeeRole extends EmployeeEvent {
  final int userId;
  final String newRole;

  UpdateEmployeeRole(this.userId, this.newRole);

  @override
  List<Object?> get props => [userId, newRole];
}

class DeleteEmployee extends EmployeeEvent {
  final int userId;

  DeleteEmployee(this.userId);

  @override
  List<Object?> get props => [userId];
}

class EmployeeCreateRequested extends EmployeeEvent {
  final String username;
  final String email;
  final String password;
  final String cin;
  final String tel;
  final String role;

  EmployeeCreateRequested({
    required this.username,
    required this.email,
    required this.password,
    required this.cin,
    required this.tel,
    required this.role,
  });

  @override
  List<Object> get props => [username, email, password, cin, tel, role];
}
