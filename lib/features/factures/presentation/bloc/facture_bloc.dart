import 'package:bloc/bloc.dart';
import '../../data/facture_repository.dart';
import 'package:oilab_frontend/features/factures/presentation/bloc/facture_event.dart';
import 'package:oilab_frontend/features/factures/presentation/bloc/facture_state.dart';

class FactureBloc extends Bloc<FactureEvent, FactureState> {
  final FactureRepository repository;
  
  // Pagination state
  int _currentPage = 1;
  static const int _pageSize = 10;
  String? _currentSearchQuery;
  String? _currentStatusFilter;

  FactureBloc({required this.repository}) : super(FactureInitial()) {
    on<LoadFactures>(_onLoadFactures);
    on<SearchFactures>(_onSearchFactures);
    on<FilterFacturesByStatus>(_onFilterFacturesByStatus);
    on<DeleteFacture>(_onDeleteFacture);
    on<RefreshFactures>(_onRefreshFactures);
  }

  Future<void> _onLoadFactures(LoadFactures event, Emitter<FactureState> emit) async {
    emit(FactureLoading());
    try {
      _currentPage = 1;
      _currentSearchQuery = null;
      _currentStatusFilter = null;
      
      final result = await repository.fetchFactures(
        page: _currentPage,
        pageSize: _pageSize,
      );
      
      emit(FactureLoaded(
        factures: result.factures,
        filteredFactures: result.factures,
      ));
    } catch (e) {
      emit(FactureError('Failed to load factures: ${e.toString()}'));
    }
  }

  Future<void> _onSearchFactures(SearchFactures event, Emitter<FactureState> emit) async {
    emit(FactureLoading());
    try {
      _currentPage = 1;
      _currentSearchQuery = event.query.isEmpty ? null : event.query;
      
      final result = await repository.fetchFactures(
        page: _currentPage,
        pageSize: _pageSize,
        searchQuery: _currentSearchQuery,
        statusFilter: _currentStatusFilter,
      );
      
      emit(FactureLoaded(
        factures: result.factures,
        filteredFactures: result.factures,
        searchQuery: event.query,
        currentFilter: _currentStatusFilter,
      ));
    } catch (e) {
      emit(FactureError('Failed to search factures: ${e.toString()}'));
    }
  }

  Future<void> _onFilterFacturesByStatus(FilterFacturesByStatus event, Emitter<FactureState> emit) async {
    emit(FactureLoading());
    try {
      _currentPage = 1;
      _currentStatusFilter = event.status;
      
      final result = await repository.fetchFactures(
        page: _currentPage,
        pageSize: _pageSize,
        searchQuery: _currentSearchQuery,
        statusFilter: _currentStatusFilter,
      );
      
      emit(FactureLoaded(
        factures: result.factures,
        filteredFactures: result.factures,
        searchQuery: _currentSearchQuery,
        currentFilter: event.status,
      ));
    } catch (e) {
      emit(FactureError('Failed to filter factures: ${e.toString()}'));
    }
  }


  Future<void> _onDeleteFacture(DeleteFacture event, Emitter<FactureState> emit) async {
    if (state is FactureLoaded) {
      final currentState = state as FactureLoaded;
      emit(FactureDeleting(event.factureId));
      
      try {
        await repository.deleteFacture(event.factureId);
        
        // Remove the deleted facture from the list
        final updatedFactures = currentState.factures
            .where((facture) => facture.id != event.factureId)
            .toList();
        
        // Update filtered factures as well
        final updatedFilteredFactures = currentState.filteredFactures
            .where((facture) => facture.id != event.factureId)
            .toList();

        emit(FactureLoaded(
          factures: updatedFactures,
          filteredFactures: updatedFilteredFactures,
          searchQuery: currentState.searchQuery,
          currentFilter: currentState.currentFilter,
        ));
        
        // Emit deleted state for showing success message
        emit(FactureDeleted(event.factureId));
      } catch (e) {
        emit(FactureError('Failed to delete facture: ${e.toString()}'));
      }
    }
  }

  Future<void> _onRefreshFactures(RefreshFactures event, Emitter<FactureState> emit) async {
    // Reset pagination and reload
    _currentPage = 1;
    add(LoadFactures());
  }
}