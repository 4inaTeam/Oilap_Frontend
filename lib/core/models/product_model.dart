import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int id;
  final String? quality;
  final String? origine;
  final double? price;
  final double? quantity;
  final String client;
  final String? status;
  final String? createdAt;
  final String? photo;
  final String? estimationDate;
  final Map<String, dynamic>? clientDetails;
  final DateTime? exitDate;
  final String? createdBy;
  final int? clientId;

  const Product({
    required this.id,
    this.quality,
    this.origine,
    this.price,
    this.quantity,
    required this.client,
    this.status,
    this.createdAt,
    this.photo,
    this.estimationDate,
    this.clientDetails,
    this.exitDate,
    this.createdBy,
    this.clientId,
  });

  // Use client field instead of clientCin
  String get clientCin => client;
  String? get clientName => clientDetails?['username'] as String?;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      quality: json['quality'] as String?,
      origine: json['origine'] as String?,
      price: double.tryParse(json['price']?.toString() ?? ''),
      quantity: double.tryParse(json['quantity']?.toString() ?? ''),
      client: json['client'] as String? ?? '',
      status: json['status'] as String?,
      createdAt: json['created_at'] as String?,
      photo: json['photo'] as String?,
      estimationDate: json['estimation_date'] as String?,
      clientDetails: json['client_details'] as Map<String, dynamic>?,
      exitDate:
          json['exit_date'] != null ? DateTime.parse(json['exit_date']) : null,
      createdBy: json['created_by'] as String?,
      clientId: json['client_id'] as int?,
    );
  }

  // Helper methods for safe parsing
  static int? _parseIntSafely(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  static String _parseStringSafely(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static double _parseDoubleSafely(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime? _parseDateTimeSafely(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'quality': quality,
    'quantity': quantity,
    'origine': origine,
    'price': price,
    'status': status,
    'client': client,
    'photo': photo,
    'created_at': createdAt,
    'exit_date': exitDate?.toIso8601String(),
    'estimation_date': estimationDate,
    'client_details': clientDetails,
    'created_by': createdBy,
  };

  // Update copyWith method parameter types
  Product copyWith({
    int? id,
    String? quality,
    double? quantity, // Changed from int to double
    String? origine,
    double? price,
    String? status,
    String? clientCin,
    int? clientId,
    String? photo,
    String? createdAt, // Changed from DateTime to String
    DateTime? exitDate,
    String? estimationDate, // Changed from DateTime to String
    String? createdBy,
  }) {
    return Product(
      id: id ?? this.id,
      quality: quality ?? this.quality,
      quantity: quantity ?? this.quantity,
      origine: origine ?? this.origine,
      price: price ?? this.price,
      status: status ?? this.status,
      client: clientCin ?? this.client,
      clientDetails: clientDetails,
      clientId: clientId ?? this.clientId,
      photo: photo ?? this.photo,
      createdAt: createdAt ?? this.createdAt,
      exitDate: exitDate ?? this.exitDate,
      estimationDate: estimationDate ?? this.estimationDate,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  // Fix date formatting methods
  String get formattedCreatedAt {
    if (createdAt == null) return '-';
    try {
      final date = DateTime.parse(createdAt!);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '-';
    }
  }

  String get formattedEstimationDate {
    if (estimationDate == null) return '-';
    try {
      final date = DateTime.parse(estimationDate!);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '-';
    }
  }

  String get formattedExitDate {
    if (exitDate == null) return '-';
    return '${exitDate!.day.toString().padLeft(2, '0')}/${exitDate!.month.toString().padLeft(2, '0')}/${exitDate!.year} ${exitDate!.hour.toString().padLeft(2, '0')}:${exitDate!.minute.toString().padLeft(2, '0')}';
  }

  String get formattedQuantity => '$quantity Kg';

  bool get hasExitDate => exitDate != null;
  bool get hasEstimationDate => estimationDate != null;

  @override
  List<Object?> get props => [
    id,
    quality,
    quantity,
    origine,
    price,
    status,
    client,
    clientId,
    photo,
    createdAt,
    exitDate,
    estimationDate,
    createdBy,
  ];

  @override
  String toString() {
    return 'Product(id: $id, quality: $quality, quantity: $quantity, origine: $origine, price: $price, status: $status, clientCin: $client, ownerName: ${clientDetails?['username']})';
  }
}
