import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:oilab_frontend/firebase_options.dart';
import 'package:oilab_frontend/shared/services/fcm_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:oilab_frontend/app.dart';
import 'package:oilab_frontend/features/auth/data/auth_repository.dart';
import 'package:oilab_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:oilab_frontend/features/auth/presentation/bloc/auth_event.dart';
import 'package:oilab_frontend/features/auth/presentation/bloc/password_reset_bloc.dart';
import 'package:oilab_frontend/features/clients/data/client_repository.dart';
import 'package:oilab_frontend/features/clients/presentation/bloc/client_bloc.dart';
import 'package:oilab_frontend/features/comptables/data/comptable_repository.dart';
import 'package:oilab_frontend/features/comptables/presentation/bloc/comptable_bloc.dart';
import 'package:oilab_frontend/features/employees/data/employee_repository.dart';
import 'package:oilab_frontend/features/employees/presentation/bloc/employee_bloc.dart';
import 'package:oilab_frontend/features/bills/data/bill_repository.dart';
import 'package:oilab_frontend/features/bills/presentation/bloc/bill_bloc.dart';
import 'package:oilab_frontend/features/factures/data/facture_repository.dart';
import 'package:oilab_frontend/features/factures/presentation/bloc/facture_bloc.dart';
import 'package:oilab_frontend/features/parametres/data/profile_repository.dart';
import 'package:oilab_frontend/features/parametres/presentation/bloc/profile_bloc.dart';
import 'package:oilab_frontend/features/produits/data/product_repository.dart';
import 'package:oilab_frontend/features/produits/presentation/bloc/product_bloc.dart';
import 'package:oilab_frontend/features/notifications/data/notification_repository.dart';
import 'package:oilab_frontend/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:oilab_frontend/shared/services/stripe_service.dart';
import 'package:oilab_frontend/core/constants/consts.dart';

bool isStripeAvailable = false;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await _loadEnvironment();

    final String backendUrl = _getBackendUrl();
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

    final authRepository = AuthRepository(
      baseUrl: backendUrl,
      sharedPreferences: sharedPreferences,
    );

    await authRepository.initializeAuth();
    await _initializeStripe(authRepository);

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    runApp(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AuthRepository>.value(value: authRepository),
          RepositoryProvider<ProfileRepository>(
            create:
                (ctx) => ProfileRepository(
                  baseUrl: backendUrl,
                  authRepository: ctx.read<AuthRepository>(),
                ),
          ),
          RepositoryProvider<EmployeeRepository>(
            create:
                (ctx) => EmployeeRepository(
                  baseUrl: backendUrl,
                  authRepo: ctx.read<AuthRepository>(),
                ),
          ),
          RepositoryProvider<BillRepository>(
            create:
                (ctx) => BillRepository(
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
          RepositoryProvider<NotificationRepository>(
            create:
                (ctx) => NotificationRepository(
                  baseUrl: backendUrl,
                  authRepo: ctx.read<AuthRepository>(),
                ),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create:
                  (ctx) =>
                      AuthBloc(ctx.read<AuthRepository>())
                        ..add(AuthInitialized()),
            ),
            BlocProvider<PasswordResetBloc>(
              create: (ctx) => PasswordResetBloc(ctx.read<AuthRepository>()),
            ),
            BlocProvider<ProfileBloc>(
              create:
                  (ctx) => ProfileBloc(
                    ctx.read<ProfileRepository>(),
                    ctx.read<AuthRepository>(),
                  ),
            ),
            BlocProvider<EmployeeBloc>(
              create: (ctx) => EmployeeBloc(ctx.read<EmployeeRepository>()),
            ),
            BlocProvider<BillBloc>(
              create: (ctx) => BillBloc(ctx.read<BillRepository>()),
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
            BlocProvider<NotificationBloc>(
              create:
                  (ctx) => NotificationBloc(ctx.read<NotificationRepository>()),
            ),
          ],
          child: MyAppWithFCM(
            authRepository: authRepository,
            backendUrl: backendUrl,
          ),
        ),
      ),
    );
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Error initializing app',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '$e',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyAppWithFCM extends StatefulWidget {
  final AuthRepository authRepository;
  final String backendUrl;

  const MyAppWithFCM({
    Key? key,
    required this.authRepository,
    required this.backendUrl,
  }) : super(key: key);

  @override
  State<MyAppWithFCM> createState() => _MyAppWithFCMState();
}

class _MyAppWithFCMState extends State<MyAppWithFCM> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFCM();
    });
  }

  Future<void> _initializeFCM() async {
    try {
      final notificationBloc = context.read<NotificationBloc>();

      await FCMService().initialize(
        authRepository: widget.authRepository,
        notificationBloc: notificationBloc,
        baseUrl: widget.backendUrl,
      );

      await FCMService().subscribeToUserTopics();
    } catch (e) {
      // FCM initialization failed
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MyApp();
  }
}

Future<void> _loadEnvironment() async {
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // Environment file not found
  }
}

Future<void> _initializeStripe(AuthRepository authRepository) async {
  try {
    await StripeService.instance.initialize(authRepository: authRepository);
    isStripeAvailable = true;
  } catch (e) {
    isStripeAvailable = false;
  }
}

String _getBackendUrl() {
  return BackendUrls.current;
}
