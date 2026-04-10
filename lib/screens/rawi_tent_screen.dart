import 'package:flutter/material.dart';

class RawiTentScreen extends StatelessWidget {
  const RawiTentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      body: Center(
        child: Text(
          "The Rawi's Tent — Coming Soon",
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
