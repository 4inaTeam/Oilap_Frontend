part of 'password_reset_bloc.dart';

abstract class PasswordResetState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ResetInitial extends PasswordResetState {}

class ResetLoading extends PasswordResetState {}

class ResetEmailSent extends PasswordResetState {}

class ResetSuccess extends PasswordResetState {}

class ResetFailure extends PasswordResetState {
  final String message;
  ResetFailure(this.message);
  @override
  List<Object?> get props => [message];
}
