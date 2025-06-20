import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/features/factures/presentation/bloc/facture_event.dart';
import 'package:oilab_frontend/features/factures/presentation/bloc/facture_state.dart';
import '../../data/facture_repository.dart';

class FactureBloc extends Bloc<FactureEvent, FactureState> {
  final FactureRepository factureRepository;

  int _currentPage = 1;
  static const int _pageSize = 6;

  // Store current filters to maintain them during pagination
  String? _currentSearchQuery;
  String? _currentStatusFilter;

  FactureBloc({required this.factureRepository}) : super(FactureInitial()) {
    on<LoadFactures>(_onLoadFactures);
    on<SearchFactures>(_onSearchFactures);
    on<FilterFacturesByStatus>(_onFilterFacturesByStatus);
    on<RefreshFactures>(_onRefreshFactures);
    on<ChangePage>(_onChangePage);
    on<LoadFactureDetail>(_onLoadFactureDetail);
    on<GetFacturePdf>(_onGetFacturePdf);
  }

  Future<void> _onLoadFactures(
    LoadFactures event,
    Emitter<FactureState> emit,
  ) async {
    emit(FactureLoading());
    _currentPage = event.page;
    _currentSearchQuery = event.searchQuery;
    _currentStatusFilter = event.statusFilter;
    await _loadFacturesData(emit);
  }

  // Common method to load factures data
  Future<void> _loadFacturesData(Emitter<FactureState> emit) async {
    try {
      final result = await factureRepository.fetchFactures(
        page: _currentPage,
        pageSize: _pageSize,
        searchQuery: _currentSearchQuery,
        statusFilter: _currentStatusFilter,
      );

      emit(
        FactureLoaded(
          factures: result.factures,
          filteredFactures: result.factures,
          totalCount: result.totalCount,
          currentPage: result.currentPage,
          totalPages: result.totalPages,
          currentSearch: _currentSearchQuery,
          currentFilter: _currentStatusFilter,
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
    // Keep the current page and filters when refreshing
    await _loadFacturesData(emit);
  }

  Future<void> _onChangePage(
    ChangePage event,
    Emitter<FactureState> emit,
  ) async {
    if (state is FactureLoaded) {
      //final currentState = state as FactureLoaded;
      _currentPage = event.page;
      _currentSearchQuery = event.currentSearchQuery;
      _currentStatusFilter = event.statusFilter;
      await _loadFacturesData(emit);
    }
  }

  Future<void> _onSearchFactures(
    SearchFactures event,
    Emitter<FactureState> emit,
  ) async {
    _currentSearchQuery = event.query.isEmpty ? null : event.query;
    _currentPage = 1; // Reset to first page
    add(LoadFactures(page: 1, searchQuery: _currentSearchQuery, statusFilter: _currentStatusFilter));
  }

  Future<void> _onFilterFacturesByStatus(
    FilterFacturesByStatus event,
    Emitter<FactureState> emit,
  ) async {
    _currentStatusFilter = event.status;
    _currentPage = 1; // Reset to first page
    add(LoadFactures(page: 1, searchQuery: _currentSearchQuery, statusFilter: _currentStatusFilter));
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
}
