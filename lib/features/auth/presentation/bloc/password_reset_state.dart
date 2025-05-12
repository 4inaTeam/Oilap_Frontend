// lib/features/auth/bloc/password_reset_state.dart

import 'package:equatable/equatable.dart';

abstract class PasswordResetState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ResetInitial extends PasswordResetState {}

class ResetLoading extends PasswordResetState {}

/// Emitted when the reset e-mail has been accepted by the server
class ResetEmailSent extends PasswordResetState {}

/// Emitted when the confirm endpoint succeeds
class ResetSuccess extends PasswordResetState {}

/// Emitted on any failure; carries the error message
class ResetFailure extends PasswordResetState {
  final String message;
  ResetFailure(this.message);
  @override
  List<Object?> get props => [message];
}
