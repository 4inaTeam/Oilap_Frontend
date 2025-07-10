import 'package:equatable/equatable.dart';

class Facture extends Equatable {
  final int id;
  final String factureNumber;
  final int clientId;
  final String clientName;
  final String clientEmail;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String paymentStatus;
  final double totalAmount;
  final double tvaRate;
  final double tvaAmount;
  final double creditCardFee;
  final double finalTotal;
  final String? stripePaymentIntent;
  final String pdfUrl;
  final String pdfPublicId;
  final List<FactureProduct> products;

  const Facture({
    required this.id,
    required this.factureNumber,
    required this.clientId,
    required this.clientName,
    required this.clientEmail,
    required this.createdAt,
    required this.updatedAt,
    required this.paymentStatus,
    required this.totalAmount,
    required this.tvaRate,
    required this.tvaAmount,
    required this.creditCardFee,
    required this.finalTotal,
    this.stripePaymentIntent,
    required this.pdfUrl,
    required this.pdfPublicId,
    required this.products,
  });

  factory Facture.fromJson(Map<String, dynamic> json) {
    return Facture(
      id: json['id'] ?? 0,
      factureNumber: json['facture_number'] ?? '',

      // Handle client - API might return int ID or nested object
      clientId: _extractClientId(json['client']),
      clientName: _extractClientName(json),
      clientEmail: _extractClientEmail(json),

      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : DateTime.now(),
      paymentStatus: json['payment_status'] ?? 'unpaid',
      totalAmount: _parseDouble(json['total_amount']),
      tvaRate: _parseDouble(json['tva_rate']),
      tvaAmount: _parseDouble(json['tva_amount']),
      creditCardFee: _parseDouble(json['credit_card_fee']),
      finalTotal: _parseDouble(json['final_total']),
      stripePaymentIntent: json['stripe_payment_intent'],
      pdfUrl: json['pdf_url'] ?? '',
      pdfPublicId: json['pdf_public_id'] ?? '',

      // Handle products - API might return different formats
      products: _extractProducts(json['products']),
    );
  }

  // Helper method to extract client ID
  static int _extractClientId(dynamic clientData) {
    if (clientData == null) return 0;
    if (clientData is int) return clientData;
    if (clientData is Map<String, dynamic>) {
      return clientData['id'] as int? ?? 0;
    }
    if (clientData is String) {
      return int.tryParse(clientData) ?? 0;
    }
    return 0;
  }

  // Helper method to extract client name
  static String _extractClientName(Map<String, dynamic> json) {
    // Try different possible field names for client name
    if (json['client_name'] != null) {
      return json['client_name'] as String;
    }

    // If client is an object, extract name from it
    final clientData = json['client'];
    if (clientData is Map<String, dynamic>) {
      return clientData['name'] as String? ??
          clientData['username'] as String? ??
          'Unknown Client';
    }

    return 'Unknown Client';
  }

  // Helper method to extract client email
  static String _extractClientEmail(Map<String, dynamic> json) {
    // Try different possible field names for client email
    if (json['client_email'] != null) {
      return json['client_email'] as String;
    }

    // If client is an object, extract email from it
    final clientData = json['client'];
    if (clientData is Map<String, dynamic>) {
      return clientData['email'] as String? ?? '';
    }

    return '';
  }

  // Helper method to extract products
  static List<FactureProduct> _extractProducts(dynamic productsData) {
    if (productsData == null) return [];

    if (productsData is List) {
      return productsData
          .map((productData) {
            if (productData is Map<String, dynamic>) {
              return FactureProduct.fromJson(productData);
            }
            return null;
          })
          .where((product) => product != null)
          .cast<FactureProduct>()
          .toList();
    }

    return [];
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'facture_number': factureNumber,
    'client_id': clientId,
    'client_name': clientName,
    'client_email': clientEmail,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'payment_status': paymentStatus,
    'total_amount': totalAmount,
    'tva_rate': tvaRate,
    'tva_amount': tvaAmount,
    'credit_card_fee': creditCardFee,
    'final_total': finalTotal,
    'stripe_payment_intent': stripePaymentIntent,
    'pdf_url': pdfUrl,
    'pdf_public_id': pdfPublicId,
    'products': products.map((product) => product.toJson()).toList(),
  };

  @override
  List<Object?> get props => [
    id,
    factureNumber,
    clientId,
    clientName,
    clientEmail,
    createdAt,
    updatedAt,
    paymentStatus,
    totalAmount,
    tvaRate,
    tvaAmount,
    creditCardFee,
    finalTotal,
    stripePaymentIntent,
    pdfUrl,
    pdfPublicId,
    products,
  ];
}

class FactureProduct extends Equatable {
  final int id;
  final String quality;
  final int quantity;
  final double price;
  final String origine;
  final String status;
  final String payement;

  const FactureProduct({
    required this.id,
    required this.quality,
    required this.quantity,
    required this.price,
    required this.origine,
    required this.status,
    required this.payement,
  });

  factory FactureProduct.fromJson(Map<String, dynamic> json) {
    return FactureProduct(
      id: json['id'] ?? 0,
      quality: json['quality'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: _parseDouble(json['price']),
      origine: json['origine'] ?? '',
      status: json['status'] ?? '',
      payement: json['payement'] ?? '',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'quality': quality,
    'quantity': quantity,
    'price': price,
    'origine': origine,
    'status': status,
    'payement': payement,
  };

  @override
  List<Object?> get props => [
    id,
    quality,
    quantity,
    price,
    origine,
    status,
    payement,
  ];
}
