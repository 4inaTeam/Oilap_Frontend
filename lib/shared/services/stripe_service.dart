import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:oilab_frontend/core/constants/consts.dart';
import 'package:oilab_frontend/features/auth/data/auth_repository.dart';

class StripeService {
  StripeService._();

  static final StripeService instance = StripeService._();

  late final Dio _dio;
  late final AuthRepository _authRepository;
  bool _isInitialized = false;

  Future<void> initialize({required AuthRepository authRepository}) async {
    try {
      // Store the AuthRepository instance
      _authRepository = authRepository;

      if (kIsWeb || PlatformHelper.isDesktop) {
        print('Initializing Stripe for Web/Desktop platform');
        await _initializeForWebDesktop();
      } else {
        print('Initializing Stripe for Mobile platform');
        await _initializeForMobile();
      }

      // Configure Dio with base URL and auth interceptor
      _dio = Dio(
          BaseOptions(
            baseUrl: BackendUrls.current,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 30),
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              try {
                // Get token from AuthRepository
                String? token = await _authRepository.getAccessToken();

                if (token != null && token.isNotEmpty) {
                  options.headers['Authorization'] = 'Bearer $token';
                  print(
                    'Added auth token to request: ${token.substring(0, 20)}...',
                  );
                } else {
                  print('⚠️ No auth token available for API request');
                }

                options.headers['Content-Type'] = 'application/json';
              } catch (e) {
                debugPrint('Auth token error: $e');
              }
              return handler.next(options);
            },
            onError: (error, handler) async {
              debugPrint('API Error: ${error.response?.data ?? error.message}');

              // Handle 401 Unauthorized - try to refresh token
              if (error.response?.statusCode == 401) {
                try {
                  print('🔄 Attempting token refresh due to 401 error');
                  final newToken = await _authRepository.refreshAccessToken();

                  if (newToken != null) {
                    print('✅ Token refreshed successfully, retrying request');
                    // Retry the original request with new token
                    final opts = error.requestOptions;
                    opts.headers['Authorization'] = 'Bearer $newToken';

                    final cloneReq = await _dio.fetch(opts);
                    return handler.resolve(cloneReq);
                  }

                  print('❌ Token refresh failed');
                } catch (refreshError) {
                  print('❌ Token refresh error: $refreshError');
                }
              }

              return handler.next(error);
            },
          ),
        );

