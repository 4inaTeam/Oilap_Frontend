/*import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:oilab_frontend/shared/widgets/app_layout.dart';
import 'package:oilab_frontend/core/constants/app_colors.dart';
import 'package:oilab_frontend/core/models/facture_model.dart';
import '../bloc/facture_bloc.dart';
import '../bloc/facture_event.dart';
import '../bloc/facture_state.dart';

class FactureDetailScreen extends StatefulWidget {
  final int factureId;
  final Facture facture;

  const FactureDetailScreen({
    super.key,
    required this.factureId,
    required this.facture,
  });

  @override
  State<FactureDetailScreen> createState() => _FactureDetailScreenState();
}

class _FactureDetailScreenState extends State<FactureDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FactureBloc>().add(GetFacturePdf(widget.factureId));
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () {},
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.payment, color: Colors.white),
                  label: const Text('Payer', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download, color: Colors.white),
                  label: const Text('Télécharger', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            BlocBuilder<FactureBloc, FactureState>(
              builder: (context, state) {
                if (state is FactureLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is FactureError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed:
                              () => context.read<FactureBloc>().add(
                                GetFacturePdf(widget.factureId),
                              ),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is FacturePdfLoaded) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SfPdfViewer.network(
                      state.pdfUrl,
                      onDocumentLoadFailed: (details) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error loading PDF: ${details.error}',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }

                return const Center(
                  child: Text(
                    'Une erreur s\'est produite lors du chargement du PDF',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
*/