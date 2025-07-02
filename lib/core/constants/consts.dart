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
  static const String physicalDevice = 'http://192.168.31.146:8000';

  static String get current {
    if (kIsWeb) {
      return localhost;
    }
    return _getPlatformSpecificUrl();
  }

  static String _getPlatformSpecificUrl() {
    // Check if we're on web first to avoid Platform errors
    if (kIsWeb) {
      return localhost;
    }

    try {
      if (Platform.isAndroid) {
        return _isRunningOnEmulator() ? androidEmulator : physicalDevice;
      } else if (Platform.isIOS) {
        return _isRunningOnSimulator() ? iosSimulator : physicalDevice;
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        return localhost;
      } else {
        return physicalDevice;
      }
    } catch (e) {
      // Fallback if Platform is not available (like on web)
      return localhost;
    }
  }

  static bool _isRunningOnEmulator() {
    // Don't check Platform on web
    if (kIsWeb) return false;

    try {
      return false;
    } catch (e) {
      return false;
    }
  }

  static bool _isRunningOnSimulator() {
    // Don't check Platform on web
    if (kIsWeb) return false;

    try {
      return false;
    } catch (e) {
      return false;
    }
  }

  static String getUrlForPlatform({
    bool isAndroid = false,
    bool isIOS = false,
    bool isWeb = false,
    bool isWindows = false,
  }) {
    if (isWeb) return localhost;
    if (isAndroid) return physicalDevice;
    if (isIOS) return physicalDevice;
    if (isWindows) return localhost;
    return physicalDevice;
  }

  static String get manualOverride {
    return current;
  }
}

class ApiEndpoints {
  static const String processWebPayment = '/api/payments/process_web_payment/';
  static const String processCardPayment =
      '/api/payments/process_card_payment/';
  static const String confirmPayment = '/api/payments/confirm_payment/';
  static const String createStripePayment =
      '/api/payments/create_stripe_payment/';
  static const String createStripePaymentCardOnly =
      '/api/payments/create_stripe_payment_card_only/';
}

class AppConfig {
  static const String merchantDisplayName = "OI Lab";
  static const double minPaymentAmount = 0.50;

  static bool get isWebPlatform => kIsWeb;
  static bool get isMobilePlatform => !kIsWeb;
  static bool get isWindowsPlatform {
    if (kIsWeb) return false;
    try {
      return !kIsWeb && Platform.isWindows;
    } catch (e) {
      return false;
    }
  }

  static bool get isStripePaymentSheetSupported {
    if (kIsWeb) return false;
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
    if (kIsWeb) return false;
    try {
      return !kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
    } catch (e) {
      return false;
    }
  }
}

class PlatformHelper {
  static bool get isWeb => kIsWeb;
  static bool get isMobile {
    if (kIsWeb) return false;
    try {
      return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    } catch (e) {
      return false;
    }
  }

  static bool get isDesktop {
    if (kIsWeb) return false;
    try {
      return !kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
    } catch (e) {
      return false;
    }
  }

  static String get platformName {
    if (kIsWeb) return 'Web';
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
