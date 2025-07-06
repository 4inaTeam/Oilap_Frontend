class TotalQuantityData {
  final double totalQuantity; // Changed to double since API returns 3630.0
  final double totalOilVolume;
  final double overallYieldPercentage;
  final Map<String, QuantityByStatus> quantityByStatus; // Changed structure
  final int totalProducts;

  TotalQuantityData({
    required this.totalQuantity,
    required this.totalOilVolume,
    required this.overallYieldPercentage,
    required this.quantityByStatus,
    required this.totalProducts,
  });

  factory TotalQuantityData.fromJson(Map<String, dynamic> json) {
    try {

      // Parse quantity_by_status with nested objects
      final quantityByStatusMap = <String, QuantityByStatus>{};
      final quantityByStatusData = json['quantity_by_status'];

      if (quantityByStatusData != null &&
          quantityByStatusData is Map<String, dynamic>) {
        quantityByStatusData.forEach((key, value) {
          if (value != null && value is Map<String, dynamic>) {
            quantityByStatusMap[key] = QuantityByStatus.fromJson(value);
          }
        });
      }

      final result = TotalQuantityData(
        totalQuantity: _parseDouble(json['total_quantity']),
        totalOilVolume: _parseDouble(json['total_oil_volume']),
        overallYieldPercentage: _parseDouble(json['overall_yield_percentage']),
        quantityByStatus: quantityByStatusMap,
        totalProducts: _parseInt(json['total_products']),
      );

      return result;
    } catch (e) {
      // Return default object on error
      return TotalQuantityData(
        totalQuantity: 0.0,
        totalOilVolume: 0.0,
        overallYieldPercentage: 0.0,
        quantityByStatus: {},
        totalProducts: 0,
      );
    }
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

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  // Helper method to get total quantity as int for display
  int get totalQuantityInt => totalQuantity.round();
}

class QuantityByStatus {
  final double totalQuantity;
  final double totalOil;

  QuantityByStatus({required this.totalQuantity, required this.totalOil});

  factory QuantityByStatus.fromJson(Map<String, dynamic> json) {
    try {
      return QuantityByStatus(
        totalQuantity: TotalQuantityData._parseDouble(json['total_quantity']),
        totalOil: TotalQuantityData._parseDouble(json['total_oil']),
      );
    } catch (e) {
      return QuantityByStatus(totalQuantity: 0.0, totalOil: 0.0);
    }
  }
}
