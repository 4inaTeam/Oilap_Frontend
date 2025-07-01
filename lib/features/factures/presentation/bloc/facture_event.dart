abstract class FactureEvent {}

class LoadFactures extends FactureEvent {
  final int page;
  final String? searchQuery;
  final String? statusFilter;
  final int? clientId; 

  LoadFactures({
    this.page = 1, 
    this.searchQuery, 
    this.statusFilter,
    this.clientId, 
  });
}

class SearchFactures extends FactureEvent {
  final String query;
  final int? clientId; 
  
  SearchFactures(this.query, {this.clientId});
}

class FilterFacturesByStatus extends FactureEvent {
  final String? status;
  final int? clientId; 
  
  FilterFacturesByStatus(this.status, {this.clientId});
}

class RefreshFactures extends FactureEvent {
  final int? clientId; 
  
  RefreshFactures({this.clientId});
}

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
  final int? clientId; 

  ChangePage(
    this.page, {
    this.currentSearchQuery, 
    this.statusFilter,
    this.clientId,
  });
}