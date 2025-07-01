import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String identifier;
  final String password;

  AuthLoginRequested(this.identifier, this.password);

  @override
  List<Object> get props => [identifier, password];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthUserRequested extends AuthEvent {}

class AuthCheckExistingToken extends AuthEvent {}

class AuthInitialized extends AuthEvent {
  @override
  List<Object> get props => [];
}

class AuthUserRefreshRequested extends AuthEvent {
  final bool forceRefresh;

  AuthUserRefreshRequested({this.forceRefresh = false});

  @override
  List<Object> get props => [forceRefresh];
}
