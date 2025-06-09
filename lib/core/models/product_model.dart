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
  final DateTime? end_time;
  final String? createdBy;
  final int? clientId;
  final int? estimationTime;
  final int? estimation_time;

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
    this.end_time,
    this.createdBy,
    this.clientId,
    this.estimationTime,
    this.estimation_time,
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
      end_time:
          json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      createdBy: json['created_by'] as String?,
      clientId: json['client_id'] as int?,
      estimationTime: json['estimation_time'] as int?,
      estimation_time: json['estimation_time'] as int?, // Parse estimation_time
    );
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
    'end_time': end_time?.toIso8601String(), 
    'estimation_date': estimationDate,
    'client_details': clientDetails,
    'created_by': createdBy,
    'estimation_time': estimationTime,
  };

  Product copyWith({
    int? id,
    String? quality,
    double? quantity, 
    String? origine,
    double? price,
    String? status,
    String? clientCin,
    int? clientId,
    String? photo,
    String? createdAt, 
    DateTime? end_time, 
    String? estimationDate, 
    String? createdBy,
    int? estimationTime,
    int? estimation_time, 
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
      end_time: end_time ?? this.end_time, 
      estimationDate: estimationDate ?? this.estimationDate,
      createdBy: createdBy ?? this.createdBy,
      estimationTime: estimationTime ?? this.estimationTime,
      estimation_time:
          estimation_time ?? this.estimation_time, 
    );
  }

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

  String get formattedEndTime {
    if (end_time == null) return '-';
    return '${end_time!.day.toString().padLeft(2, '0')}/${end_time!.month.toString().padLeft(2, '0')}/${end_time!.year} ${end_time!.hour.toString().padLeft(2, '0')}:${end_time!.minute.toString().padLeft(2, '0')}';
  }

  String get formattedQuantity => '$quantity Kg';

  bool get hasEndTime => end_time != null; 
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
    end_time,
    estimationDate,
    createdBy,
    estimationTime,
    estimation_time,
  ];

  @override
  String toString() {
    return 'Product(id: $id, quality: $quality, quantity: $quantity, origine: $origine, price: $price, status: $status, clientCin: $client, ownerName: ${clientDetails?['username']})';
  }
}
