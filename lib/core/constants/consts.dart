import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String get stripePublishableKey {
  try {
    final key = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
    return (key.length >= 50) ? key : '';
  } catch (e) {
    return '';
  }
}

String get stripeSecretKey {
  try {
    final key = dotenv.env['STRIPE_SECRET_KEY'] ?? '';
    return (key.length >= 50) ? key : '';
  } catch (e) {
    return '';
  }
}

String get stripePublishableKeyLegacy => stripePublishableKey;
String get stripeSecretKeyLegacy => stripeSecretKey;

class BackendUrls {
  static const String localhost = 'http://localhost:8000';
  static const String androidEmulator = 'http://10.0.2.2:8000';
  static const String iosSimulator = 'http://localhost:8000';
  static const String physicalDevice = 'http://192.168.100.8:8000';

  static String get current {
    if (kIsWeb) {
      return localhost;
    }
    return _getPlatformSpecificUrl();
  }

  static String _getPlatformSpecificUrl() {
    try {
      if (Platform.isAndroid) {
        return androidEmulator;
      } else if (Platform.isIOS) {
        return iosSimulator;
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // For desktop platforms including Windows
        return localhost;
      } else {
        return physicalDevice;
      }
    } catch (e) {
      // Fallback in case Platform is not available
      return localhost;
    }
  }

  static String getUrlForPlatform({
    bool isAndroid = false,
    bool isIOS = false,
    bool isWeb = false,
    bool isWindows = false,
  }) {
    if (isWeb) return localhost;
    if (isAndroid) return androidEmulator;
    if (isIOS) return iosSimulator;
    if (isWindows) return localhost;
    return physicalDevice;
  }
}

class ApiEndpoints {
  // Updated to match your Django backend URLs
  static const String processWebPayment = '/api/payments/process_web_payment/';
  static const String processCardPayment = '/api/payments/process_card_payment/';
  static const String confirmPayment = '/api/payments/confirm_payment/';
  
  // Legacy endpoints (kept for backward compatibility)
  static const String createStripePayment = '/api/payments/create_stripe_payment/';
  static const String createStripePaymentCardOnly = '/api/payments/create_stripe_payment_card_only/';
}

class AppConfig {
  static const String merchantDisplayName = "OI Lab";
  static const double minPaymentAmount = 0.50;

  static bool get isWebPlatform => kIsWeb;
  static bool get isMobilePlatform => !kIsWeb;
  static bool get isWindowsPlatform {
    try {
      return !kIsWeb && Platform.isWindows;
    } catch (e) {
      return false;
    }
  }

  static bool get isStripePaymentSheetSupported {
    try {
      return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    } catch (e) {
      return false;
    }
  }
  
  static bool get isStripeElementsSupported => kIsWeb || isWindowsPlatform;
}

bool validateStripeConfiguration() {
  try {
    final pubKey = stripePublishableKey;
    final secretKey = stripeSecretKey;
    return pubKey.isNotEmpty && secretKey.isNotEmpty;
  } catch (_) {
    return false;
  }
}

class EnvironmentHelper {
  static bool get isDevelopment => kDebugMode;
  static bool get isProduction => kReleaseMode;
  static bool get isWeb => kIsWeb;
  static bool get isDesktop {
    try {
      return !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
    } catch (e) {
      return false;
    }
  }
}

class PlatformHelper {
  static bool get isWeb => kIsWeb;
  static bool get isMobile {
    try {
      return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    } catch (e) {
      return false;
    }
  }
  static bool get isDesktop {
    try {
      return !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
    } catch (e) {
      return false;
    }
  }

  static String get platformName {
    if (isWeb) return 'Web';
    try {
      if (Platform.isWindows) return 'Windows';
      if (Platform.isMacOS) return 'macOS';
      if (Platform.isLinux) return 'Linux';
      if (Platform.isAndroid) return 'Android';
      if (Platform.isIOS) return 'iOS';
    } catch (e) {
      // Platform not available
    }
    return 'Unknown';
  }
}