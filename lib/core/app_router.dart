import 'package:flutter/material.dart';
import 'package:oilab_frontend/features/auth/data/auth_repository.dart';
import 'package:oilab_frontend/features/bills/presentation/screens/bill_detail_screen.dart';
import 'package:oilab_frontend/features/bills/presentation/screens/bill_list_screen.dart';
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

  // Helper method to get image URL from Bill
  static String? _getBillImageUrl(Bill bill) {
    // Check if bill has originalImage
    if (bill.originalImage != null && bill.originalImage!.isNotEmpty) {
      // If the URL is already absolute, return it
      if (bill.originalImage!.startsWith('http')) {
        return bill.originalImage;
      }
      // If it's relative, make it absolute (assuming your base URL)
      return 'http://localhost:8000${bill.originalImage}';
    }

    // Fallback to pdfUrl if available
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

      // Bill/Enterprise facture routes
      case '/factures/entreprise':
        if (isAdmin || isAccountant || isClient) {
          return MaterialPageRoute(builder: (_) => const BillListScreen());
        }
        break;

      case '/factures/entreprise/detail':
        if (isAdmin || isAccountant || isClient) {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args != null) {
            // Check if we have the bill object (preferred method)
            if (args.containsKey('bill')) {
              final Bill bill = args['bill'] as Bill;
              final String? imageUrl = _getBillImageUrl(bill);

              // Always navigate to BillDetailScreen, even if no image URL
              // The screen will handle the case of missing image gracefully
              return MaterialPageRoute(
                builder:
                    (_) => BillDetailScreen(
                      imageUrl: imageUrl, // Can be null, screen handles it
                      bill: bill,
                      billTitle:
                          args['billTitle'] as String? ??
                          'Facture - ${bill.owner}',
                      billId: args['billId'] as int? ?? bill.id,
                    ),
              );
            }
            // Fallback: if only imageUrl/pdfUrl is provided, create a minimal Bill object
            else if (args.containsKey('pdfUrl') ||
                args.containsKey('imageUrl')) {
              final String? imageUrl =
                  args['imageUrl'] as String? ?? args['pdfUrl'] as String?;

              // Create a minimal bill object with available data
              final Bill tempBill = Bill(
                id: args['billId'] as int? ?? 0,
                owner: args['billTitle'] as String? ?? 'Facture',
                amount: 0.0, // Required field
                category: '', // Required field
                pdfFile:
                    imageUrl ?? '', // This will be used by the pdfUrl getter
                createdAt: DateTime.now(),
                // Add originalImage if it's an image URL
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
              // If no valid arguments, show error
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

      case '/notifications':
        if (isClient) {
          return MaterialPageRoute(builder: (_) => const NotificationScreen());
        }
        break;

      default:
        break;
    }

    // Return access denied page for unauthorized access or invalid routes
    return MaterialPageRoute(
      builder:
          (_) => const Scaffold(
            body: Center(
              child: Text(
                'Accès refusé. Vous n\'avez pas la permission pour cette page.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
    );
  }
}
