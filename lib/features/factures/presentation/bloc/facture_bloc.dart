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

      // Validate that the current page is within bounds
      if (_currentPage > result.totalPages && result.totalPages > 0) {
        _currentPage = result.totalPages;
        // Retry with the corrected page
        final correctedResult = await factureRepository.fetchFactures(
          page: _currentPage,
          pageSize: _pageSize,
          searchQuery: _currentSearchQuery,
          statusFilter: _currentStatusFilter,
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
    // Validate page number
    if (event.page <= 0) {
      emit(FactureError('Numéro de page invalide'));
      return;
    }

    // Check if we're already on this page
    if (event.page == _currentPage) {
      return;
    }

    // Update page and filters
    _currentPage = event.page;
    _currentSearchQuery = event.currentSearchQuery;
    _currentStatusFilter = event.statusFilter;

    // Show loading only if we're changing pages significantly
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
    _currentPage = 1; // Reset to first page when searching

    // Don't show loading if it's just clearing the search
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
    _currentPage = 1; // Reset to first page when filtering

    emit(FactureLoading());

    try {
      await _loadFacturesData(emit);
    } catch (e) {
      emit(FactureError('Erreur lors du filtrage: ${e.toString()}'));
    }

    // REMOVED: The duplicate add(LoadFactures(...)) call that was causing issues
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

  // Helper method to get current state info
  Map<String, dynamic> getCurrentStateInfo() {
    return {
      'currentPage': _currentPage,
      'pageSize': _pageSize,
      'searchQuery': _currentSearchQuery,
      'statusFilter': _currentStatusFilter,
    };
  }

  // Method to reset pagination state
  void resetPagination() {
    _currentPage = 1;
    _currentSearchQuery = null;
    _currentStatusFilter = null;
  }
}
