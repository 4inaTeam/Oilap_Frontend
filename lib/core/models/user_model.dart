class User {
  final int id;
  final String name;
  final String email;
  final String cin;
  final String? tel;
  final String role;
  final String? profileImageUrl;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.cin,
    this.tel,
    required this.role,
    this.profileImageUrl,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as int? ?? 0,
    name: json['username'] as String? ?? json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    cin: json['cin'] as String? ?? '',
    tel: json['tel'] as String?,
    role: json['role'] as String? ?? 'CLIENT',
    profileImageUrl: json['profile_photo'] as String?,
    isActive: json['isActive'] as bool? ?? false,
  );
}
