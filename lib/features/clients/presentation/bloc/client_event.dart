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

// Updated UpdateClient event
class UpdateClient extends ClientEvent {
  final int clientId;
  final String username;
  final String email;
  final String cin;
  final String tel;
  final String? password; // Optional password update

  UpdateClient({
    required this.clientId,
    required this.username,
    required this.email,
    required this.cin,
    required this.tel,
    this.password,
  });

  @override
  List<Object?> get props => [clientId, username, email, cin, tel, password];
}

class DisactivateClient extends ClientEvent {
  final int userId;

  DisactivateClient(this.userId);

  @override
  List<Object?> get props => [userId];
}

// New event to get client details for update
class GetClientForUpdate extends ClientEvent {
  final int clientId;

  GetClientForUpdate(this.clientId);

  @override
  List<Object?> get props => [clientId];
}

// New event to view client profile
class ViewClientProfile extends ClientEvent {
  final int clientId;

  ViewClientProfile(this.clientId);

  @override
  List<Object?> get props => [clientId];
}