import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:oilab_frontend/core/constants/consts.dart';
import 'package:oilab_frontend/features/auth/data/auth_repository.dart';
import 'package:oilab_frontend/shared/dialogs/error_dialog.dart';

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
        await _initializeForWebDesktop();
      } else {
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
                } else {
                  debugPrint('⚠️ No auth token available for API request');
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
                  final newToken = await _authRepository.refreshAccessToken();

                  if (newToken != null) {
                    // Retry the original request with new token
                    final opts = error.requestOptions;
                    opts.headers['Authorization'] = 'Bearer $newToken';

                    final cloneReq = await _dio.fetch(opts);
                    return handler.resolve(cloneReq);
                  }
                } catch (refreshError) {
                  debugPrint('❌ Token refresh error: $refreshError');
                }
              }

              return handler.next(error);
            },
          ),
        );

      _isInitialized = true;
    } catch (e) {
      debugPrint('❌ Failed to initialize Stripe: $e');
      _isInitialized = false;
    }
  }

  Future<void> _initializeForWebDesktop() async {
    if (stripePublishableKey.isEmpty ||
        stripePublishableKey == 'pk_test_your_stripe_publishable_key_here') {
      throw Exception('Stripe publishable key not configured');
    }

    // For web and desktop, we'll handle payments through our backend API
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
    } catch (e) {
      debugPrint(
        'Warning: Stripe native SDK not available on this platform: $e',
      );
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
      await showCustomErrorDialog(
        context,
        message: 'Le service de paiement n\'est pas initialisé',
        showRetry: false,
      );
      return false;
    }

    // Debug: Check if we have a valid token before making payment
    try {
      final token = await _authRepository.getAccessToken();
      if (token == null || token.isEmpty) {
        await showCustomErrorDialog(
          context,
          message: 'Authentification requise. Veuillez vous reconnecter.',
          showRetry: false,
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ Token check failed: $e');
      await showCustomErrorDialog(
        context,
        message: 'Erreur d\'authentification. Veuillez vous reconnecter.',
        showRetry: false,
      );
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
          debugPrint('Native payment failed, falling back to web payment: $e');
          return await _makeWebPayment(factureId, context);
        }
      }
    } catch (e) {
      await showCustomErrorDialog(
        context,
        message: 'Échec du paiement: ${e.toString()}',
        showRetry: false,
      );
      return false;
    }
  }

  Future<bool> _makeMobilePayment(int factureId, BuildContext context) async {
    try {
      // 1) Create PaymentIntent using process_web_payment endpoint
      final resp = await _dio.post(
        '/api/payments/process_web_payment/',
        data: {'facture_id': factureId},
      );

      if (resp.statusCode != 201) {
        await showCustomErrorDialog(
          context,
          message:
              'Échec de la création de l\'intention de paiement: ${resp.data}',
          showRetry: false,
        );
        return false;
      }

      final data = resp.data as Map<String, dynamic>;
      final clientSecret = data['client_secret'] as String?;
      final paymentId = data['id'] as String?;

      if (clientSecret == null || paymentId == null) {
        await showCustomErrorDialog(
          context,
          message: 'Réponse invalide du serveur',
          showRetry: false,
        );
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

      if (confirmResp.statusCode == 201) {
        final confirmData = confirmResp.data;
        if (confirmData['status'] == 'completed' ||
            confirmData['status'] == 'succeeded') {
          // Payment successful - let the calling screen handle success message
          return true;
        }
      }

      await showCustomErrorDialog(
        context,
        message: 'Échec de la confirmation du paiement',
        showRetry: false,
      );
      return false;
    } on StripeException catch (e) {
      await _handleStripeError(context, e);
      return false;
    } on DioException catch (e) {
      debugPrint(
        '❌ Mobile payment DioException: ${e.response?.statusCode} - ${e.response?.data}',
      );
      await showNetworkError(context);
      return false;
    } catch (e) {
      debugPrint('❌ Mobile payment unexpected error: $e');
      await showCustomErrorDialog(
        context,
        message: 'Erreur inattendue: $e',
        showRetry: false,
      );
      return false;
    }
  }

  Future<bool> _makeWebPayment(int factureId, BuildContext context) async {
    try {
      // For web and desktop, collect card details and process through backend
      final paymentConfirmed = await _showWebPaymentDialog(context, factureId);

      return paymentConfirmed;
    } catch (e) {
      debugPrint('Web/desktop payment error: $e');
      await showCustomErrorDialog(
        context,
        message: 'Échec du paiement: ${e.toString()}',
        showRetry: false,
      );
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
                  const Text('Saisir les détails de paiement'),
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
                        labelText: 'Nom du titulaire',
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
                        labelText: 'Numéro de carte',
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
                              labelText: 'Date d\'expiration',
                              hintText: 'MM/AA',
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
                              'Vos informations de paiement sont sécurisées et cryptées.',
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
                  child: const Text('Annuler'),
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
                      await showValidationError(context, validationError);
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
                                  Text('Traitement du paiement...'),
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
                        // Payment successful - let the calling screen handle success message
                        Navigator.of(dialogContext).pop(true);
                      } else {
                        await showCustomErrorDialog(
                          context,
                          message: 'Échec du traitement du paiement',
                          showRetry: false,
                        );
                      }
                    } catch (e) {
                      Navigator.of(dialogContext).pop(); // Close loading
                      await showCustomErrorDialog(
                        context,
                        message: 'Échec du paiement: ${e.toString()}',
                        showRetry: false,
                      );
                    }
                  },
                  child: const Text('Payer maintenant'),
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

      if (createResponse.statusCode != 201) {
        debugPrint('Failed to create payment intent: ${createResponse.data}');
        return false;
      }

      final paymentData = createResponse.data as Map<String, dynamic>;
      final paymentId = paymentData['id'] as String?;
      final clientSecret = paymentData['client_secret'] as String?;
      final paymentIntentId = paymentData['payment_intent_id'] as String?;

      if (paymentId == null ||
          clientSecret == null ||
          paymentIntentId == null) {
        debugPrint('Missing payment data from server response');
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
      debugPrint(
        '❌ Error processing web payment: ${e.response?.statusCode} - ${e.response?.data ?? e.message}',
      );
      return false;
    } catch (e) {
      debugPrint('❌ Unexpected error in web payment: $e');
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

      if (confirmResponse.statusCode == 201) {
        final confirmData = confirmResponse.data;
        return confirmData['status'] == 'completed' ||
            confirmData['status'] == 'succeeded';
      }

      return false;
    } catch (e) {
      debugPrint('❌ Error confirming web payment: $e');
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
      return 'Veuillez saisir le nom du titulaire de la carte';
    }

    final cleanCardNumber = cardNumber.replaceAll(' ', '');
    if (cleanCardNumber.length != 16) {
      return 'Veuillez saisir un numéro de carte valide à 16 chiffres';
    }

    if (!RegExp(r'^\d{16}$').hasMatch(cleanCardNumber)) {
      return 'Le numéro de carte ne doit contenir que des chiffres';
    }

    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiry)) {
      return 'Veuillez saisir la date d\'expiration au format MM/AA';
    }

    final parts = expiry.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);

    if (month == null || month < 1 || month > 12) {
      return 'Veuillez saisir un mois valide (01-12)';
    }

    final currentYear = DateTime.now().year % 100;
    final currentMonth = DateTime.now().month;

    if (year == null ||
        year < currentYear ||
        (year == currentYear && month < currentMonth)) {
      return 'La carte a expiré';
    }

    if (cvc.length < 3 || cvc.length > 4) {
      return 'Veuillez saisir un CVC valide (3-4 chiffres)';
    }

    if (!RegExp(r'^\d{3,4}$').hasMatch(cvc)) {
      return 'Le CVC ne doit contenir que des chiffres';
    }

    return null;
  }

  void _disposeControllers(List<TextEditingController> controllers) {
    for (final controller in controllers) {
      controller.dispose();
    }
  }

  Future<void> _handleStripeError(
    BuildContext context,
    StripeException e,
  ) async {
    final code = e.error.code;
    String message;
    if (code == FailureCode.Canceled) {
      message = 'Paiement annulé';
    } else if (code == FailureCode.Failed) {
      message = 'Échec du paiement';
    } else if (code == FailureCode.Timeout) {
      message = 'Délai d\'attente du paiement dépassé';
    } else {
      message = e.error.localizedMessage ?? e.error.message ?? 'Erreur Stripe';
    }

    await showCustomErrorDialog(context, message: message, showRetry: false);
  }

  bool get isPaymentSupported => _isInitialized;
}
