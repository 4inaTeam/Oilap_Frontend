import 'package:flutter/material.dart';
import 'package:oilab_frontend/features/bills/presentation/screens/bill_add_dialog.dart';
import 'package:oilab_frontend/shared/widgets/app_layout.dart';
import 'package:oilab_frontend/core/constants/app_colors.dart';

class FactureUploadScreen extends StatelessWidget {
  final List<Map<String, dynamic>> templates = [
    {
      "title": "Facture d'un client",
      "icon": Icons.add_circle_outline,
      "category": "purchase",
    },
    {
      "title": "Facture d'achats",
      "icon": Icons.shopping_cart,
      "category": "purchase",
    },
    {"title": "Facture d'eau", "icon": Icons.water_drop, "category": "water"},
    {
      "title": "Facture d'électricité",
      "icon": Icons.electric_bolt,
      "category": "electricity",
    },
  ];

  void _openBillDialog(BuildContext context, [String? preselectedCategory]) {
    showDialog(
      context: context,
      builder:
          (context) => BillAddDialog(preselectedCategory: preselectedCategory),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Ajouter', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mainColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => _openBillDialog(context),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/invoice.png',
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(0.2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                templates
                    .map(
                      (template) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mainColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed:
                                () => _openBillDialog(
                                  context,
                                  template['category'],
                                ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  template['title'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(template['icon'], color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return AppLayout(
      currentRoute: '/factures/entreprise/ajouter',
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child:
                    isMobile
                        ? _buildMobileLayout(context)
                        : Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: templates.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.3,
                                ),
                            itemBuilder: (context, index) {
                              final template = templates[index];

                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 3,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Image.asset(
                                          'assets/images/invoice.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.mainColor,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              bottom: Radius.circular(16),
                                            ),
                                      ),
                                      child: ListTile(
                                        dense: true,
                                        title: Text(
                                          template['title'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        trailing: Icon(
                                          template['icon'],
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        onTap:
                                            () => _openBillDialog(
                                              context,
                                              template['category'],
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
