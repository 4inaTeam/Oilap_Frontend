import 'package:equatable/equatable.dart';

abstract class BillStatisticsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadBillStatistics extends BillStatisticsEvent {}

class RefreshBillStatistics extends BillStatisticsEvent {}
