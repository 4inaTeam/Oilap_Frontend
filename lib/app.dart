import 'package:flutter/material.dart';
import 'package:oilab_frontend/features/splash/presentation/screens/splash_screen.dart';
import 'core/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'BAHNSCHRIFT',
        primaryColor: const Color(0xFF3A5B22),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
