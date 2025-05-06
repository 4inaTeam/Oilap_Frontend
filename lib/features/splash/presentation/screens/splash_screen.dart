import 'dart:async';
import 'package:flutter/material.dart';
import '../../../auth/presentation/screens/signin_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/footer_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Timer(const Duration(seconds: 2), () {
      _controller.forward().then((_) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    const SignInScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _opacityAnimation,
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset('assets/images/back.png', fit: BoxFit.cover),
            ),

            // Logo & Title
            Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool isDesktop = constraints.maxWidth > 600;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/splash_logo.png',
                        width: isDesktop ? 300.0 : 150.0,
                        height: isDesktop ? 300.0 : 150.0,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "OILAPP",
                        style: TextStyle(
                          fontSize: isDesktop ? 40.0 : 24.0,
                          fontWeight: FontWeight.normal,
                          color: AppColors.mainColor,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Footer
            Positioned(
              bottom: 20,
              left: 50,
              right: 0,
              child: const FooterWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
