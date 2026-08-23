import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'farmer/screens/farmer_dashboard_screen.dart';

void main() {
  runApp(const AyurTraceFarmerApp());
}

class AyurTraceFarmerApp extends StatelessWidget {
  const AyurTraceFarmerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AYURTRACE FIELD • Farmer Portal',
      theme: AppTheme.lightTheme,
      home: const FarmerDashboardScreen(),
    );
  }
}