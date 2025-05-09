import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/auth_repository.dart';

part 'password_reset_event.dart';
part 'password_reset_state.dart';

class PasswordResetBloc extends Bloc<PasswordResetEvent, PasswordResetState> {
  final AuthRepository _repo;

  PasswordResetBloc(this._repo) : super(ResetInitial()) {
    on<ResetEmailRequested>(_onResetEmailRequested);
    on<ResetConfirmRequested>(_onResetConfirmRequested);
  }

  Future<void> _onResetEmailRequested(
    ResetEmailRequested e,
    Emitter<PasswordResetState> emit,
  ) async {
    emit(ResetLoading());
    try {
      await _repo.requestPasswordReset(e.email);
      emit(ResetEmailSent());
    } catch (err) {
      emit(ResetFailure(err.toString()));
    }
  }

  Future<void> _onResetConfirmRequested(
    ResetConfirmRequested e,
    Emitter<PasswordResetState> emit,
  ) async {
    emit(ResetLoading());
    try {
      await _repo.confirmPasswordReset(e.token, e.newPassword);
      emit(ResetSuccess());
    } catch (err) {
      emit(ResetFailure(err.toString()));
    }
  }
}
