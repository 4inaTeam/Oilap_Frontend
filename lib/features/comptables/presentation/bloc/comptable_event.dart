import 'package:equatable/equatable.dart';

abstract class ComptableEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadComptables extends ComptableEvent {
  final int page;
  final int pageSize;
  final String? searchQuery;

  LoadComptables({
    this.page = 1,
    this.pageSize = 6,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [page, pageSize, searchQuery];
}

class SearchComptables extends ComptableEvent {
  final String query;
  final int page;
  final int pageSize;

  SearchComptables({
    required this.query,
    this.page = 1,
    this.pageSize = 6,
  });

  @override
  List<Object?> get props => [query, page, pageSize];
}

class ChangePage extends ComptableEvent {
  final int page;
  final String? currentSearchQuery;

  ChangePage(this.page, {this.currentSearchQuery});

  @override
  List<Object?> get props => [page, currentSearchQuery];
}

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

class UpdateComptable extends ComptableEvent {
  final int id;
  final String username;
  final String email;
  final String? password;
  final String cin;
  final String tel;
  final String role;

  UpdateComptable({
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