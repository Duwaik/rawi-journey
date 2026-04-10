import 'package:flutter/material.dart';

// Phase 2 data model — imported for architecture readiness, not yet used.
// ignore: unused_import
import '../models/map_location.dart';

class LivingMapScreen extends StatelessWidget {
  const LivingMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      body: Center(
        child: Text(
          'The Living Map — Coming Soon',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
