part of 'password_reset_bloc.dart';

abstract class PasswordResetEventBase extends Equatable {
  @override
  List<Object?> get props => [];
}

class EmailResetRequested extends PasswordResetEventBase {
  final String email;
  EmailResetRequested(this.email);
  @override
  List<Object?> get props => [email];
}

class ConfirmResetRequested extends PasswordResetEventBase {
  final String token;
  final String newPassword;
  ConfirmResetRequested(this.token, this.newPassword);
  @override
  List<Object?> get props => [token, newPassword];
}
