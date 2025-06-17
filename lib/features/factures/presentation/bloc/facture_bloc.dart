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
    on<LoadFacturesPage>(_onLoadFacturesPage); // Add this handler
    on<SearchFactures>(_onSearchFactures);
    on<FilterFacturesByStatus>(_onFilterFacturesByStatus);
    on<RefreshFactures>(_onRefreshFactures);
    on<LoadFactureDetail>(_onLoadFactureDetail);
    on<GetFacturePdf>(_onGetFacturePdf);
  }

  Future<void> _onLoadFactures(
    LoadFactures event,
    Emitter<FactureState> emit,
  ) async {
    emit(FactureLoading());
    _currentPage = 1; 
    await _loadFacturesData(emit);
  }

  Future<void> _onLoadFacturesPage(
    LoadFacturesPage event,
    Emitter<FactureState> emit,
  ) async {
    emit(FactureLoading());
    _currentPage = event.page;
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

  void _onSearchFactures(SearchFactures event, Emitter<FactureState> emit) {
    _currentSearchQuery = event.query.isEmpty ? null : event.query;
    _currentPage = 1; // Reset to first page when searching
    add(LoadFacturesPage(1)); // Trigger a new load with search
  }

  void _onFilterFacturesByStatus(
    FilterFacturesByStatus event,
    Emitter<FactureState> emit,
  ) {
    _currentStatusFilter = event.status;
    _currentPage = 1; // Reset to first page when filtering
    add(LoadFacturesPage(1)); // Trigger a new load with filter
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
