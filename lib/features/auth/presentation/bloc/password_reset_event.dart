part of 'password_reset_bloc.dart';

abstract class PasswordResetEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ResetEmailRequested extends PasswordResetEvent {
  final String email;
  ResetEmailRequested(this.email);
  @override
  List<Object?> get props => [email];
}

class ResetConfirmRequested extends PasswordResetEvent {
  final String token;
  final String newPassword;
  ResetConfirmRequested(this.token, this.newPassword);
  @override
  List<Object?> get props => [token, newPassword];
}
