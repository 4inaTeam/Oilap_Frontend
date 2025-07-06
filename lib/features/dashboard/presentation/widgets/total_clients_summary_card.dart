import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/features/clients/presentation/bloc/client_bloc.dart';
import 'package:oilab_frontend/features/clients/presentation/bloc/client_event.dart';
import 'package:oilab_frontend/features/clients/presentation/bloc/client_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/summary_card.dart';

class TotalClientsSummaryCard extends StatefulWidget {
  final double? width;

  const TotalClientsSummaryCard({Key? key, this.width}) : super(key: key);

  @override
  State<TotalClientsSummaryCard> createState() =>
      _TotalClientsSummaryCardState();
}

class _TotalClientsSummaryCardState extends State<TotalClientsSummaryCard> {
  @override
  void initState() {
    super.initState();
    context.read<ClientBloc>().add(LoadTotalClients());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientBloc, ClientState>(
      builder: (context, state) {
        String value = '-';
        String change = '+11.01%';
        Color color = AppColors.greenLight;

        if (state is TotalClientsLoaded) {
          value = state.totalClients.toString();
          color = AppColors.greenLight;
        } else if (state is ClientLoading) {
          value = '...';
          change = '...';
          color = AppColors.greenLight;
        } else if (state is ClientOperationFailure) {
          value = 'Error';
          change = '';
          color = Colors.red;
        } else if (state is ClientLoadSuccess) {
          value = state.totalClients.toString();
          color = AppColors.greenLight;
        }

        return GestureDetector(
          onTap: () {
            context.read<ClientBloc>().add(LoadTotalClients());
          },
          child: SummaryCard(
            title: 'Clients',
            value: value,
            change: change,
            color: color,
            width: widget.width ?? 200.0,
          ),
        );
      },
    );
  }
}
