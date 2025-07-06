import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/features/clients/presentation/bloc/client_bloc.dart';
import 'package:oilab_frontend/features/clients/presentation/bloc/client_event.dart';
import 'package:oilab_frontend/features/clients/presentation/bloc/client_state.dart';

class DataTableCard extends StatefulWidget {
  const DataTableCard({Key? key}) : super(key: key);

  @override
  State<DataTableCard> createState() => _DataTableCardState();
}

class _DataTableCardState extends State<DataTableCard> {
  @override
  void initState() {
    super.initState();
    // Load clients when widget initializes
    context.read<ClientBloc>().add(LoadClients());
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Clients récents',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<ClientBloc, ClientState>(
                builder: (context, state) {
                  if (state is ClientLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ClientLoadSuccess) {
                    if (state.clients.isEmpty) {
                      return const Center(child: Text('No clients found'));
                    }

                    // Get random 5 clients or all if less than 5
                    final clientsToShow = List.from(state.clients);
                    clientsToShow.shuffle();
                    final displayClients = clientsToShow.take(5).toList();

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 24,
                        headingRowHeight: 40,
                        dataRowHeight: 36,
                        columns: const [
                          DataColumn(label: Text('Nom de client')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Actif')),
                        ],
                        rows:
                            displayClients.map((client) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(client.name)),
                                  DataCell(Text(client.email)),
                                  DataCell(
                                    Text(
                                      client.isActive ? 'Active' : 'Inactive',
                                      style: TextStyle(
                                        color:
                                            client.isActive
                                                ? Colors.green
                                                : Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                      ),
                    );
                  }

                  if (state is ClientOperationFailure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[400],
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Error loading clients',
                            style: TextStyle(
                              color: Colors.red[400],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              context.read<ClientBloc>().add(LoadClients());
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Default case
                  return const Center(child: Text('No data available'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
