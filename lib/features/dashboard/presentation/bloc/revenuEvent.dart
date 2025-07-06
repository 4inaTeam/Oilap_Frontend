// revenue_event.dart - Use UNIQUE event names
abstract class RevenueEvent {}

class LoadRevenue extends RevenueEvent {
  // Changed from LoadTotalRevenue
  final int? clientId;
  final String? dateFrom;
  final String? dateTo;

  LoadRevenue({this.clientId, this.dateFrom, this.dateTo});
}

class RefreshRevenue extends RevenueEvent {
  final int? clientId;
  final String? dateFrom;
  final String? dateTo;

  RefreshRevenue({this.clientId, this.dateFrom, this.dateTo});
}
