import 'package:flutter/material.dart';
import 'package:oilab_frontend/features/auth/data/auth_repository.dart';
import 'package:oilab_frontend/features/energie/presentation/screens/energie_list_screen.dart';
import 'package:oilab_frontend/features/splash/presentation/screens/splash_screen.dart';
import 'package:oilab_frontend/features/auth/presentation/screens/signin_screen.dart';
import 'package:oilab_frontend/features/clients/presentation/screens/client_list_screen.dart';
import 'package:oilab_frontend/features/comptables/presentation/screens/comptable_list_screen.dart';
import 'package:oilab_frontend/features/employees/presentation/screens/employee_list_screen.dart';
import 'package:oilab_frontend/features/produits/presentation/screens/product_list_screen.dart';
import 'package:oilab_frontend/features/factures/presentation/screens/facture_list_screen.dart';
import 'package:oilab_frontend/features/factures/presentation/screens/facture_detail_screen.dart';
import 'package:oilab_frontend/features/parametres/presentation/screens/parametre_screen.dart';
import 'package:oilab_frontend/features/factures/presentation/screens/facture_upload_screen.dart';
import 'package:oilab_frontend/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:oilab_frontend/core/models/facture_model.dart';
import 'dart:convert';

class AppRouter {
  static String? getRoleFromToken(String? token) {
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final payloadMap = json.decode(payload);
      return payloadMap['role'] as String?;
    } catch (_) {
      return null;
    }
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Use the static variables from AuthRepository
    final String? role = AuthRepository.currentRole;

    bool isAdmin = role == 'ADMIN';
    bool isEmployee = role == 'EMPLOYEE';
    bool isAccountant = role == 'ACCOUNTANT';
    bool isClient = role == 'CLIENT';

    // ADMIN has access to all routes
    if (isAdmin) {
      switch (settings.name) {
        case '/':
          return MaterialPageRoute(builder: (_) => const SplashScreen());
        case '/signin':
          return MaterialPageRoute(builder: (_) => const SignInScreen());
        case '/dashboard':
          return MaterialPageRoute(builder: (_) => const DashboardScreen());
        case '/clients':
          return MaterialPageRoute(builder: (_) => const ClientListScreen());
        case '/comptables':
          return MaterialPageRoute(builder: (_) => const ComptableListScreen());
        case '/employees':
          return MaterialPageRoute(builder: (_) => const EmployeeListScreen());
        case '/produits':
          return MaterialPageRoute(builder: (_) => const ProductListScreen());
        case '/factures':
          return MaterialPageRoute(builder: (_) => const FactureListScreen());
        case '/factures/detail':
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => FactureDetailScreen(
              factureId: args['factureId'] as int,
              facture: args['facture'] as Facture,
            ),
          );
        case '/factures/upload':
          return MaterialPageRoute(builder: (_) => FactureUploadScreen());
        case '/parametres':
          return MaterialPageRoute(builder: (_) => const ParametresScreen());
        case '/energie':
          return MaterialPageRoute(builder: (_) => const EnergieScrren());
        default:
          break;
      }
    } else {
      switch (settings.name) {
        case '/':
          return MaterialPageRoute(builder: (_) => const SplashScreen());
        case '/signin':
          return MaterialPageRoute(builder: (_) => const SignInScreen());
        case '/dashboard':
          if (isEmployee || isAccountant || isClient) {
            return MaterialPageRoute(builder: (_) => const DashboardScreen());
          }
          break;
        case '/clients':
          if (isEmployee) {
            return MaterialPageRoute(builder: (_) => const ClientListScreen());
          }
          break;
        case '/comptables':
          break;
        case '/employees':
          break;
        case '/produits':
          if (isEmployee || isClient) {
            return MaterialPageRoute(builder: (_) => const ProductListScreen());
          }
          break;
        case '/factures':
          if (isAccountant) {
            return MaterialPageRoute(builder: (_) => const FactureListScreen());
          }
          break;
        case '/factures/detail':
          if (isAccountant) {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => FactureDetailScreen(
                factureId: args['factureId'] as int,
                facture: args['facture'] as Facture,
              ),
            );
          }
          break;
        case '/factures/upload':
          if (isAccountant) {
            return MaterialPageRoute(builder: (_) => FactureUploadScreen());
          }
          break;
        case '/parametres':
          if (isEmployee || isAccountant || isClient) {
            return MaterialPageRoute(builder: (_) => const ParametresScreen());
          }
          break;
        case '/energie':
          break;
        default:
          break;
      }
    }
    
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text(
            'Accès refusé. Vous n\'avez pas la permission pour cette page.',
          ),
        ),
      ),
    );
  }

}