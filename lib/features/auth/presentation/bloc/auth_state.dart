abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoadInProgress extends AuthState {}

class AuthLoadSuccess extends AuthState {
  final String token;
  final String? refreshToken;

  AuthLoadSuccess(this.token, {this.refreshToken});
}

class AuthLoadFailure extends AuthState {
  final String message;
  AuthLoadFailure(this.message);
}

class AuthLoggedOut extends AuthState {}

class AuthUserLoadInProgress extends AuthState {}

class AuthUserLoadSuccess extends AuthState {
  final String username;
  final String? profileImageUrl;

  AuthUserLoadSuccess(this.username, {this.profileImageUrl});
}

class AuthUserLoadFailure extends AuthState {
  final String message;
  AuthUserLoadFailure(this.message);
}
