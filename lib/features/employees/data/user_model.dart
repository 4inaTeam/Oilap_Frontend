class User {
  final int id;
  final String username;
  final String email;
  final String cin;
  final String tel;
  final String role;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.cin,
    required this.tel,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    username: json['username'],
    email: json['email'],
    cin: json['cin'],
    tel: json['tel'],
    role: json['role'],
  );
}
