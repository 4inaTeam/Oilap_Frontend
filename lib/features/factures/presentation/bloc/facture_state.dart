import 'package:equatable/equatable.dart';
import '../../../../core/models/facture_model.dart';

abstract class FactureState extends Equatable {
  const FactureState();

  @override
  List<Object?> get props => [];
}

class FactureInitial extends FactureState {}

class FactureLoading extends FactureState {}

class FactureLoaded extends FactureState {
  final List<Facture> factures;
  final List<Facture> filteredFactures;
  final String? currentFilter;
  final String? searchQuery;

  const FactureLoaded({
    required this.factures,
    required this.filteredFactures,
    this.currentFilter,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [factures, filteredFactures, currentFilter, searchQuery];

  FactureLoaded copyWith({
    List<Facture>? factures,
    List<Facture>? filteredFactures,
    String? currentFilter,
    String? searchQuery,
  }) {
    return FactureLoaded(
      factures: factures ?? this.factures,
      filteredFactures: filteredFactures ?? this.filteredFactures,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class FactureError extends FactureState {
  final String message;

  const FactureError(this.message);

  @override
  List<Object?> get props => [message];
}

class FactureDeleting extends FactureState {
  final int factureId;

  const FactureDeleting(this.factureId);

  @override
  List<Object?> get props => [factureId];
}

class FactureDeleted extends FactureState {
  final int deletedFactureId;

  const FactureDeleted(this.deletedFactureId);

  @override
  List<Object?> get props => [deletedFactureId];
}