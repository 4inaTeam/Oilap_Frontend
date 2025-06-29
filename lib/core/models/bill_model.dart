import 'dart:convert';

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

  String? get pdfUrl => pdfFile;

  String? get fullPdfUrl {
    if (pdfFile == null || pdfFile!.isEmpty) return null;

    if (pdfFile!.startsWith('http://') || pdfFile!.startsWith('https://')) {
      return pdfFile;
    }

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
      items: _parseItemsFromBackend(json['items']),
      originalImage: json['original_image']?.toString(),
      pdfFile: json['pdf_file']?.toString(),
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null,
    );
  }

  static List<Map<String, dynamic>>? _parseItemsFromBackend(dynamic itemsData) {
    if (itemsData == null) return null;

    try {
      if (itemsData is List) {
        return itemsData.map((item) {
          if (item is Map<String, dynamic>) {
            return {
              'name': item['title']?.toString() ?? '',
              'quantity': _parseDouble(item['quantity']),
              'price': _parseDouble(item['unit_price']),
            };
          }
          return item as Map<String, dynamic>;
        }).toList();
      }

      if (itemsData is String) {
        final decoded = json.decode(itemsData);
        if (decoded is List) {
          return decoded.map((item) {
            if (item is Map<String, dynamic>) {
              if (item.containsKey('title') && item.containsKey('unit_price')) {
                return {
                  'name': item['title']?.toString() ?? '',
                  'quantity': _parseDouble(item['quantity']),
                  'price': _parseDouble(item['unit_price']),
                };
              }
              return item;
            }
            return item as Map<String, dynamic>;
          }).toList();
        }
      }

      return null;
    } catch (e) {
      print('Error parsing items: $e');
      return null;
    }
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
