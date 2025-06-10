import 'package:oilab_frontend/core/models/facture_model.dart';

abstract class FactureState {}

class FactureInitial extends FactureState {}

class FactureLoading extends FactureState {}

class FactureLoaded extends FactureState {
  final List<Facture> factures;
  final List<Facture> filteredFactures;
  final String? currentFilter;
  final String? currentSearch;
  final int totalCount;
  final int currentPage;
  final int totalPages;

  FactureLoaded({
    required this.factures,
    required this.filteredFactures,
    this.currentFilter,
    this.currentSearch,
    this.totalCount = 0,
    this.currentPage = 1,
    this.totalPages = 1,
  });

  FactureLoaded copyWith({
    List<Facture>? factures,
    List<Facture>? filteredFactures,
    String? currentFilter,
    String? currentSearch,
    int? totalCount,
    int? currentPage,
    int? totalPages,
  }) {
    return FactureLoaded(
      factures: factures ?? this.factures,
      filteredFactures: filteredFactures ?? this.filteredFactures,
      currentFilter: currentFilter ?? this.currentFilter,
      currentSearch: currentSearch ?? this.currentSearch,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
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
