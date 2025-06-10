import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/features/factures/presentation/bloc/facture_event.dart'
    show
        FactureEvent,
        FilterFacturesByStatus,
        LoadFactureDetail,
        LoadFactures,
        RefreshFactures,
        SearchFactures,
        GetFacturePdf;
import 'package:oilab_frontend/features/factures/presentation/bloc/facture_state.dart';
import '../../../../core/models/facture_model.dart';
import '../../data/facture_repository.dart';

class FactureBloc extends Bloc<FactureEvent, FactureState> {
  final FactureRepository factureRepository;

  FactureBloc({required this.factureRepository}) : super(FactureInitial()) {
    on<LoadFactures>(_onLoadFactures);
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
    try {
      final factures = await factureRepository.fetchFactures();
      emit(FactureLoaded(factures: factures, filteredFactures: factures));
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
    try {
      final factures = await factureRepository.fetchFactures();
      if (state is FactureLoaded) {
        final currentState = state as FactureLoaded;
        final filteredFactures = _applyFilters(
          factures,
          currentState.currentSearch,
          currentState.currentFilter,
        );
        emit(
          currentState.copyWith(
            factures: factures,
            filteredFactures: filteredFactures,
          ),
        );
      } else {
        emit(FactureLoaded(factures: factures, filteredFactures: factures));
      }
    } catch (e) {
      emit(FactureError('Erreur lors du rafraîchissement: ${e.toString()}'));
    }
  }

  void _onSearchFactures(SearchFactures event, Emitter<FactureState> emit) {
    if (state is FactureLoaded) {
      final currentState = state as FactureLoaded;
      final filteredFactures = _applyFilters(
        currentState.factures,
        event.query,
        currentState.currentFilter,
      );
      emit(
        currentState.copyWith(
          filteredFactures: filteredFactures,
          currentSearch: event.query,
        ),
      );
    }
  }

  void _onFilterFacturesByStatus(
    FilterFacturesByStatus event,
    Emitter<FactureState> emit,
  ) {
    if (state is FactureLoaded) {
      final currentState = state as FactureLoaded;
      final filteredFactures = _applyFilters(
        currentState.factures,
        currentState.currentSearch,
        event.status,
      );
      emit(
        currentState.copyWith(
          filteredFactures: filteredFactures,
          currentFilter: event.status,
        ),
      );
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

  List<Facture> _applyFilters(
    List<Facture> factures,
    String? searchQuery,
    String? statusFilter,
  ) {
    List<Facture> filtered = List.from(factures);

    // Apply status filter
    if (statusFilter != null && statusFilter.isNotEmpty) {
      filtered =
          filtered.where((facture) {
            return facture.paymentStatus.toLowerCase() ==
                statusFilter.toLowerCase();
          }).toList();
    }

    // Apply search filter
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered =
          filtered.where((facture) {
            return facture.id.toString().contains(query) ||
                facture.factureNumber.toLowerCase().contains(query) ||
                facture.clientName.toLowerCase().contains(query) ||
                facture.finalTotal.toString().contains(query) ||
                facture.paymentStatus.toLowerCase().contains(query);
          }).toList();
    }

    return filtered;
  }
}
