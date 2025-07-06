import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/features/dashboard/presentation/bloc/revenuEvent.dart';
import 'package:oilab_frontend/features/dashboard/presentation/bloc/revenuState.dart';
import 'package:oilab_frontend/features/factures/data/facture_repository.dart';

class RevenueBloc extends Bloc<RevenueEvent, RevenueState> {
  final FactureRepository factureRepository;

  RevenueBloc({required this.factureRepository}) : super(RevenueInitial()) {
    on<LoadRevenue>(_onLoadRevenue); // Changed from LoadTotalRevenue
    on<RefreshRevenue>(_onRefreshRevenue);
  }

  Future<void> _onLoadRevenue(
    // Changed method name
    LoadRevenue event, // Changed parameter type
    Emitter<RevenueState> emit,
  ) async {

    emit(RevenueLoading());

    await _fetchRevenue(event.clientId, event.dateFrom, event.dateTo, emit);
  }

  Future<void> _onRefreshRevenue(
    RefreshRevenue event,
    Emitter<RevenueState> emit,
  ) async {
    await _fetchRevenue(event.clientId, event.dateFrom, event.dateTo, emit);
  }

  Future<void> _fetchRevenue(
    int? clientId,
    String? dateFrom,
    String? dateTo,
    Emitter<RevenueState> emit,
  ) async {
    try {

      final result = await factureRepository.fetchTotalRevenue(
        clientId: clientId,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );


      final revenueState = RevenueLoaded(
        totalRevenue: result.totalRevenue,
        totalAmountBeforeTax: result.totalAmountBeforeTax,
      );

      emit(revenueState);
    } catch (e) {
      emit(
        RevenueError(
          'Erreur lors du chargement du chiffre d\'affaires: ${e.toString()}',
        ),
      );
    }
  }
}
