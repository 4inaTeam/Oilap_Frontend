import 'package:equatable/equatable.dart';
import 'package:oilab_frontend/features/bills/data/bill_statistics_repository.dart';

abstract class BillStatisticsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BillStatisticsInitial extends BillStatisticsState {}

class BillStatisticsLoading extends BillStatisticsState {}

class BillStatisticsLoaded extends BillStatisticsState {
  final BillStatistics statistics;

  BillStatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}

class BillStatisticsError extends BillStatisticsState {
  final String message;

  BillStatisticsError(this.message);

  @override
  List<Object?> get props => [message];
}
