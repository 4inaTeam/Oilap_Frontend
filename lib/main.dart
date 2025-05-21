import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/password_reset_bloc.dart';
import '../features/parametres/presentation/bloc/profile_bloc.dart';
import 'features/parametres/data/profile_repository.dart';
import 'app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final backendUrl = kIsWeb ? 'http://localhost:8000' : 'http://127.0.0.1:8000';

  SharedPreferences? sharedPreferences;
  if (kIsWeb) {
    try {
      sharedPreferences = await SharedPreferences.getInstance();
      debugPrint('SharedPreferences initialized');
    } catch (e) {
      debugPrint('SharedPreferences error: $e');
    }
  }

  runApp(
    RepositoryProvider(
      create:
          (_) => AuthRepository(
            baseUrl: backendUrl,
            sharedPreferences: sharedPreferences,
          ),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (ctx) => AuthBloc(ctx.read<AuthRepository>())),
          BlocProvider(
            create: (ctx) => PasswordResetBloc(ctx.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (ctx) => ProfileBloc(ctx.read<ProfileRepository>()),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}
