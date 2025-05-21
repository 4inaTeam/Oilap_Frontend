import 'package:equatable/equatable.dart';

abstract class EmployeeEvent extends Equatable {
  @override List<Object?> get props => [];
}

class LoadEmployees extends EmployeeEvent {}

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
  @override List<Object?> get props => [username, email, password, cin, tel, role];
}
