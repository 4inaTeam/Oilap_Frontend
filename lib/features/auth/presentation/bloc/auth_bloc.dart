// lib/features/auth/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;

  AuthBloc(this._repo) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);

    on<AuthLogoutRequested>(_onLogoutRequested);

    on<AuthUserRequested>(_onUserRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadInProgress());
    try {
      await _repo.login(identifier: event.identifier, password: event.password);
      emit(AuthLoadSuccess());
    } catch (e) {
      emit(AuthLoadFailure(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repo.logout();
    emit(AuthLoggedOut());
  }

  Future<void> _onUserRequested(
    AuthUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthUserLoadInProgress());
    try {
      final userMap = await _repo.fetchCurrentUser();
      final username =
          userMap['username'] as String? ?? userMap['cin'] as String;

      emit(AuthUserLoadSuccess(username));
    } catch (e) {
      emit(AuthUserLoadFailure(e.toString()));
    }
  }
}
