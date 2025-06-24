import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Bill {
  final int? id;
  final String owner;
  final double amount;
  final String category;
  @JsonKey(name: 'payment_date')
  final DateTime? paymentDate;
  final double? consumption;
  final List<Map<String, dynamic>>? items;
  @JsonKey(name: 'original_image')
  final String? originalImage;
  @JsonKey(name: 'pdf_file')
  final String? pdfFile;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  Bill({
    this.id,
    required this.owner,
    required this.amount,
    required this.category,
    this.paymentDate,
    this.consumption,
    this.items,
    this.originalImage,
    this.pdfFile,
    this.createdAt,
  });

  // Getter for PDF URL - returns the pdfFile as the URL
  String? get pdfUrl => pdfFile;

  // Alternative getter if you need to prepend a base URL
  String? get fullPdfUrl {
    if (pdfFile == null || pdfFile!.isEmpty) return null;

    // If pdfFile already contains a full URL, return as is
    if (pdfFile!.startsWith('http://') || pdfFile!.startsWith('https://')) {
      return pdfFile;
    }

    // Otherwise, you might want to prepend your base URL
    // Replace 'YOUR_BASE_URL' with your actual base URL
    // return 'YOUR_BASE_URL/$pdfFile';

    // For now, return the pdfFile as is
    return pdfFile;
  }

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'] as int?,
      owner: json['owner']?.toString() ?? '',
      amount: _parseDouble(json['amount']),
      category: json['category']?.toString() ?? '',
      paymentDate:
          json['payment_date'] != null
              ? DateTime.tryParse(json['payment_date'].toString())
              : null,
      consumption:
          json['consumption'] != null
              ? _parseDouble(json['consumption'])
              : null,
      items:
          json['items'] != null
              ? (json['items'] as List<dynamic>?)?.cast<Map<String, dynamic>>()
              : null,
      originalImage: json['original_image']?.toString(),
      pdfFile: json['pdf_file']?.toString(),
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner': owner,
      'amount': amount,
      'category': category,
      'payment_date': paymentDate?.toIso8601String().split('T')[0],
      'consumption': consumption,
      'items': items,
      'original_image': originalImage,
      'pdf_file': pdfFile,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      String cleanValue = value.replaceAll(',', '.').trim();
      return double.tryParse(cleanValue) ?? 0.0;
    }
    return 0.0;
  }

  Bill copyWith({
    int? id,
    String? owner,
    double? amount,
    String? category,
    DateTime? paymentDate,
    double? consumption,
    List<Map<String, dynamic>>? items,
    String? originalImage,
    String? pdfFile,
    DateTime? createdAt,
  }) {
    return Bill(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      paymentDate: paymentDate ?? this.paymentDate,
      consumption: consumption ?? this.consumption,
      items: items ?? this.items,
      originalImage: originalImage ?? this.originalImage,
      pdfFile: pdfFile ?? this.pdfFile,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
