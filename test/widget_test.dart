import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oilab_frontend/app.dart';
import 'package:oilab_frontend/features/auth/presentation/screens/signin_screen.dart';
import 'package:oilab_frontend/features/splash/presentation/screens/splash_screen.dart'; // Changed from main.dart

void main() {
  testWidgets('Splash screen renders correctly', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MyApp());

    // Verify splash screen elements
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(Image), findsAtLeastNWidgets(2)); // Background and logo
    expect(find.text('OILAPP'), findsOneWidget);
  });

  testWidgets('Navigation to sign-in screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Wait for splash duration
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify navigation to sign-in screen
    expect(find.byType(SignInScreen), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });
}
