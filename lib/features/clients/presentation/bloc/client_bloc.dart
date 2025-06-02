import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/core/models/product_model.dart';
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

        emit(
          ClientLoadSuccess(
            clients: result.clients,
            currentPage: result.currentPage,
            totalPages: result.totalPages,
            totalClients: result.totalCount,
            pageSize: event.pageSize,
            currentSearchQuery: event.searchQuery,
          ),
        );
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

        emit(
          ClientLoadSuccess(
            clients: result.clients,
            currentPage: result.currentPage,
            totalPages: result.totalPages,
            totalClients: result.totalCount,
            pageSize: event.pageSize,
            currentSearchQuery: event.query,
          ),
        );
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

          emit(
            ClientLoadSuccess(
              clients: result.clients,
              currentPage: result.currentPage,
              totalPages: result.totalPages,
              totalClients: result.totalCount,
              pageSize: currentState.pageSize,
              currentSearchQuery: event.currentSearchQuery,
            ),
          );
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

        final result = await repo.fetchClients(page: 1, pageSize: 8);
        emit(
          ClientLoadSuccess(
            clients: result.clients,
            currentPage: result.currentPage,
            totalPages: result.totalPages,
            totalClients: result.totalCount,
            pageSize: 8,
          ),
        );
      } catch (err) {
        emit(ClientOperationFailure(err.toString()));
      }
    });

    on<UpdateClient>((event, emit) async {
      emit(ClientLoading());
      try {
        await repo.updateClient(
          clientId: event.clientId,
          username: event.username,
          email: event.email,
          cin: event.cin,
          tel: event.tel,
          password: event.password,
        );

        emit(ClientUpdateSuccess());

        if (state is ClientLoadSuccess) {
          final currentState = state as ClientLoadSuccess;
          final result = await repo.fetchClients(
            page: currentState.currentPage,
            pageSize: currentState.pageSize,
            searchQuery: currentState.currentSearchQuery,
          );

          emit(
            ClientLoadSuccess(
              clients: result.clients,
              currentPage: result.currentPage,
              totalPages: result.totalPages,
              totalClients: result.totalCount,
              pageSize: currentState.pageSize,
              currentSearchQuery: currentState.currentSearchQuery,
            ),
          );
        } else {
          final result = await repo.fetchClients(page: 1, pageSize: 8);
          emit(
            ClientLoadSuccess(
              clients: result.clients,
              currentPage: result.currentPage,
              totalPages: result.totalPages,
              totalClients: result.totalCount,
              pageSize: 8,
            ),
          );
        }
      } catch (err) {
        emit(ClientOperationFailure(err.toString()));
      }
    });

    on<GetClientForUpdate>((event, emit) async {
      emit(ClientLoading());
      try {
        final client = await repo.getClientById(event.clientId);
        emit(ClientDetailsLoaded(client));
      } catch (err) {
        emit(ClientOperationFailure(err.toString()));
      }
    });

    on<ViewClientProfile>((event, emit) async {
      emit(ClientLoading());
      try {
        print(
          'ViewClientProfile: Loading profile for client ID: ${event.clientId}',
        );

        // First get the client details
        final client = await repo.getClientById(event.clientId);
        print(
          'ViewClientProfile: Client loaded - ${client.name} (CIN: ${client.cin})',
        );

        // Then get the products
        List<Product> products = [];
        try {
          // Use client.cin as the identifier for products
          products = await repo.getClientProducts(client.cin);
          print(
            'ViewClientProfile: Loaded ${products.length} products for client CIN ${client.cin}',
          );
        } catch (productError) {
          print(
            'ViewClientProfile: Error loading products - ${productError.toString()}',
          );
          // Continue without products rather than failing entirely
        }

        emit(ClientProfileLoaded(client, products: products));
      } catch (err) {
        print('ViewClientProfile: Error - ${err.toString()}');
        emit(
          ClientOperationFailure(
            'Failed to load client profile: ${err.toString()}',
          ),
        );
      }
    });

    on<LoadClientProducts>((event, emit) async {
      try {
        emit(ClientLoading());

        final products = await repo.getClientProducts(event.clientCin);

        emit(ClientProductsLoaded(products));
      } catch (e) {
        emit(
          ClientOperationFailure(
            'Failed to load client products: ${e.toString()}',
          ),
        );
      }
    });

    on<DisactivateClient>((event, emit) async {
      if (state is ClientLoadSuccess) {
        final currentState = state as ClientLoadSuccess;
        emit(ClientLoading());
        try {
          await repo.disactivateClient(event.userId);
          emit(ClientDeactivateSuccess());

          int targetPage = currentState.currentPage;
          if (currentState.clients.length == 1 &&
              currentState.currentPage > 1) {
            targetPage = currentState.currentPage - 1;
          }

          final result = await repo.fetchClients(
            page: targetPage,
            pageSize: currentState.pageSize,
            searchQuery: currentState.currentSearchQuery,
          );

          emit(
            ClientLoadSuccess(
              clients: result.clients,
              currentPage: result.currentPage,
              totalPages: result.totalPages,
              totalClients: result.totalCount,
              pageSize: currentState.pageSize,
              currentSearchQuery: currentState.currentSearchQuery,
            ),
          );
        } catch (err) {
          emit(ClientOperationFailure(err.toString()));
        }
      }
    });
  }

  Future<bool> checkClientExists(String cin) async {
    try {
      final client = await repo.getClientByCin(cin);
      return client != null;
    } catch (e) {
      return false;
    }
  }
}
