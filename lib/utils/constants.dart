import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF2E7D32);
  static const Color primaryDark = Color(0xFF145218);
  static const Color secondary = Color(0xFF2E7D32);
  static const Color accent = Color(0xFF81C784);
  static const Color background = Color(0xFFF1F8E9);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFC62828);
  static const Color warning = Color(0xFFF57F17);
  static const Color success = Color(0xFF2E7D32);
  static const Color info = Color(0xFF1565C0);
}

class AppConstants {
  static const String appName = 'AYURTRACE';
  static const String appVersion = '1.0.0';
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  static const List<String> userRoles = [
    'FARMER',
    'COLLECTOR',
    'LAB',
    'MANUFACTURER',
    'ADMIN',
    'CUSTOMER',
  ];

  static const List<String> batchStatuses = [
    'pending',
    'recorded',
    'lab_testing',
    'completed',
    'rejected',
  ];

  static const List<String> processingTypes = [
    'drying',
    'grinding',
    'extraction',
    'packaging',
    'other',
  ];

  static const List<String> productTypes = [
    'powder',
    'capsule',
    'tablet',
    'extract',
    'oil',
    'other',
  ];

  static const List<String> eventTypes = [
    'COLLECTION',
    'PROCESSING',
    'LAB',
    'MANUFACTURING',
    'QR_GENERATED',
  ];

  static const Map<String, Color> statusColors = {
    'pending': Colors.orange,
    'recorded': Colors.blue,
    'lab_testing': Colors.purple,
    'completed': Colors.green,
    'rejected': Colors.red,
    'in_progress': Colors.blue,
    'failed': Colors.red,
  };

  static const Map<String, IconData> statusIcons = {
    'pending': Icons.schedule,
    'recorded': Icons.check_circle_outline,
    'lab_testing': Icons.science_outlined,
    'completed': Icons.verified,
    'rejected': Icons.cancel_outlined,
    'in_progress': Icons.sync,
    'failed': Icons.error_outline,
  };
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}