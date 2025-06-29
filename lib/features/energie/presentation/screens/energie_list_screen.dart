import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_layout.dart';

class EnergieScrren extends StatelessWidget {
  const EnergieScrren({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppLayout(
      currentRoute: "/energie",
      child: Center(
        child: Text('Energie List Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
