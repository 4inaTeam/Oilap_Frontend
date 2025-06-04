import 'package:equatable/equatable.dart';

abstract class FactureEvent extends Equatable {
  const FactureEvent();

  @override
  List<Object?> get props => [];
}

class LoadFactures extends FactureEvent {}

class SearchFactures extends FactureEvent {
  final String query;

  const SearchFactures(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterFacturesByStatus extends FactureEvent {
  final String? status; 

  const FilterFacturesByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class DeleteFacture extends FactureEvent {
  final int factureId;

  const DeleteFacture(this.factureId);

  @override
  List<Object?> get props => [factureId];
}

class RefreshFactures extends FactureEvent {}