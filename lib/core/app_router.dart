import 'package:flutter/material.dart';
import 'package:oilab_frontend/features/auth/data/auth_repository.dart';
import 'package:oilab_frontend/features/bills/presentation/screens/bill_detail_screen.dart';
import 'package:oilab_frontend/features/bills/presentation/screens/bill_list_screen.dart';
import 'package:oilab_frontend/features/bills/presentation/screens/bill_upload_screen.dart';
import 'package:oilab_frontend/features/energie/presentation/screens/energie_list_screen.dart';
import 'package:oilab_frontend/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:oilab_frontend/features/splash/presentation/screens/splash_screen.dart';
import 'package:oilab_frontend/features/auth/presentation/screens/signin_screen.dart';
import 'package:oilab_frontend/features/clients/presentation/screens/client_list_screen.dart';
import 'package:oilab_frontend/features/comptables/presentation/screens/comptable_list_screen.dart';
import 'package:oilab_frontend/features/employees/presentation/screens/employee_list_screen.dart';
import 'package:oilab_frontend/features/produits/presentation/screens/product_list_screen.dart';
import 'package:oilab_frontend/features/factures/presentation/screens/facture_list_screen.dart';
import 'package:oilab_frontend/features/factures/presentation/screens/facture_detail_screen.dart';
import 'package:oilab_frontend/features/parametres/presentation/screens/parametre_screen.dart';
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
    final String? role = AuthRepository.currentRole;

    bool isAdmin = role == 'ADMIN';
    bool isEmployee = role == 'EMPLOYEE';
    bool isAccountant = role == 'ACCOUNTANT';
    bool isClient = role == 'CLIENT';

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case '/signin':
        return MaterialPageRoute(builder: (_) => const SignInScreen());

      case '/dashboard':
        if (isAdmin || isEmployee || isAccountant || isClient) {
          return MaterialPageRoute(builder: (_) => const DashboardScreen());
        }
        break;

      case '/clients':
        if (isAdmin || isEmployee) {
          return MaterialPageRoute(builder: (_) => const ClientListScreen());
        }
        break;

      case '/comptables':
        if (isAdmin) {
          return MaterialPageRoute(builder: (_) => const ComptableListScreen());
        }
        break;

      case '/employees':
        if (isAdmin) {
          return MaterialPageRoute(builder: (_) => const EmployeeListScreen());
        }
        break;

      case '/produits':
        if (isAdmin || isEmployee || isClient) {
          return MaterialPageRoute(builder: (_) => const ProductListScreen());
        }
        break;

      // Facture client routes
      case '/factures/client':
        if (isAdmin || isAccountant || isClient) {
          return MaterialPageRoute(builder: (_) => const FactureListScreen());
        }
        break;

      case '/factures/client/detail':
        if (isAdmin || isAccountant || isClient) {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args != null &&
              args.containsKey('factureId') &&
              args.containsKey('facture')) {
            return MaterialPageRoute(
              builder:
                  (_) => FactureDetailScreen(
                    factureId: args['factureId'] as int,
                    facture: args['facture'] as Facture,
                  ),
            );
          }
        }
        break;

      case '/factures/client/upload':
        if (isAdmin || isAccountant || isClient) {
          return MaterialPageRoute(builder: (_) => FactureUploadScreen());
        }
        break;

      // Facture entreprise routes
      case '/factures/entreprise':
        if (isAdmin || isAccountant || isClient) {
          return MaterialPageRoute(builder: (_) => const BillListScreen());
        }
        break;

      case '/factures/entreprise/detail':
        if (isAdmin || isAccountant || isClient) {
          return MaterialPageRoute(builder: (_) => BillDetailScreen());
        }
        break;

      case '/factures/entreprise/upload':
        if (isAdmin || isAccountant || isClient) {
          return MaterialPageRoute(builder: (_) => FactureUploadScreen());
        }
        break;

      case '/parametres':
        if (isAdmin || isEmployee || isAccountant || isClient) {
          return MaterialPageRoute(builder: (_) => const ParametresScreen());
        }
        break;

      case '/energie':
        if (isAdmin) {
          return MaterialPageRoute(builder: (_) => const EnergieScrren());
        }
        break;

      case '/notifications':
        if (isAdmin || isClient) {
          return MaterialPageRoute(builder: (_) => const NotificationScreen());
        }
        break;

      default:
        break;
    }

    // Return access denied page if no route matched or user doesn't have permission
    return MaterialPageRoute(
      builder:
          (_) => const Scaffold(
            body: Center(
              child: Text(
                'Accès refusé. Vous n\'avez pas la permission pour cette page.',
              ),
            ),
          ),
    );
  }
}
