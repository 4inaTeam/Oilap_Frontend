import 'package:equatable/equatable.dart';
import '../../../../core/models/user_model.dart';

abstract class ComptableState extends Equatable {
  @override List<Object?> get props => [];
}

class ComptableInitial extends ComptableState {}
class ComptableLoading extends ComptableState {}
class ComptableLoadSuccess extends ComptableState {
  final List<User> comptables;
  ComptableLoadSuccess(this.comptables);
  @override List<Object?> get props => [comptables];
}
class ComptableOperationFailure extends ComptableState {
  final String message;
  ComptableOperationFailure(this.message);
  @override List<Object?> get props => [message];
}
class ComptableAddSuccess extends ComptableState {}