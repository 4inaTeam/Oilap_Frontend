import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/profile_repository.dart';
import '../../../auth/data/auth_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;
  final AuthRepository _authRepository;

  ProfileBloc(this._repository, this._authRepository)
    : super(ProfileInitial()) {
    on<LoadCurrentUser>(_onLoadCurrentUser);
    on<UpdateProfile>(_onUpdateProfile);
    on<RefreshProfile>(_onRefreshProfile);
  }

  Future<void> _onLoadCurrentUser(
    LoadCurrentUser event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileLoading());

      final hasTokens = await _authRepository.hasValidTokens();

      if (!hasTokens) {
        emit(ProfileError('Aucune session active. Veuillez vous reconnecter.'));
        return;
      }

      final isTokenValid = await _authRepository.validateAccessToken();

      if (!isTokenValid) {
        final newToken = await _authRepository.refreshAccessToken();
        if (newToken == null) {
          emit(ProfileError('Session expirée. Veuillez vous reconnecter.'));
          return;
        }
      }

      final user = await _repository.getCurrentUser();
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError(_formatErrorMessage(e.toString())));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileLoading());

      final hasTokens = await _authRepository.hasValidTokens();
      if (!hasTokens) {
        emit(ProfileError('Session expirée. Veuillez vous reconnecter.'));
        return;
      }

      final updatedUser = await _repository.updateProfile(
        name: event.name,
        email: event.email,
        cin: event.cin,
        tel: event.tel,
        password: event.password,
        profilePhoto: event.profilePhoto,
        profilePhotoBytes: event.profilePhotoBytes, // Add this line
      );

      emit(ProfileUpdated(updatedUser));

      await Future.delayed(const Duration(milliseconds: 500));
      emit(ProfileLoaded(updatedUser));
    } catch (e) {
      emit(ProfileError(_formatErrorMessage(e.toString())));
    }
  }

  Future<void> _onRefreshProfile(
    RefreshProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final hasTokens = await _authRepository.hasValidTokens();
      if (!hasTokens) {
        emit(ProfileError('Session expirée. Veuillez vous reconnecter.'));
        return;
      }

      final user = await _repository.getCurrentUser();
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError(_formatErrorMessage(e.toString())));
    }
  }

  String _formatErrorMessage(String errorMessage) {
    String cleanMessage = errorMessage
        .replaceFirst('Exception: ', '')
        .replaceFirst('Error: ', '')
        .replaceFirst('Error updating profile: ', '')
        .replaceFirst('Error loading user profile: ', '');

    if (cleanMessage.contains('Authentication failed') ||
        cleanMessage.contains('No authentication token found')) {
      return 'Session expirée. Veuillez vous reconnecter.';
    }

    if (cleanMessage.contains('Network') ||
        cleanMessage.contains('Connection') ||
        cleanMessage.contains('SocketException')) {
      return 'Problème de connexion. Vérifiez votre connexion internet.';
    }

    if (cleanMessage.contains('email') &&
        cleanMessage.contains('already exists')) {
      return 'Cette adresse email est déjà utilisée.';
    }

    if (cleanMessage.contains('cin') &&
        cleanMessage.contains('already exists')) {
      return 'Ce numéro CIN est déjà utilisé.';
    }

    if (cleanMessage.contains('HTTP 400')) {
      return 'Données invalides. Vérifiez vos informations.';
    }

    if (cleanMessage.contains('HTTP 401')) {
      return 'Session expirée. Veuillez vous reconnecter.';
    }

    if (cleanMessage.contains('HTTP 403')) {
      return 'Accès refusé. Vous n\'avez pas les permissions nécessaires.';
    }

    if (cleanMessage.contains('HTTP 404')) {
      return 'Ressource non trouvée. Contactez le support.';
    }

    if (cleanMessage.contains('HTTP 500')) {
      return 'Erreur serveur. Réessayez plus tard.';
    }

    return cleanMessage.isNotEmpty ? cleanMessage : 'Une erreur est survenue.';
  }
}
