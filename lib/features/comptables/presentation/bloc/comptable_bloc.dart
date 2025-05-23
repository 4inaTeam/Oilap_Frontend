import 'package:flutter_bloc/flutter_bloc.dart';
import 'comptable_event.dart';
import 'comptable_state.dart';
import '../../data/comptable_repository.dart';

class ComptableBloc extends Bloc<ComptableEvent, ComptableState> {
  final ComptableRepository repo;
  ComptableBloc(this.repo) : super(ComptableInitial()) {
    on<LoadComptables>((e, emit) async {
      emit(ComptableLoading());
      try {
        final list = await repo.fetchComptables();
        emit(ComptableLoadSuccess(list));
      } catch (err) {
        emit(ComptableOperationFailure(err.toString()));
      }
    });
    on<AddComptable>((e, emit) async {
      emit(ComptableLoading());
      try {
        await repo.createComptable(
          username: e.username,
          email: e.email,
          password: e.password,
          cin: e.cin,
          tel: e.tel,
          role: e.role,
        );
        emit(ComptableAddSuccess());
        final list = await repo.fetchComptables();
        emit(ComptableLoadSuccess(list));
      } catch (err) {
        emit(ComptableOperationFailure(err.toString()));
      }
    });

    on<UpdateComptableRole>((event, emit) async {
      try {
        emit(ComptableLoading());
        await repo.updateRole(event.userId, event.newRole);
        final updatedList = await repo.fetchComptables();
        emit(ComptableLoadSuccess(updatedList));
      } catch (e) {
        emit(ComptableOperationFailure(e.toString()));
      }
    });

    on<DeleteComptable>((event, emit) async {
      emit(ComptableLoading());
      try {
        await repo.deleteComptable(event.userId);
        final list = await repo.fetchComptables();
        emit(ComptableLoadSuccess(list));
      } catch (err) {
        emit(ComptableOperationFailure(err.toString()));
      }
    });
  }
}