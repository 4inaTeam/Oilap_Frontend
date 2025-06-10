import 'package:oilab_frontend/core/models/facture_model.dart';

abstract class FactureState {}

class FactureInitial extends FactureState {}

class FactureLoading extends FactureState {}

class FactureLoaded extends FactureState {
  final List<Facture> factures;
  final List<Facture> filteredFactures;
  final String? currentFilter;
  final String? currentSearch;

  FactureLoaded({
    required this.factures,
    required this.filteredFactures,
    this.currentFilter,
    this.currentSearch,
  });

  FactureLoaded copyWith({
    List<Facture>? factures,
    List<Facture>? filteredFactures,
    String? currentFilter,
    String? currentSearch,
  }) {
    return FactureLoaded(
      factures: factures ?? this.factures,
      filteredFactures: filteredFactures ?? this.filteredFactures,
      currentFilter: currentFilter ?? this.currentFilter,
      currentSearch: currentSearch ?? this.currentSearch,
    );
  }
}

class FactureDetailLoaded extends FactureState {
  final Facture facture;
  FactureDetailLoaded(this.facture);
}

class FactureError extends FactureState {
  final String message;
  FactureError(this.message);
}

class FactureDeleting extends FactureState {}

class FactureDeleted extends FactureState {}

class FacturePdfLoaded extends FactureState {
  final String pdfUrl;
  FacturePdfLoaded(this.pdfUrl);
}