      _isInitialized = true;
      print(
        '✅ Stripe initialized successfully for ${PlatformHelper.platformName}',
      );
    } catch (e) {
      print('❌ Failed to initialize Stripe: $e');
      _isInitialized = false;
    }
  }

  Future<void> _initializeForWebDesktop() async {
    if (stripePublishableKey.isEmpty ||
        stripePublishableKey == 'pk_test_your_stripe_publishable_key_here') {
      throw Exception('Stripe publishable key not configured');
    }

    // For web and desktop, we'll handle payments through our backend API
    print('Web/Desktop Stripe initialization: Ready for payment processing');
  }

  Future<void> _initializeForMobile() async {
    if (stripePublishableKey.isEmpty ||
        stripePublishableKey == 'pk_test_your_stripe_publishable_key_here') {
      throw Exception('Stripe publishable key not configured');
    }

    try {
      // Configure Stripe publishable key for mobile
      Stripe.publishableKey = stripePublishableKey;
      await Stripe.instance.applySettings();
      print('Mobile Stripe initialization: Payment sheet available');
    } catch (e) {
      print('Warning: Stripe native SDK not available on this platform: $e');
      // Continue without native Stripe SDK - we'll use web-based payment
    }
  }

  bool get isInitialized => _isInitialized;
  bool get isWeb => kIsWeb;
  bool get isStripeNativeSupported =>
      !kIsWeb && !PlatformHelper.isDesktop && _isInitialized;

  Future<bool> makePayment({
    required int factureId,
    required BuildContext context,
  }) async {
    if (!_isInitialized) {
      _showError(context, 'Payment service not initialized');
      return false;
    }

    // Debug: Check if we have a valid token before making payment
    try {
      final token = await _authRepository.getAccessToken();
      if (token == null || token.isEmpty) {
        _showError(context, 'Authentication required. Please login again.');
        return false;
      }
      print('🔐 Making payment with token: ${token.substring(0, 20)}...');
    } catch (e) {
      print('❌ Token check failed: $e');
      _showError(context, 'Authentication error. Please login again.');
      return false;
    }

    try {
      // For Windows desktop and web, use web-based payment
      if (kIsWeb || PlatformHelper.isDesktop) {
        return await _makeWebPayment(factureId, context);
      } else {
        // For mobile platforms, try native first, fallback to web
        try {
          return await _makeMobilePayment(factureId, context);
        } catch (e) {
          print('Native payment failed, falling back to web payment: $e');
          return await _makeWebPayment(factureId, context);
        }
      }
    } catch (e) {
      _showError(context, 'Payment failed: ${e.toString()}');
      return false;
    }
  }

  Future<bool> _makeMobilePayment(int factureId, BuildContext context) async {
    try {
      print('🚀 Starting mobile payment for facture ID: $factureId');

      // 1) Create PaymentIntent using process_web_payment endpoint
      final resp = await _dio.post(
        '/api/payments/process_web_payment/',
        data: {'facture_id': factureId},
      );

      print('📡 Process web payment response status: ${resp.statusCode}');
      print('📡 Process web payment response data: ${resp.data}');

      if (resp.statusCode != 201) {
        _showError(context, 'Create PaymentIntent failed: ${resp.data}');
        return false;
      }

      final data = resp.data as Map<String, dynamic>;
      final clientSecret = data['client_secret'] as String?;
      final paymentId = data['id'] as String?;

      if (clientSecret == null || paymentId == null) {
        _showError(context, 'Invalid response from server');
        return false;
      }

      // 2) Present Stripe PaymentSheet to user
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: AppConfig.merchantDisplayName,
          style: ThemeMode.system,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF4CAF50),
              background: Colors.white,
              componentBackground: Colors.white,
            ),
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // 3) Confirm payment through backend
      final confirmResp = await _dio.post(
        '/api/payments/confirm_payment/',
        data: {'payment_id': paymentId},
      );

      print('📡 Confirm payment response status: ${confirmResp.statusCode}');
      print('📡 Confirm payment response data: ${confirmResp.data}');

      if (confirmResp.statusCode == 201) {
        final confirmData = confirmResp.data;
        if (confirmData['status'] == 'completed' ||
            confirmData['status'] == 'succeeded') {
          _showSuccess(context, 'Payment successful!');
          return true;
        }
      }

      _showError(context, 'Payment confirmation failed');
      return false;
    } on StripeException catch (e) {
      _handleStripeError(context, e);
      return false;
    } on DioException catch (e) {
      print(
        '❌ Mobile payment DioException: ${e.response?.statusCode} - ${e.response?.data}',
      );
      _showError(context, 'Network error: ${e.response?.data ?? e.message}');
      return false;
    } catch (e) {
      print('❌ Mobile payment unexpected error: $e');
      _showError(context, 'Unexpected error: $e');
      return false;
    }
  }

  Future<bool> _makeWebPayment(int factureId, BuildContext context) async {
    try {
      print('🌐 Starting web/desktop payment for facture ID: $factureId');

      // For web and desktop, collect card details and process through backend
      final paymentConfirmed = await _showWebPaymentDialog(context, factureId);

      return paymentConfirmed;
    } catch (e) {
      print('Web/desktop payment error: $e');
      _showError(context, 'Payment failed: ${e.toString()}');
      return false;
    }
  }

  Future<bool> _showWebPaymentDialog(
    BuildContext context,
    int factureId,
  ) async {
    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvcController = TextEditingController();
    final cardHolderController = TextEditingController();

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.payment, color: Colors.green[600]),
                  const SizedBox(width: 8),
                  const Text('Enter Payment Details'),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: cardHolderController,
                      decoration: InputDecoration(
                        labelText: 'Cardholder Name',
                        hintText: 'John Doe',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: cardNumberController,
                      decoration: InputDecoration(
                        labelText: 'Card Number',
                        hintText: '4242 4242 4242 4242',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.credit_card),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        // Format card number with spaces
                        final text = value.replaceAll(' ', '');
                        if (text.length <= 16) {
                          final buffer = StringBuffer();
                          for (int i = 0; i < text.length; i++) {
                            if (i > 0 && i % 4 == 0) buffer.write(' ');
                            buffer.write(text[i]);
                          }
                          final formatted = buffer.toString();
                          if (formatted != value) {
                            cardNumberController.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(
                                offset: formatted.length,
                              ),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: expiryController,
                            decoration: InputDecoration(
                              labelText: 'Expiry Date',
                              hintText: 'MM/YY',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.calendar_month),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              // Format expiry date
                              final text = value.replaceAll('/', '');
                              if (text.length <= 4) {
                                String formatted = text;
                                if (text.length >= 2) {
                                  formatted =
                                      '${text.substring(0, 2)}/${text.substring(2)}';
                                }
                                if (formatted != value) {
                                  expiryController.value = TextEditingValue(
                                    text: formatted,
                                    selection: TextSelection.collapsed(
                                      offset: formatted.length,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: cvcController,
                            decoration: InputDecoration(
                              labelText: 'CVC',
                              hintText: '123',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.security),
                              filled: true,
                              fillColor: Colors.grey[50],
                              counterText: '',
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            obscureText: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lock, size: 16, color: Colors.green),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your payment information is secure and encrypted.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _disposeControllers([
                      cardNumberController,
                      expiryController,
                      cvcController,
                      cardHolderController,
                    ]);
                    Navigator.of(dialogContext).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () async {
                    // Validate input
                    final validationError = _validatePaymentInput(
                      cardHolderController.text,
                      cardNumberController.text,
                      expiryController.text,
                      cvcController.text,
                    );

                    if (validationError != null) {
                      _showError(context, validationError);
                      return;
                    }

                    try {
                      // Show loading
                      showDialog(
                        context: dialogContext,
                        barrierDismissible: false,
                        builder:
                            (context) => const AlertDialog(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text('Processing payment...'),
                                ],
                              ),
                            ),
                      );

                      // Process payment through backend
                      final success = await _processWebPayment(
                        factureId,
                        cardHolderController.text,
                        cardNumberController.text.replaceAll(' ', ''),
                        expiryController.text,
                        cvcController.text,
                      );

                      Navigator.of(dialogContext).pop(); // Close loading

                      if (success) {
                        _disposeControllers([
                          cardNumberController,
                          expiryController,
                          cvcController,
                          cardHolderController,
                        ]);
                        _showSuccess(context, 'Payment successful!');
                        Navigator.of(dialogContext).pop(true);
                      } else {
                        _showError(context, 'Payment processing failed');
                      }
                    } catch (e) {
                      Navigator.of(dialogContext).pop(); // Close loading
                      _showError(context, 'Payment failed: ${e.toString()}');
                    }
                  },
                  child: const Text('Pay Now'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<bool> _processWebPayment(
    int factureId,
    String cardHolder,
    String cardNumber,
    String expiry,
    String cvc,
  ) async {
    try {
      print(
        '🚀 Starting web/desktop payment processing for facture ID: $factureId',
      );

      // Step 1: Create PaymentIntent using process_web_payment endpoint (same as mobile)
      final createResponse = await _dio.post(
        '/api/payments/process_web_payment/',
        data: {'facture_id': factureId},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      print(
        '📡 Web payment create response status: ${createResponse.statusCode}',
      );
      print('📡 Web payment create response data: ${createResponse.data}');

      if (createResponse.statusCode != 201) {
        print('Failed to create payment intent: ${createResponse.data}');
        return false;
      }

      final paymentData = createResponse.data as Map<String, dynamic>;
      final paymentId = paymentData['id'] as String?;
      final clientSecret = paymentData['client_secret'] as String?;
      final paymentIntentId = paymentData['payment_intent_id'] as String?;

      if (paymentId == null ||
          clientSecret == null ||
          paymentIntentId == null) {
        print('Missing payment data from server response');
        return false;
      }

      // Step 2: For web/desktop, create a payment method with the card details
      // and then confirm the payment intent
      final success = await _confirmWebPaymentWithCard(
        paymentIntentId,
        clientSecret,
        paymentId,
        cardHolder,
        cardNumber,
        expiry,
        cvc,
      );

      return success;
    } on DioException catch (e) {
      print(
        '❌ Error processing web payment: ${e.response?.statusCode} - ${e.response?.data ?? e.message}',
      );
      return false;
    } catch (e) {
      print('❌ Unexpected error in web payment: $e');
      return false;
    }
  }

  Future<bool> _confirmWebPaymentWithCard(
    String paymentIntentId,
    String clientSecret,
    String paymentId,
    String cardHolder,
    String cardNumber,
    String expiry,
    String cvc,
  ) async {
    try {
      // For web/desktop, we'll use the confirm_payment endpoint directly
      // The backend will handle the payment method creation and confirmation
      final confirmResponse = await _dio.post(
        '/api/payments/confirm_payment/',
        data: {
          'payment_id': paymentId,
          'client_secret': clientSecret,
          'payment_intent_id': paymentIntentId,
          // Add card details for backend processing
          'card_number': cardNumber,
          'exp_month': int.parse(expiry.split('/')[0]),
          'exp_year': int.parse('20${expiry.split('/')[1]}'),
          'cvc': cvc,
          'cardholder_name': cardHolder,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      print(
        '📡 Web payment confirm response status: ${confirmResponse.statusCode}',
      );
      print('📡 Web payment confirm response data: ${confirmResponse.data}');

      if (confirmResponse.statusCode == 201) {
        final confirmData = confirmResponse.data;
        return confirmData['status'] == 'completed' ||
            confirmData['status'] == 'succeeded';
      }

      return false;
    } catch (e) {
      print('❌ Error confirming web payment: $e');
      return false;
    }
  }

  String? _validatePaymentInput(
    String cardHolder,
    String cardNumber,
    String expiry,
    String cvc,
  ) {
    if (cardHolder.trim().isEmpty) {
      return 'Please enter cardholder name';
    }

    final cleanCardNumber = cardNumber.replaceAll(' ', '');
    if (cleanCardNumber.length != 16) {
      return 'Please enter a valid 16-digit card number';
    }

    if (!RegExp(r'^\d{16}$').hasMatch(cleanCardNumber)) {
      return 'Card number must contain only digits';
    }

    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiry)) {
      return 'Please enter expiry date in MM/YY format';
    }

    final parts = expiry.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);

    if (month == null || month < 1 || month > 12) {
      return 'Please enter a valid month (01-12)';
    }

    final currentYear = DateTime.now().year % 100;
    final currentMonth = DateTime.now().month;

    if (year == null ||
        year < currentYear ||
        (year == currentYear && month < currentMonth)) {
      return 'Card has expired';
    }

    if (cvc.length < 3 || cvc.length > 4) {
      return 'Please enter a valid CVC (3-4 digits)';
    }

    if (!RegExp(r'^\d{3,4}$').hasMatch(cvc)) {
      return 'CVC must contain only digits';
    }

    return null;
  }

  void _disposeControllers(List<TextEditingController> controllers) {
    for (final controller in controllers) {
      controller.dispose();
    }
  }

  void _handleStripeError(BuildContext context, StripeException e) {
    final code = e.error.code;
    String message;
    if (code == FailureCode.Canceled) {
      message = 'Payment cancelled';
    } else if (code == FailureCode.Failed) {
      message = 'Payment failed';
    } else if (code == FailureCode.Timeout) {
      message = 'Payment timed out';
    } else {
      message = e.error.localizedMessage ?? e.error.message ?? 'Stripe error';
    }
    _showError(context, message);
  }

  void _showError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red[600],
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccess(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green[600],
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  bool get isPaymentSupported => _isInitialized;
}
