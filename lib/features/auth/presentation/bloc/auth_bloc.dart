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
        // Automatically fetch user data when we have a valid token
        add(AuthUserRequested());
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
    // Don't emit loading state if we're already authenticated
    if (state is! AuthLoadSuccess) {
      emit(AuthUserLoadInProgress());
    }

    try {
      final user = await _repo.fetchCurrentUser();
      emit(AuthUserLoadSuccess(user));
    } catch (e) {
      final errorMessage = e.toString();
      print('User fetch error: $errorMessage');

      // If authentication failed completely, logout the user
      if (errorMessage.contains('please login again') ||
          errorMessage.contains('No access token available')) {
        await _repo.logout();
        emit(AuthLoggedOut());
      } else {
        emit(AuthUserLoadFailure(errorMessage));
      }
    }
  }
}