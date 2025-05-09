import 'package:flutter/material.dart';
import 'core/app_router.dart';
import 'features/auth/presentation/screens/signin_screen.dart';

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
      home: const SignInScreen(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
