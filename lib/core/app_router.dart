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
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/signin':
        return MaterialPageRoute(builder: (_) => const SignInScreen());

      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      case '/clients':
        return MaterialPageRoute(builder: (_) => const ClientListScreen());
      case '/clients/profile':
        return MaterialPageRoute(builder: (_) => const ClientProfileScreen());

      case '/comptables':
        return MaterialPageRoute(builder: (_) => const ComptableListScreen());

      case '/employees':
        return MaterialPageRoute(builder: (_) => const EmployeeListScreen());

      case '/produits':
        return MaterialPageRoute(builder: (_) => const ProductListScreen());
      case '/produits/detail':
        return MaterialPageRoute(builder: (_) => const ProductDetailScreen());

      case '/factures':
        return MaterialPageRoute(builder: (_) => const FactureListScreen());
      case '/factures/detail':
        return MaterialPageRoute(builder: (_) => const FactureDetailScreen());
      case '/factures/upload':
        return MaterialPageRoute(builder: (_) => FactureUploadScreen());

      case '/parametres':
        return MaterialPageRoute(builder: (_) => const ParametresScreen());

      default:
        throw Exception('Route not found: ${settings.name}');
    }
  }
}
