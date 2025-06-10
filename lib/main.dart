import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:oilab_frontend/features/clients/presentation/bloc/client_bloc.dart';
import 'package:oilab_frontend/features/factures/data/facture_repository.dart';
import 'package:oilab_frontend/features/factures/presentation/bloc/facture_bloc.dart';
import 'package:oilab_frontend/features/produits/data/product_repository.dart';
import 'package:oilab_frontend/features/produits/presentation/bloc/product_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

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

  String backendUrl = _getBackendUrl();

  SharedPreferences? sharedPreferences;
  try {
    sharedPreferences = await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint('SharedPreferences error: $e');
  }

  // Initialize AuthRepository and load existing tokens
  final authRepository = AuthRepository(
    baseUrl: backendUrl,
    sharedPreferences: sharedPreferences,
  );
  
  // Initialize auth to load stored tokens and extract role
  try {
    await authRepository.initializeAuth();
    debugPrint('Auth initialized. Current role: ${AuthRepository.currentRole}');
  } catch (e) {
    debugPrint('Auth initialization error: $e');
  }

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(
          value: authRepository,
        ),
        RepositoryProvider(
          create: (_) => ProfileRepository(baseUrl: backendUrl),
        ),
        RepositoryProvider(
          create:
              (context) => EmployeeRepository(
                baseUrl: backendUrl,
                authRepo: context.read(),
              ),
        ),
        RepositoryProvider(
          create:
              (context) => ComptableRepository(
                baseUrl: backendUrl,
                authRepo: context.read(),
              ),
        ),
        RepositoryProvider(
          create:
              (context) => ClientRepository(
                baseUrl: backendUrl,
                authRepo: context.read(),
              ),
        ),
        RepositoryProvider(
          create:
              (context) => ProductRepository(
                baseUrl: backendUrl,
                authRepo: context.read(),
              ),
        ),
        RepositoryProvider(
          create:
              (context) => FactureRepository(
                baseUrl: backendUrl,
                authRepo: context.read(),
              ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (ctx) => AuthBloc(ctx.read())),
          BlocProvider(create: (ctx) => PasswordResetBloc(ctx.read())),
          BlocProvider(create: (ctx) => ProfileBloc(ctx.read())),
          BlocProvider(create: (ctx) => EmployeeBloc(ctx.read())),
          BlocProvider(create: (ctx) => ComptableBloc(ctx.read())),
          BlocProvider(create: (ctx) => ClientBloc(ctx.read())),
          BlocProvider(create: (ctx) => ProductBloc(ctx.read())),
          BlocProvider(create: (ctx) => FactureBloc(factureRepository: ctx.read())),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

String _getBackendUrl() {
  if (kIsWeb) {
    return 'http://localhost:8000';
  } else if (Platform.isAndroid) {
    return 'http://10.0.2.2:8000';
  } else if (Platform.isIOS) {
    return 'http://localhost:8000';
  } else {
    return 'http://192.168.100.8:8000';
  }
}