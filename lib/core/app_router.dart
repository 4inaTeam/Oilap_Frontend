import 'package:flutter/material.dart';
import 'package:oilab_frontend/features/auth/data/auth_repository.dart';
import 'package:oilab_frontend/features/bills/presentation/screens/bill_detail_screen.dart';
import 'package:oilab_frontend/features/bills/presentation/screens/bill_list_screen.dart';
import 'package:oilab_frontend/features/comptableDashboard/presentation/screens/dashboardAccounatant_screen.dart';
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
import 'package:oilab_frontend/core/models/bill_model.dart';
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

  static String? _getBillImageUrl(Bill bill) {
    if (bill.originalImage != null && bill.originalImage!.isNotEmpty) {
      if (bill.originalImage!.startsWith('http')) {
        return bill.originalImage;
      }
      return 'http://localhost:8000${bill.originalImage}';
    }

    return bill.pdfUrl;
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
        if (isAdmin) {
          return MaterialPageRoute(builder: (_) => const DashboardScreen());
        } else if (isEmployee) {
          // Redirect employees to clients page instead of dashboard
          return MaterialPageRoute(builder: (_) => const ClientListScreen());
        } else if (isAccountant) {
          // Redirect accountants to their specific dashboard
          return MaterialPageRoute(builder: (_) => const AccountantScreen());
        } else if (isClient) {
          // Redirect clients to products page instead of dashboard
          return MaterialPageRoute(builder: (_) => const ProductListScreen());
        }
        break;

      case '/comptableDashboard':
        if (isAccountant) {
          return MaterialPageRoute(builder: (_) => const AccountantScreen());
        }
        break;

      case '/clients':
        if (isAdmin || isEmployee || isAccountant) {
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

      case '/factures/entreprise':
        if (isAdmin || isAccountant || isClient) {
          return MaterialPageRoute(builder: (_) => const BillListScreen());
        }
        break;

      case '/factures/entreprise/detail':
        if (isAdmin || isAccountant || isClient) {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args != null) {
            if (args.containsKey('bill')) {
              final Bill bill = args['bill'] as Bill;
              final String? imageUrl = _getBillImageUrl(bill);

              return MaterialPageRoute(
                builder:
                    (_) => BillDetailScreen(
                      imageUrl: imageUrl,
                      bill: bill,
                      billTitle:
                          args['billTitle'] as String? ??
                          'Facture - ${bill.owner}',
                      billId: args['billId'] as int? ?? bill.id,
                    ),
              );
            } else if (args.containsKey('pdfUrl') ||
                args.containsKey('imageUrl')) {
              final String? imageUrl =
                  args['imageUrl'] as String? ?? args['pdfUrl'] as String?;

              final Bill tempBill = Bill(
                id: args['billId'] as int? ?? 0,
                owner: args['billTitle'] as String? ?? 'Facture',
                amount: 0.0,
                category: '',
                pdfFile: imageUrl ?? '',
                createdAt: DateTime.now(),
                originalImage: imageUrl,
              );

              return MaterialPageRoute(
                builder:
                    (_) => BillDetailScreen(
                      imageUrl: imageUrl,
                      bill: tempBill,
                      billTitle: args['billTitle'] as String?,
                      billId: args['billId'] as int?,
                    ),
              );
            } else {
              return MaterialPageRoute(
                builder:
                    (_) => Scaffold(
                      appBar: AppBar(title: const Text('Erreur')),
                      body: const Center(
                        child: Text(
                          'Arguments invalides pour la facture.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
              );
            }
          }
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
        if (isClient) {
          return MaterialPageRoute(builder: (_) => const NotificationScreen());
        }
        break;

      default:
        break;
    }

    // If no route matches, show access denied
    return MaterialPageRoute(
      builder:
          (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Accès refusé'),
              backgroundColor: Colors.red,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Accès refusé',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Vous n\'avez pas la permission pour cette page.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
