import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;

  AuthBloc(this._repo) : super(AuthInitial()) {
    on<AuthCheckExistingToken>(_onCheckExistingToken);
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
      final token = await _repo.getAccessToken();

      emit(AuthLoadSuccess(token!));
      add(AuthUserRequested());
    } catch (e) {
      emit(AuthLoadFailure(e.toString()));
    }
  }

  Future<void> _onCheckExistingToken(
    AuthCheckExistingToken event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadInProgress());
    try {
      final token = await _repo.getAccessToken();
      if (token != null) {
        emit(AuthLoadSuccess(token));
      } else {
        emit(AuthInitial());
      }
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
    try {
      final user = await _repo.fetchCurrentUser(); // returns User
      emit(AuthUserLoadSuccess(user));
    } catch (e) {
      emit(AuthUserLoadFailure(e.toString()));
    }
  }
}
