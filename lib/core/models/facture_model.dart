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
      id: json['id'],
      quality: json['quality'],
      origine: json['origine'],
      price: json['price'],
      quantity: json['quantity'],
      client: json['client'],
      clientName: json['client_name'],
      status: json['status'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      photo: json['photo'],
      estimationTime: json['estimation_time'],
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
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
      profilePhoto: json['profile_photo'],
      isActive: json['isActive'],
      cin: json['cin'],
      tel: json['tel'],
    );
  }
}

class Facture {
  final int id;
  final String type;
  final Product product;
  final String client;
  final Employee employee;
  final Employee accountant;
  final String baseAmount;
  final String taxAmount;
  final String totalAmount;
  final DateTime issueDate;
  final DateTime dueDate;
  final String status;
  final DateTime? paymentDate;
  final String paymentUuid;
  final bool qrVerified;
  final String qrCodeUrl;
  final String? imageUrl;
  final String? pdfUrl;

  Facture({
    required this.id,
    required this.type,
    required this.product,
    required this.client,
    required this.employee,
    required this.accountant,
    required this.baseAmount,
    required this.taxAmount,
    required this.totalAmount,
    required this.issueDate,
    required this.dueDate,
    required this.status,
    this.paymentDate,
    required this.paymentUuid,
    required this.qrVerified,
    required this.qrCodeUrl,
    this.imageUrl,
    this.pdfUrl,
  });

  factory Facture.fromJson(Map<String, dynamic> json) {
    return Facture(
      id: json['id'],
      type: json['type'],
      product: Product.fromJson(json['product']),
      client: json['client'],
      employee: Employee.fromJson(json['employee']),
      accountant: Employee.fromJson(json['accountant']),
      baseAmount: json['base_amount'],
      taxAmount: json['tax_amount'],
      totalAmount: json['total_amount'],
      issueDate: DateTime.parse(json['issue_date']),
      dueDate: DateTime.parse(json['due_date']),
      status: json['status'],
      paymentDate: json['payment_date'] != null ? DateTime.parse(json['payment_date']) : null,
      paymentUuid: json['payment_uuid'],
      qrVerified: json['qr_verified'],
      qrCodeUrl: json['qr_code_url'],
      imageUrl: json['image_url'],
      pdfUrl: json['pdf_url'],
    );
  }

  bool get isPaid => status == 'paid';
  
  String get formattedIssueDate {
    return '${issueDate.day.toString().padLeft(2, '0')}/${issueDate.month.toString().padLeft(2, '0')}/${issueDate.year}';
  }
  
  String get formattedDueDate {
    return '${dueDate.day.toString().padLeft(2, '0')}/${dueDate.month.toString().padLeft(2, '0')}/${dueDate.year}';
  }
}