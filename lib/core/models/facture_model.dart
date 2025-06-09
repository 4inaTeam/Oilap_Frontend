class Product {
  final int id;
  final String quality;
  final String origine;
  final String price;
  final int quantity;
  final String client;
  final String clientName;
  final String status;
  final String createdBy;
  final DateTime createdAt;
  final String photo;
  final int estimationTime;
  final DateTime? endTime;

  Product({
    required this.id,
    required this.quality,
    required this.origine,
    required this.price,
    required this.quantity,
    required this.client,
    required this.clientName,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.photo,
    required this.estimationTime,
    this.endTime,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      quality: json['quality'] ?? '',
      origine: json['origine'] ?? '',
      price: json['price'] ?? '0',
      quantity: json['quantity'] ?? 0,
      client: json['client'] ?? '',
      clientName: json['client_name'] ?? '',
      status: json['status'] ?? '',
      createdBy: json['created_by'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      photo: json['photo'] ?? '',
      estimationTime: json['estimation_time'] ?? 0,
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
    );
  }
}

class Employee {
  final int id;
  final String username;
  final String email;
  final String role;
  final String profilePhoto;
  final bool isActive;
  final String cin;
  final String? tel;

  Employee({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.profilePhoto,
    required this.isActive,
    required this.cin,
    this.tel,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      profilePhoto: json['profile_photo'] ?? '',
      isActive: json['isActive'] ?? false,
      cin: json['cin'] ?? '',
      tel: json['tel'],
    );
  }
}

class Facture {
  final int id;
  final String factureNumber;
  final int client;
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

  Facture({
    required this.id,
    required this.factureNumber,
    required this.client,
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
      client: json['client'] ?? 0,
      clientName: json['client_name'] ?? '',
      clientEmail: json['client_email'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
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
      products: json['products'] != null
          ? (json['products'] as List)
              .map((p) => FactureProduct.fromJson(p))
              .toList()
          : [],
    );
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
}

class FactureProduct {
  final int id;
  final String quality;
  final int quantity;
  final double price;
  final String origine;
  final String status;
  final String payement;

  FactureProduct({
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
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}