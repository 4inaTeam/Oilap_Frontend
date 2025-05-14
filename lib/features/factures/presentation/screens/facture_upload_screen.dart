import 'package:flutter/material.dart';
import 'package:oilab_frontend/shared/widgets/app_layout.dart';
import 'package:oilab_frontend/core/constants/app_colors.dart';

class FactureUploadScreen extends StatelessWidget {
  final List<Map<String, dynamic>> templates = [
    {"title": "Facture d'un client", "icon": Icons.add_circle_outline},
    {"title": "Facture d'achats", "icon": Icons.download},
    {"title": "Facture d'eau", "icon": Icons.download},
    {"title": "Facture d'électricité", "icon": Icons.download},
  ];

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GridView.builder(
          itemCount: templates.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 2,
          ),
          itemBuilder: (context, index) {
            final template = templates[index];

            return SizedBox(
              width: 160,
              height: 200,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // image box
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: Image.asset(
                          'assets/images/invoice.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // footer with title and icon
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.mainColor,
                        borderRadius: const BorderRadius.vertical(
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
                        onTap: () {
                          // Handle upload/download logic here
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
