import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:oilab_frontend/features/clients/presentation/bloc/client_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:oilab_frontend/app.dart';

import 'package:oilab_frontend/features/auth/data/auth_repository.dart';
import 'package:oilab_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:oilab_frontend/features/auth/presentation/bloc/password_reset_bloc.dart';
import 'package:oilab_frontend/features/comptables/data/comptable_repository.dart';
import 'package:oilab_frontend/features/comptables/presentation/bloc/comptable_bloc.dart';
import 'package:oilab_frontend/features/employees/data/employee_repository.dart';
import 'package:oilab_frontend/features/employees/presentation/bloc/employee_bloc.dart';
import 'package:oilab_frontend/features/parametres/data/profile_repository.dart';
import 'package:oilab_frontend/features/parametres/presentation/bloc/profile_bloc.dart';

import 'features/clients/data/client_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String backendUrl;
  if (kIsWeb) {
    backendUrl = 'http://localhost:8000';
  } else {
    backendUrl = 'http://192.168.100.8:8000';
  }

  SharedPreferences? sharedPreferences;

  if (kIsWeb) {
    try {
      sharedPreferences = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('SharedPreferences error: $e');
    }
  }

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (_) => AuthRepository(
            baseUrl: backendUrl,
            sharedPreferences: sharedPreferences,
          ),
        ),
        RepositoryProvider(
          create: (_) => ProfileRepository(baseUrl: backendUrl),
        ),
        RepositoryProvider(
          create: (context) => EmployeeRepository(
            baseUrl: backendUrl,
            authRepo: context.read(),
          ),
        ),
        RepositoryProvider(
          create: (context) => ComptableRepository(
            baseUrl: backendUrl,
            authRepo: context.read(),
          ),
        ),
        RepositoryProvider(
          create: (context) => ClientRepository(
            baseUrl: backendUrl,
            authRepo: context.read(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (ctx) => AuthBloc(ctx.read())),
          BlocProvider(
            create: (ctx) => PasswordResetBloc(ctx.read()),
          ),
          BlocProvider(
            create: (ctx) => ProfileBloc(ctx.read()),
          ),
          BlocProvider(
            create: (ctx) => EmployeeBloc(ctx.read()),
          ),
          BlocProvider(
            create: (ctx) => ComptableBloc(ctx.read()),
          ),
          BlocProvider(
            create: (ctx) => ClientBloc(ctx.read()),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}