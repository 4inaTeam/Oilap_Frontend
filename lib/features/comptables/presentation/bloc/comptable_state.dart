import 'package:equatable/equatable.dart';
import '../../../../core/models/user_model.dart';

abstract class ComptableState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ComptableInitial extends ComptableState {}

class ComptableLoading extends ComptableState {}

class ComptableLoadSuccess extends ComptableState {
  final List<User> comptables;
  final int currentPage;
  final int totalPages;
  final int totalComptables;
  final int pageSize;
  final String? currentSearchQuery;

  ComptableLoadSuccess({
    required this.comptables,
    required this.currentPage,
    required this.totalPages,
    required this.totalComptables,
    required this.pageSize,
    this.currentSearchQuery,
  });

  @override
  List<Object?> get props => [
    comptables,
    currentPage,
    totalPages,
    totalComptables,
    pageSize,
    currentSearchQuery,
  ];

  ComptableLoadSuccess copyWith({
    List<User>? comptables,
    int? currentPage,
    int? totalPages,
    int? totalComptables,
    int? pageSize,
    String? currentSearchQuery,
  }) {
    return ComptableLoadSuccess(
      comptables: comptables ?? this.comptables,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalComptables: totalComptables ?? this.totalComptables,
      pageSize: pageSize ?? this.pageSize,
      currentSearchQuery: currentSearchQuery ?? this.currentSearchQuery,
    );
  }
}

class ComptableOperationFailure extends ComptableState {
  final String message;
  ComptableOperationFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class ComptableAddSuccess extends ComptableState {}

class ComptableUpdateSuccess extends ComptableState {}