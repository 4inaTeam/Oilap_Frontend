// lib/features/auth/bloc/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;

  AuthBloc(this._repo) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadInProgress());
    try {
      final tokens = await _repo.login(
        email: event.email,
        cin: event.cin,
        password: event.password,
      );
      // TODO: store tokens.access / tokens.refresh in secure storage
      emit(AuthLoadSuccess());
    } catch (e) {
      emit(AuthLoadFailure(e.toString()));
    }
  }
}
