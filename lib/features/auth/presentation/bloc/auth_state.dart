// lib/features/auth/bloc/auth_state.dart
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoadInProgress extends AuthState {}

class AuthLoadSuccess extends AuthState {}

class AuthLoadFailure extends AuthState {
  final String message;
  AuthLoadFailure(this.message);
}
