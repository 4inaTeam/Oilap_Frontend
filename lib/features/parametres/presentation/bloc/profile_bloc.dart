// lib/features/profile/bloc/profile_bloc.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import '../../data/profile_repository.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repo;

  ProfileBloc(this._repo) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoad);
    on<UpdateProfile>(_onUpdate);
  }

  Future<void> _onLoad(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    // Optionally fetch current user data from API
  }

  Future<void> _onUpdate(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final data = await _repo.updateProfile(
        username: event.username,
        email: event.email,
        photo: event.photo,
        firstName: event.firstName,
        lastName: event.lastName,
        tel: event.tel,
        password: event.password,
      );
      emit(ProfileLoaded(data));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
