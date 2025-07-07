import 'package:equatable/equatable.dart';
import 'package:oilab_frontend/core/models/facture_model.dart';

abstract class FactureState extends Equatable {
  @override
  List<Object?> get props => [];
}

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
  final int? currentClientId;

  FactureLoaded({
    required this.factures,
    required this.filteredFactures,
    this.currentFilter,
    this.currentSearch,
    this.totalCount = 0,
    this.currentPage = 1,
    this.totalPages = 1,
    this.currentClientId,
  });

  FactureLoaded copyWith({
    List<Facture>? factures,
    List<Facture>? filteredFactures,
    String? currentFilter,
    String? currentSearch,
    int? totalCount,
    int? currentPage,
    int? totalPages,
    int? currentClientId,
  }) {
    return FactureLoaded(
      factures: factures ?? this.factures,
      filteredFactures: filteredFactures ?? this.filteredFactures,
      currentFilter: currentFilter ?? this.currentFilter,
      currentSearch: currentSearch ?? this.currentSearch,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      currentClientId: currentClientId ?? this.currentClientId,
    );
  }

  @override
  List<Object?> get props => [
    factures,
    filteredFactures,
    currentFilter,
    currentSearch,
    totalCount,
    currentPage,
    totalPages,
    currentClientId,
  ];
}

class FactureDetailLoaded extends FactureState {
  final Facture facture;

  FactureDetailLoaded(this.facture);

  @override
  List<Object?> get props => [facture];
}

class FactureError extends FactureState {
  final String message;

  FactureError(this.message);

  @override
  List<Object?> get props => [message];
}

class FactureDeleting extends FactureState {}

class FactureDeleted extends FactureState {}

class FacturePdfLoaded extends FactureState {
  final String pdfUrl;

  FacturePdfLoaded(this.pdfUrl);

  @override
  List<Object?> get props => [pdfUrl];
}

class TotalRevenueLoaded extends FactureState {
  final double totalRevenue;
  final double totalAmountBeforeTax;

  TotalRevenueLoaded({
    required this.totalRevenue,
    required this.totalAmountBeforeTax,
  });

  @override
  List<Object?> get props => [totalRevenue, totalAmountBeforeTax];
}

// New state for dashboard data
class DashboardDataLoaded extends FactureState {
  final List<Facture> recentFactures;
  final double totalRevenue;
  final double totalAmountBeforeTax;
  final int totalFacturesCount;

  DashboardDataLoaded({
    required this.recentFactures,
    required this.totalRevenue,
    required this.totalAmountBeforeTax,
    required this.totalFacturesCount,
  });

  @override
  List<Object?> get props => [
    recentFactures,
    totalRevenue,
    totalAmountBeforeTax,
    totalFacturesCount,
  ];
}
