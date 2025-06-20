abstract class FactureEvent {}

class LoadFactures extends FactureEvent {
  final int page;
  final String? searchQuery;
  final String? statusFilter;

  LoadFactures({this.page = 1, this.searchQuery, this.statusFilter});
}

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

class ChangePage extends FactureEvent {
  final int page;
  final String? currentSearchQuery;
  final String? statusFilter;

  ChangePage(this.page, {this.currentSearchQuery, this.statusFilter});
}
