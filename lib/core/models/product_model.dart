class Product {
  final int id;
  final String quality;
  final int quantity;
  final String origine;
  final double price;
  final String status;
  final String clientCin;
  final String ownerName;
  final int? clientId;
  final String? photo;
  final String? createdAt;
  final String? estimationDate;
  final String? createdBy;

  Product({
    required this.id,
    required this.quality,
    required this.quantity,
    required this.origine,
    required this.price,
    required this.status,
    required this.clientCin,
    required this.ownerName,
    this.clientId,
    this.photo,
    this.createdAt,
    this.estimationDate,
    this.createdBy,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String clientCin = '';
    int? clientId;
    String ownerName = '';

    // Handle client CIN
    if (json['client_Cin'] != null) {
      clientCin = json['client_Cin'].toString();
    } else if (json['client_cin'] != null) {
      clientCin = json['client_cin'].toString();
    } else if (json['clientCin'] != null) {
      clientCin = json['clientCin'].toString();
    } else if (json['client_id'] != null) {
      clientId = json['client_id'] is int
          ? json['client_id']
          : int.tryParse(json['client_id'].toString());
      clientCin = json['client_id'].toString();
    } else if (json['clientId'] != null) {
      clientId = json['clientId'] is int
          ? json['clientId']
          : int.tryParse(json['clientId'].toString());
      clientCin = json['clientId'].toString();
    } else if (json['client'] != null) {
      if (json['client'] is Map) {
        final clientObj = json['client'] as Map<String, dynamic>;
        clientId = clientObj['id'] ?? clientObj['client_id'];
        clientCin = clientId?.toString() ?? '';
      } else {
        clientId = json['client'] is int
            ? json['client']
            : int.tryParse(json['client'].toString());
        clientCin = json['client'].toString();
      }
    }

    // Handle owner name - check for client_name from your backend response
    if (json['client_name'] != null) {
      ownerName = json['client_name'].toString();
    } else if (json['owner_name'] != null) {
      ownerName = json['owner_name'].toString();
    } else if (json['ownerName'] != null) {
      ownerName = json['ownerName'].toString();
    }

    return Product(
      id: json['id'] as int? ?? 0,
      quality: json['quality'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      origine: json['origine'] as String? ?? '',
      price: (json['price'] is String) 
          ? double.tryParse(json['price']) ?? 0.0
          : (json['price'] is num) 
              ? (json['price'] as num).toDouble() 
              : 0.0,
      status: json['status'] as String? ?? 'pending',
      ownerName: ownerName,
      clientCin: clientCin,
      clientId: clientId,
      photo: json['photo'] as String?,
      createdAt: json['created_at'] as String?,
      estimationDate: json['estimation_date'] as String?,
      createdBy: json['created_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'quality': quality,
        'quantity': quantity,
        'origine': origine,
        'price': price,
        'status': status,
        'client_Cin': clientCin,
        if (clientId != null) 'client_id': clientId,
        if (photo != null) 'photo': photo,
        if (createdAt != null) 'created_at': createdAt,
        if (estimationDate != null) 'estimation_date': estimationDate,
        if (createdBy != null) 'created_by': createdBy,
      };

  String toDetailedString() {
    return 'Product{'
        'id: $id, '
        'quality: $quality, '
        'quantity: $quantity, '
        'origine: $origine, '
        'price: $price, '
        'status: $status, '
        'clientCin: "$clientCin", '
        'ownerName: "$ownerName", '
        'clientId: $clientId'
        '}';
  }

  @override
  String toString() {
    return 'Product(id: $id, quality: $quality, quantity: $quantity, origine: $origine, price: $price, status: $status, clientCin: $clientCin, ownerName: $ownerName, clientId: $clientId)';
  }
}