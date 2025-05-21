abstract class AuthEvent {}

/// Triggered when the user taps “Se connecter”
class AuthLoginRequested extends AuthEvent {
  final String identifier;
  final String password;

  AuthLoginRequested(this.identifier, this.password);
}

class AuthLogoutRequested extends AuthEvent {}

class AuthUserRequested extends AuthEvent {}

class AuthCheckExistingToken extends AuthEvent {} 
