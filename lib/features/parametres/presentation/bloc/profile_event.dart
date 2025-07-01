import 'dart:io';
import 'dart:typed_data';

abstract class ProfileEvent {}

class LoadCurrentUser extends ProfileEvent {}

class RefreshProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final String name;
  final String email;
  final String cin;
  final String? tel;
  final String? password;
  final File? profilePhoto;
  final Uint8List? profilePhotoBytes; 

  UpdateProfile({
    required this.name,
    required this.email,
    required this.cin,
    this.tel,
    this.password,
    this.profilePhoto,
    this.profilePhotoBytes,
  });
}