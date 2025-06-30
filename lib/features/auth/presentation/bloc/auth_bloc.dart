import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;

  AuthBloc(this._repo) : super(AuthInitial()) {
    on<AuthInitialized>(_onAuthInitialized);
    on<AuthCheckExistingToken>(_onCheckExistingToken);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthUserRequested>(_onUserRequested);
  }

  Future<void> _onAuthInitialized(
    AuthInitialized event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Check if user has valid tokens
      final hasValidTokens = await _repo.hasValidTokens();

      if (hasValidTokens) {
        // Validate the access token
        final isTokenValid = await _repo.validateAccessToken();

        if (isTokenValid) {
          // Ensure role is properly set from stored token
          await _repo.initializeAuth();
          final token = await _repo.getAccessToken();
          emit(AuthLoadSuccess(token!));

          // Immediately fetch user data to get role
          add(AuthUserRequested());
        } else {
          // Try to refresh token
          final newToken = await _repo.refreshAccessToken();
          if (newToken != null) {
            emit(AuthLoadSuccess(newToken));
            add(AuthUserRequested());
          } else {
            await _repo.logout();
            emit(AuthLoggedOut());
          }
        }
      } else {
        emit(AuthLoggedOut());
      }
    } catch (e) {
      await _repo.logout();
      emit(AuthLoggedOut());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadInProgress());
    try {
      await _repo.login(identifier: event.identifier, password: event.password);

      await _repo.initializeAuth();

      final token = await _repo.getAccessToken();
      emit(AuthLoadSuccess(token!));
      try {
        final user = await _repo.fetchCurrentUser();
        emit(AuthUserLoadSuccess(user));
      } catch (userError) {
        add(AuthUserRequested());
      }
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
        await _repo.initializeAuth();
        emit(AuthLoadSuccess(token));
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
    if (state is! AuthLoadSuccess && state is! AuthUserLoadSuccess) {
      emit(AuthUserLoadInProgress());
    }

    try {
      final user = await _repo.fetchCurrentUser();
      emit(AuthUserLoadSuccess(user));
    } catch (e) {
      final errorMessage = e.toString();

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
