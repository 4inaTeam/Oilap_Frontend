import 'package:equatable/equatable.dart';
import '../../../../core/models/user_model.dart';

abstract class ClientState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ClientInitial extends ClientState {}

class ClientLoading extends ClientState {}

class ClientLoadSuccess extends ClientState {
  final List<User> clients;
  final int currentPage;
  final int totalPages;
  final int totalClients;
  final int pageSize;
  final String? currentSearchQuery;

  ClientLoadSuccess({
    required this.clients,
    required this.currentPage,
    required this.totalPages,
    required this.totalClients,
    required this.pageSize,
    this.currentSearchQuery,
  });

  @override
  List<Object?> get props => [
    clients,
    currentPage,
    totalPages,
    totalClients,
    pageSize,
    currentSearchQuery,
  ];

  ClientLoadSuccess copyWith({
    List<User>? clients,
    int? currentPage,
    int? totalPages,
    int? totalClients,
    int? pageSize,
    String? currentSearchQuery,
  }) {
    return ClientLoadSuccess(
      clients: clients ?? this.clients,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalClients: totalClients ?? this.totalClients,
      pageSize: pageSize ?? this.pageSize,
      currentSearchQuery: currentSearchQuery ?? this.currentSearchQuery,
    );
  }
}

class ClientOperationFailure extends ClientState {
  final String message;
  ClientOperationFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class ClientAddSuccess extends ClientState {}

// New state for successful client update
class ClientUpdateSuccess extends ClientState {}

// New state for client deactivate success
class ClientDeactivateSuccess extends ClientState {}

// New state for client details loaded for update
class ClientDetailsLoaded extends ClientState {
  final User client;

  ClientDetailsLoaded(this.client);

  @override
  List<Object?> get props => [client];
}

// New state for client profile view
class ClientProfileLoaded extends ClientState {
  final User client;

  ClientProfileLoaded(this.client);

  @override
  List<Object?> get props => [client];
}