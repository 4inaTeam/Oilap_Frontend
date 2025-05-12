// lib/features/auth/bloc/password_reset_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/auth_repository.dart';

part 'password_reset_event.dart';

class PasswordResetBloc extends Bloc<PasswordResetEvent, PasswordResetState> {
  final AuthRepository _repo;

  PasswordResetBloc(this._repo) : super(ResetInitial()) {
    on<ResetEmailRequested>(_onResetEmailRequested);
    on<ResetConfirmRequested>(_onResetConfirmRequested);
  }

  Future<void> _onResetEmailRequested(
    ResetEmailRequested event,
    Emitter<PasswordResetState> emit,
  ) async {
    emit(ResetLoading());
    try {
      await _repo.requestPasswordReset(event.email);
      emit(ResetEmailSent());
    } catch (err) {
      emit(ResetFailure(err.toString()));
    }
  }

  Future<void> _onResetConfirmRequested(
    ResetConfirmRequested event,
    Emitter<PasswordResetState> emit,
  ) async {
    emit(ResetLoading());
    try {
      await _repo.confirmPasswordReset(event.token, event.newPassword);
      emit(ResetSuccess());
    } catch (err) {
      emit(ResetFailure(err.toString()));
    }
  }
}

// lib/features/auth/bloc/password_reset_event.dart

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

// lib/features/auth/bloc/password_reset_state.dart

abstract class PasswordResetState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ResetInitial extends PasswordResetState {}

class ResetLoading extends PasswordResetState {}

/// Emitted when the server has accepted the reset email request
class ResetEmailSent extends PasswordResetState {}

/// Emitted when the server has successfully changed the password
class ResetSuccess extends PasswordResetState {}

/// Emitted when any step fails; carries an error message
class ResetFailure extends PasswordResetState {
  final String message;
  ResetFailure(this.message);

  @override
  List<Object?> get props => [message];
}
