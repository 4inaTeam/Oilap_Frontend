import 'package:flutter/material.dart';
import 'package:oilab_frontend/shared/widgets/app_layout.dart';
import 'package:oilab_frontend/core/constants/app_colors.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Field controllers
    final clientController = TextEditingController();
    final deliveryModeController = TextEditingController();
    final entryTimeController = TextEditingController();
    final deliveryPriceController = TextEditingController();
    final cityController = TextEditingController();
    final quantityController = TextEditingController();
    final exitTimeController = TextEditingController();
    final totalPriceController = TextEditingController();

    return AppLayout(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Détails de produit',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Télécharger'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // TODO: implement download
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Input grid ─────────────────────────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildLeftColumn(
                          clientController,
                          deliveryModeController,
                          entryTimeController,
                          deliveryPriceController,
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: _buildRightColumn(
                          cityController,
                          quantityController,
                          exitTimeController,
                          totalPriceController,
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildLeftColumn(
                        clientController,
                        deliveryModeController,
                        entryTimeController,
                        deliveryPriceController,
                      ),
                      const SizedBox(height: 16),
                      _buildRightColumn(
                        cityController,
                        quantityController,
                        exitTimeController,
                        totalPriceController,
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 32),

            // ── Status legends ─────────────────────────────────────
            Column(
              children: List.generate(3, (_) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: const [
                      _StatusLegend(
                        dotColor: AppColors.error,
                        label: 'En attente',
                      ),
                      SizedBox(width: 24),
                      _StatusLegend(
                        dotColor: AppColors.success,
                        label: 'En cours',
                      ),
                      SizedBox(width: 24),
                      _StatusLegend(dotColor: Colors.grey, label: 'Fini'),
                      SizedBox(width: 24),
                      _StatusLegend(dotColor: Colors.black, label: 'Livré'),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftColumn(
    TextEditingController client,
    TextEditingController mode,
    TextEditingController entry,
    TextEditingController price,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildField('Nom de client', client),
      const SizedBox(height: 16),
      _buildField('Mode de livraison', mode),
      const SizedBox(height: 16),
      _buildField('Temps d\'entrée', entry),
      const SizedBox(height: 16),
      _buildField('Prix de livraison', price),
    ],
  );

  Widget _buildRightColumn(
    TextEditingController city,
    TextEditingController qty,
    TextEditingController exit,
    TextEditingController total,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildField('Ville', city),
      const SizedBox(height: 16),
      _buildField('Quantité', qty),
      const SizedBox(height: 16),
      _buildField('Sortie', exit),
      const SizedBox(height: 16),
      _buildField('Prix total', total),
    ],
  );

  Widget _buildField(String label, TextEditingController controller) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 14)),
      const SizedBox(height: 4),
      TextField(
        controller: controller,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 12,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ],
  );
}

class _StatusLegend extends StatelessWidget {
  final Color dotColor;
  final String label;
  const _StatusLegend({required this.dotColor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 8, backgroundColor: dotColor),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Container(height: 2, width: 50, color: dotColor),
      ],
    );
  }
}
