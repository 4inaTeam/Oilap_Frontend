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
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String clientCin = '';
    int? clientId;

    if (json['client_Cin'] != null) {
      clientCin = json['client_Cin'].toString();
    } else if (json['client_cin'] != null) {
      clientCin = json['client_cin'].toString();
    } else if (json['clientCin'] != null) {
      clientCin = json['clientCin'].toString();
    } else if (json['client_id'] != null) {
      clientId =
          json['client_id'] is int
              ? json['client_id']
              : int.tryParse(json['client_id'].toString());
      clientCin = json['client_id'].toString();
    } else if (json['clientId'] != null) {
      clientId =
          json['clientId'] is int
              ? json['clientId']
              : int.tryParse(json['clientId'].toString());
      clientCin = json['clientId'].toString();
    } else if (json['client'] != null) {
      if (json['client'] is Map) {
        // If client is an object, try to get ID from it
        final clientObj = json['client'] as Map<String, dynamic>;
        clientId = clientObj['id'] ?? clientObj['client_id'];
        clientCin = clientId?.toString() ?? '';
      } else {
        // If client is a direct value
        clientId =
            json['client'] is int
                ? json['client']
                : int.tryParse(json['client'].toString());
        clientCin = json['client'].toString();
      }
    }

    return Product(
      id: json['id'] as int? ?? 0,
      quality: json['quality'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      origine: json['origine'] as String? ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      status: json['status'] as String? ?? 'pending',
      ownerName: json['owner_name'] as String? ?? '',
      clientCin: clientCin,
      clientId: clientId,
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
        'clientId: $clientId'
        '}';
  }

  @override
  String toString() {
    return 'Product(id: $id, quality: $quality, quantity: $quantity, origine: $origine, price: $price, status: $status, clientCin: $clientCin, clientId: $clientId)';
  }
}
