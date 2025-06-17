import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:oilab_frontend/app.dart';
import 'package:oilab_frontend/features/auth/data/auth_repository.dart';
import 'package:oilab_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:oilab_frontend/features/auth/presentation/bloc/password_reset_bloc.dart';
import 'package:oilab_frontend/features/clients/data/client_repository.dart';
import 'package:oilab_frontend/features/clients/presentation/bloc/client_bloc.dart';
import 'package:oilab_frontend/features/comptables/data/comptable_repository.dart';
import 'package:oilab_frontend/features/comptables/presentation/bloc/comptable_bloc.dart';
import 'package:oilab_frontend/features/employees/data/employee_repository.dart';
import 'package:oilab_frontend/features/employees/presentation/bloc/employee_bloc.dart';
import 'package:oilab_frontend/features/factures/data/facture_repository.dart';
import 'package:oilab_frontend/features/factures/presentation/bloc/facture_bloc.dart';
import 'package:oilab_frontend/features/parametres/data/profile_repository.dart';
import 'package:oilab_frontend/features/parametres/presentation/bloc/profile_bloc.dart';
import 'package:oilab_frontend/features/produits/data/product_repository.dart';
import 'package:oilab_frontend/features/produits/presentation/bloc/product_bloc.dart';
import 'package:oilab_frontend/shared/services/stripe_service.dart';
import 'package:oilab_frontend/core/constants/consts.dart';

// Global flag to track Stripe availability
bool isStripeAvailable = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables
    await _loadEnvironment();

    final String backendUrl = _getBackendUrl();
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

    final authRepository = AuthRepository(
      baseUrl: backendUrl,
      sharedPreferences: sharedPreferences,
    );

    // Initialize Stripe service with the properly configured authRepository
    await _initializeStripe(authRepository);

    runApp(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AuthRepository>.value(value: authRepository),
          RepositoryProvider<ProfileRepository>(
            create: (_) => ProfileRepository(baseUrl: backendUrl),
          ),
          RepositoryProvider<EmployeeRepository>(
            create:
                (ctx) => EmployeeRepository(
                  baseUrl: backendUrl,
                  authRepo: ctx.read<AuthRepository>(),
                ),
          ),
          RepositoryProvider<ComptableRepository>(
            create:
                (ctx) => ComptableRepository(
                  baseUrl: backendUrl,
                  authRepo: ctx.read<AuthRepository>(),
                ),
          ),
          RepositoryProvider<ClientRepository>(
            create:
                (ctx) => ClientRepository(
                  baseUrl: backendUrl,
                  authRepo: ctx.read<AuthRepository>(),
                ),
          ),
          RepositoryProvider<ProductRepository>(
            create:
                (ctx) => ProductRepository(
                  baseUrl: backendUrl,
                  authRepo: ctx.read<AuthRepository>(),
                ),
          ),
          RepositoryProvider<FactureRepository>(
            create:
                (ctx) => FactureRepository(
                  baseUrl: backendUrl,
                  authRepo: ctx.read<AuthRepository>(),
                ),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (ctx) => AuthBloc(ctx.read<AuthRepository>()),
            ),
            BlocProvider<PasswordResetBloc>(
              create: (ctx) => PasswordResetBloc(ctx.read<AuthRepository>()),
            ),
            BlocProvider<ProfileBloc>(
              create: (ctx) => ProfileBloc(ctx.read<ProfileRepository>()),
            ),
            BlocProvider<EmployeeBloc>(
              create: (ctx) => EmployeeBloc(ctx.read<EmployeeRepository>()),
            ),
            BlocProvider<ComptableBloc>(
              create: (ctx) => ComptableBloc(ctx.read<ComptableRepository>()),
            ),
            BlocProvider<ClientBloc>(
              create: (ctx) => ClientBloc(ctx.read<ClientRepository>()),
            ),
            BlocProvider<ProductBloc>(
              create: (ctx) => ProductBloc(ctx.read<ProductRepository>()),
            ),
            BlocProvider<FactureBloc>(
              create:
                  (ctx) => FactureBloc(
                    factureRepository: ctx.read<FactureRepository>(),
                  ),
            ),
          ],
          child: const MyApp(),
        ),
      ),
    );
  } catch (e) {
    // Handle any initialization errors
    print('Error during app initialization: $e');
    // You might want to show an error screen or fallback UI here
    runApp(
      MaterialApp(
        home: Scaffold(body: Center(child: Text('Error initializing app: $e'))),
      ),
    );
  }
}

Future<void> _loadEnvironment() async {
  await dotenv.load(fileName: '.env');
}

Future<void> _initializeStripe(AuthRepository authRepository) async {
  try {
    await StripeService.instance.initialize(authRepository: authRepository);
    isStripeAvailable = true;
  } catch (e) {
    print('Failed to initialize Stripe: $e');
    isStripeAvailable = false;
  }
}

String _getBackendUrl() {
  return BackendUrls.current;
}
