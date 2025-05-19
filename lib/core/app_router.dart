import 'package:flutter/material.dart';
import 'package:oilab_frontend/features/splash/presentation/screens/splash_screen.dart';
import 'package:oilab_frontend/features/auth/presentation/screens/signin_screen.dart';
import 'package:oilab_frontend/features/clients/presentation/screens/client_list_screen.dart';
import 'package:oilab_frontend/features/comptables/presentation/screens/comptable_list_screen.dart';
import 'package:oilab_frontend/features/employees/presentation/screens/employee_list_screen.dart';
import 'package:oilab_frontend/features/clients/presentation/screens/client_profile_screen.dart';
import 'package:oilab_frontend/features/produits/presentation/screens/product_list_screen.dart';
import 'package:oilab_frontend/features/produits/presentation/screens/product_detail_screen.dart';
import 'package:oilab_frontend/features/factures/presentation/screens/facture_list_screen.dart';
import 'package:oilab_frontend/features/factures/presentation/screens/facture_detail_screen.dart';
import 'package:oilab_frontend/features/parametres/presentation/screens/parametre_screen.dart';
import 'package:oilab_frontend/features/factures/presentation/screens/facture_upload_screen.dart';
import 'package:oilab_frontend/features/dashboard/presentation/screens/dashboard_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Splash & Auth
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/signin':
        return MaterialPageRoute(builder: (_) => const SignInScreen());

      // Dashboard (root)
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      // Clients
      case '/clients':
        return MaterialPageRoute(builder: (_) => const ClientListScreen());
      case '/clients/profile':
        return MaterialPageRoute(builder: (_) => const ClientProfileScreen());

      // Comptables
      case '/comptables':
        return MaterialPageRoute(builder: (_) => const ComptableListScreen());

      // Employees
      case '/employees':
        return MaterialPageRoute(builder: (_) => const EmployeeListScreen());

      // Produits
      case '/produits':
        return MaterialPageRoute(builder: (_) => const ProductListScreen());
      case '/produits/detail':
        return MaterialPageRoute(builder: (_) => const ProductDetailScreen());

      // Factures
      case '/factures':
        return MaterialPageRoute(builder: (_) => const FactureListScreen());
      case '/factures/detail':
        return MaterialPageRoute(builder: (_) => const FactureDetailScreen());
      case '/factures/upload':
        return MaterialPageRoute(builder: (_) => FactureUploadScreen());

      // Paramètres
      case '/parametres':
        return MaterialPageRoute(builder: (_) => const ParametresScreen());

      // TODO: add more routes here

      default:
        throw Exception('Route not found: ${settings.name}');
    }
  }
}
