abstract class AuthEvent {}

/// Triggered when the user taps “Se connecter”
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String cin;
  final String password;
  AuthLoginRequested(this.email, this.cin, this.password);
}
