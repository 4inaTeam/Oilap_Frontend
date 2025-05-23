import 'package:equatable/equatable.dart';

abstract class ComptableEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadComptables extends ComptableEvent {}

class AddComptable extends ComptableEvent {
  final String username, email, password, cin, tel, role;
  AddComptable({
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

class UpdateComptableRole extends ComptableEvent {
  final int userId;
  final String newRole;

  UpdateComptableRole(this.userId, this.newRole);
  @override
  List<Object?> get props => [userId, newRole];
}

class DeleteComptable extends ComptableEvent {
  final int userId;

  DeleteComptable(this.userId);
  @override
  List<Object?> get props => [userId];
}