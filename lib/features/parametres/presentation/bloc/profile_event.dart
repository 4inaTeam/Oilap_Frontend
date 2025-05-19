import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? tel;
  final String? password;
  final File?   photo;

  UpdateProfile({
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.tel,
    this.password,
    this.photo,
  });

  @override
  List<Object?> get props =>
      [username, email, firstName, lastName, tel, password, photo];
}
