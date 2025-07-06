// bill_statistics_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/features/bills/data/bill_statistics-repository.dart';
import 'bill_statistics_event.dart';
import 'bill_statistics_state.dart';

class BillStatisticsBloc
    extends Bloc<BillStatisticsEvent, BillStatisticsState> {
  final BillStatisticsRepository repository;

  BillStatisticsBloc({required this.repository})
    : super(BillStatisticsInitial()) {
    on<LoadBillStatistics>(_onLoadBillStatistics);
    on<RefreshBillStatistics>(_onRefreshBillStatistics);
  }

  Future<void> _onLoadBillStatistics(
    LoadBillStatistics event,
    Emitter<BillStatisticsState> emit,
  ) async {
    emit(BillStatisticsLoading());
    try {
      final statistics = await repository.fetchBillStatistics();
      emit(BillStatisticsLoaded(statistics));
    } catch (e) {
      emit(BillStatisticsError(e.toString()));
    }
  }

  Future<void> _onRefreshBillStatistics(
    RefreshBillStatistics event,
    Emitter<BillStatisticsState> emit,
  ) async {
    // Don't emit loading for refresh to avoid UI flicker
    try {
      final statistics = await repository.fetchBillStatistics();
      emit(BillStatisticsLoaded(statistics));
    } catch (e) {
      emit(BillStatisticsError(e.toString()));
    }
  }
}
