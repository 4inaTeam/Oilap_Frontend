import 'package:flutter_bloc/flutter_bloc.dart';
import 'client_event.dart';
import 'client_state.dart';
import '../../data/client_repository.dart';

class ClientBloc extends Bloc<ClientEvent, ClientState> {
  final ClientRepository repo;

  ClientBloc(this.repo) : super(ClientInitial()) {
    on<LoadClients>((event, emit) async {
      emit(ClientLoading());
      try {
        final result = await repo.fetchClients(
          page: event.page,
          pageSize: event.pageSize,
          searchQuery: event.searchQuery,
        );

        emit(ClientLoadSuccess(
          clients: result.clients,
          currentPage: result.currentPage,
          totalPages: result.totalPages,
          totalClients: result.totalCount,
          pageSize: event.pageSize,
          currentSearchQuery: event.searchQuery,
        ));
      } catch (err) {
        emit(ClientOperationFailure(err.toString()));
      }
    });

    on<SearchClients>((event, emit) async {
      emit(ClientLoading());
      try {
        final result = await repo.fetchClients(
          page: event.page,
          pageSize: event.pageSize,
          searchQuery: event.query,
        );

        emit(ClientLoadSuccess(
          clients: result.clients,
          currentPage: result.currentPage,
          totalPages: result.totalPages,
          totalClients: result.totalCount,
          pageSize: event.pageSize,
          currentSearchQuery: event.query,
        ));
      } catch (err) {
        emit(ClientOperationFailure(err.toString()));
      }
    });

    on<ChangePage>((event, emit) async {
      if (state is ClientLoadSuccess) {
        final currentState = state as ClientLoadSuccess;
        emit(ClientLoading());

        try {
          final result = await repo.fetchClients(
            page: event.page,
            pageSize: currentState.pageSize,
            searchQuery: event.currentSearchQuery,
          );

          emit(ClientLoadSuccess(
            clients: result.clients,
            currentPage: result.currentPage,
            totalPages: result.totalPages,
            totalClients: result.totalCount,
            pageSize: currentState.pageSize,
            currentSearchQuery: event.currentSearchQuery,
          ));
        } catch (err) {
          emit(ClientOperationFailure(err.toString()));
        }
      }
    });

    on<AddClient>((event, emit) async {
      emit(ClientLoading());
      try {
        await repo.createClient(
          username: event.username,
          email: event.email,
          password: event.password,
          cin: event.cin,
          tel: event.tel,
          role: event.role,
        );
        emit(ClientAddSuccess());

        // Reload the first page after adding
        final result = await repo.fetchClients(page: 1, pageSize: 8);
        emit(ClientLoadSuccess(
          clients: result.clients,
          currentPage: result.currentPage,
          totalPages: result.totalPages,
          totalClients: result.totalCount,
          pageSize: 8,
        ));
      } catch (err) {
        emit(ClientOperationFailure(err.toString()));
      }
    });

    on<UpdateClientRole>((event, emit) async {
      if (state is ClientLoadSuccess) {
        final currentState = state as ClientLoadSuccess;
        try {
          emit(ClientLoading());
          await repo.updateRole(event.userId, event.newRole);

          final result = await repo.fetchClients(
            page: currentState.currentPage,
            pageSize: currentState.pageSize,
            searchQuery: currentState.currentSearchQuery,
          );

          emit(ClientLoadSuccess(
            clients: result.clients,
            currentPage: result.currentPage,
            totalPages: result.totalPages,
            totalClients: result.totalCount,
            pageSize: currentState.pageSize,
            currentSearchQuery: currentState.currentSearchQuery,
          ));
        } catch (e) {
          emit(ClientOperationFailure(e.toString()));
        }
      }
    });

    on<DeleteClient>((event, emit) async {
      if (state is ClientLoadSuccess) {
        final currentState = state as ClientLoadSuccess;
        emit(ClientLoading());
        try {
          await repo.deleteClient(event.userId);

          // Check if we need to go to previous page after deletion
          int targetPage = currentState.currentPage;
          if (currentState.clients.length == 1 && currentState.currentPage > 1) {
            targetPage = currentState.currentPage - 1;
          }

          final result = await repo.fetchClients(
            page: targetPage,
            pageSize: currentState.pageSize,
            searchQuery: currentState.currentSearchQuery,
          );

          emit(ClientLoadSuccess(
            clients: result.clients,
            currentPage: result.currentPage,
            totalPages: result.totalPages,
            totalClients: result.totalCount,
            pageSize: currentState.pageSize,
            currentSearchQuery: currentState.currentSearchQuery,
          ));
        } catch (err) {
          emit(ClientOperationFailure(err.toString()));
        }
      }
    });
  }
}