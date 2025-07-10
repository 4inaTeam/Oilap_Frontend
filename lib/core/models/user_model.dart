import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String cin;
  final String? tel;
  final String role;
  final String? profilePhotoUrl;
  final bool isActive;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.cin,
    this.tel,
    required this.role,
    this.profilePhotoUrl,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as int? ?? 0,
    name: json['username'] as String? ?? json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    cin: json['cin'] as String? ?? '',
    tel: json['tel'] as String?,
    role: json['role'] as String? ?? 'CLIENT',
    profilePhotoUrl: json['profile_photo'] as String?,
    isActive: json['isActive'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': name,
    'email': email,
    'cin': cin,
    'tel': tel,
    'role': role,
    'profile_photo': profilePhotoUrl,
    'isActive': isActive,
  };

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    cin,
    tel,
    role,
    profilePhotoUrl,
    isActive,
  ];
}
