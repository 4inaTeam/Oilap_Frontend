abstract class FactureEvent {}

class LoadFactures extends FactureEvent {}

class SearchFactures extends FactureEvent {
  final String query;
  SearchFactures(this.query);
}

class FilterFacturesByStatus extends FactureEvent {
  final String? status;
  FilterFacturesByStatus(this.status);
}

class RefreshFactures extends FactureEvent {}

class LoadFactureDetail extends FactureEvent {
  final int factureId;
  LoadFactureDetail(this.factureId);
}

class GetFacturePdf extends FactureEvent {
  final int factureId;
  GetFacturePdf(this.factureId);
}
