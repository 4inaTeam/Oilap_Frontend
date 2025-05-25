import 'package:equatable/equatable.dart';

abstract class ClientEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadClients extends ClientEvent {
  final int page;
  final int pageSize;
  final String? searchQuery;

  LoadClients({
    this.page = 1,
    this.pageSize = 6,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [page, pageSize, searchQuery];
}

class SearchClients extends ClientEvent {
  final String query;
  final int page;
  final int pageSize;

  SearchClients({
    required this.query,
    this.page = 1,
    this.pageSize = 6,
  });

  @override
  List<Object?> get props => [query, page, pageSize];
}

class ChangePage extends ClientEvent {
  final int page;
  final String? currentSearchQuery;

  ChangePage(this.page, {this.currentSearchQuery});

  @override
  List<Object?> get props => [page, currentSearchQuery];
}

class AddClient extends ClientEvent {
  final String username, email, password, cin, tel, role;

  AddClient({
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

class UpdateClientRole extends ClientEvent {
  final int userId;
  final String newRole;

  UpdateClientRole(this.userId, this.newRole);

  @override
  List<Object?> get props => [userId, newRole];
}

class DeleteClient extends ClientEvent {
  final int userId;

  DeleteClient(this.userId);

  @override
  List<Object?> get props => [userId];
}