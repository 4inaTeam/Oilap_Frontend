// revenue_state.dart
import 'package:equatable/equatable.dart';

abstract class RevenueState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RevenueInitial extends RevenueState {}

class RevenueLoading extends RevenueState {}

class RevenueLoaded extends RevenueState {
  final double totalRevenue;
  final double totalAmountBeforeTax;

  RevenueLoaded({
    required this.totalRevenue,
    required this.totalAmountBeforeTax,
  });

  @override
  List<Object?> get props => [totalRevenue, totalAmountBeforeTax];
}

class RevenueError extends RevenueState {
  final String message;

  RevenueError(this.message);

  @override
  List<Object?> get props => [message];
}
