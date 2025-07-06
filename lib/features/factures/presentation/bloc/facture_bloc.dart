import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/features/factures/presentation/bloc/facture_event.dart';
import 'package:oilab_frontend/features/factures/presentation/bloc/facture_state.dart';
import '../../data/facture_repository.dart';

class FactureBloc extends Bloc<FactureEvent, FactureState> {
  final FactureRepository factureRepository;

  int _currentPage = 1;
  static const int _pageSize = 10;

  String? _currentSearchQuery;
  String? _currentStatusFilter;
  int? _currentClientId;

  FactureBloc({required this.factureRepository}) : super(FactureInitial()) {
    on<LoadFactures>(_onLoadFactures);
    on<SearchFactures>(_onSearchFactures);
    on<FilterFacturesByStatus>(_onFilterFacturesByStatus);
    on<RefreshFactures>(_onRefreshFactures);
    on<ChangePage>(_onChangePage);
    on<LoadFactureDetail>(_onLoadFactureDetail);
    on<GetFacturePdf>(_onGetFacturePdf);
    on<LoadTotalRevenue>(_onLoadTotalRevenue); // Add new event handler
  }

  Future<void> _onLoadFactures(
    LoadFactures event,
    Emitter<FactureState> emit,
  ) async {
    emit(FactureLoading());
    _currentPage = event.page;
    _currentSearchQuery = event.searchQuery;
    _currentStatusFilter = event.statusFilter;
    _currentClientId = event.clientId;
    await _loadFacturesData(emit);
  }

  Future<void> _loadFacturesData(Emitter<FactureState> emit) async {
    try {
      final result = await factureRepository.fetchFactures(
        page: _currentPage,
        pageSize: _pageSize,
        searchQuery: _currentSearchQuery,
        statusFilter: _currentStatusFilter,
        clientId: _currentClientId,
      );

      if (_currentPage > result.totalPages && result.totalPages > 0) {
        _currentPage = result.totalPages;
        final correctedResult = await factureRepository.fetchFactures(
          page: _currentPage,
          pageSize: _pageSize,
          searchQuery: _currentSearchQuery,
          statusFilter: _currentStatusFilter,
          clientId: _currentClientId,
        );

        emit(
          FactureLoaded(
            factures: correctedResult.factures,
            filteredFactures: correctedResult.factures,
            totalCount: correctedResult.totalCount,
            currentPage: correctedResult.currentPage,
            totalPages: correctedResult.totalPages,
            currentSearch: _currentSearchQuery,
            currentFilter: _currentStatusFilter,
            currentClientId: _currentClientId,
          ),
        );
        return;
      }

      emit(
        FactureLoaded(
          factures: result.factures,
          filteredFactures: result.factures,
          totalCount: result.totalCount,
          currentPage: result.currentPage,
          totalPages: result.totalPages,
          currentSearch: _currentSearchQuery,
          currentFilter: _currentStatusFilter,
          currentClientId: _currentClientId,
        ),
      );
    } catch (e) {
      emit(
        FactureError('Erreur lors du chargement des factures: ${e.toString()}'),
      );
    }
  }

  Future<void> _onRefreshFactures(
    RefreshFactures event,
    Emitter<FactureState> emit,
  ) async {
    if (event.clientId != null) {
      _currentClientId = event.clientId;
    }
    await _loadFacturesData(emit);
  }

  Future<void> _onChangePage(
    ChangePage event,
    Emitter<FactureState> emit,
  ) async {
    if (event.page <= 0) {
      emit(FactureError('Numéro de page invalide'));
      return;
    }

    if (event.page == _currentPage) {
      return;
    }

    _currentPage = event.page;
    _currentSearchQuery = event.currentSearchQuery;
    _currentStatusFilter = event.statusFilter;
    _currentClientId = event.clientId;

    if (state is FactureLoaded) {
      final currentState = state as FactureLoaded;
      if ((event.page - currentState.currentPage).abs() > 1) {
        emit(FactureLoading());
      }
    }

    try {
      await _loadFacturesData(emit);
    } catch (e) {
      emit(FactureError('Erreur lors du changement de page: ${e.toString()}'));
    }
  }

  Future<void> _onSearchFactures(
    SearchFactures event,
    Emitter<FactureState> emit,
  ) async {
    _currentSearchQuery = event.query.isEmpty ? null : event.query;
    _currentClientId = event.clientId;
    _currentPage = 1;

    if (event.query.isNotEmpty || state is! FactureLoaded) {
      emit(FactureLoading());
    }

    try {
      await _loadFacturesData(emit);
    } catch (e) {
      emit(FactureError('Erreur lors de la recherche: ${e.toString()}'));
    }
  }

  Future<void> _onFilterFacturesByStatus(
    FilterFacturesByStatus event,
    Emitter<FactureState> emit,
  ) async {
    _currentStatusFilter = event.status;
    _currentClientId = event.clientId;
    _currentPage = 1;

    emit(FactureLoading());

    try {
      await _loadFacturesData(emit);
    } catch (e) {
      emit(FactureError('Erreur lors du filtrage: ${e.toString()}'));
    }
  }

  Future<void> _onLoadFactureDetail(
    LoadFactureDetail event,
    Emitter<FactureState> emit,
  ) async {
    emit(FactureLoading());
    try {
      final facture = await factureRepository.getFactureDetail(event.factureId);
      emit(FactureDetailLoaded(facture));
    } catch (e) {
      emit(
        FactureError(
          'Erreur lors du chargement de la facture: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onGetFacturePdf(
    GetFacturePdf event,
    Emitter<FactureState> emit,
  ) async {
    emit(FactureLoading());
    try {
      final pdfUrl = await factureRepository.fetchFacturePdfUrl(
        event.factureId,
      );
      if (pdfUrl != null) {
        emit(FacturePdfLoaded(pdfUrl));
      } else {
        emit(FactureError('PDF introuvable pour cette facture.'));
      }
    } catch (e) {
      emit(FactureError('Erreur lors du chargement du PDF: ${e.toString()}'));
    }
  }

  // New handler for LoadTotalRevenue event
  // Add this debug version to your _onLoadTotalRevenue method in FactureBloc

  Future<void> _onLoadTotalRevenue(
    LoadTotalRevenue event,
    Emitter<FactureState> emit,
  ) async {

    emit(FactureLoading());

    try {
      final result = await factureRepository.fetchTotalRevenue(
        clientId: event.clientId,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      );



      final state = TotalRevenueLoaded(
        totalRevenue: result.totalRevenue,
        totalAmountBeforeTax: result.totalAmountBeforeTax, 

      );

      emit(state);
    } catch (e) {
      emit(
        FactureError(
          'Erreur lors du chargement du chiffre d\'affaires: ${e.toString()}',
        ),
      );
    }
  }
}
