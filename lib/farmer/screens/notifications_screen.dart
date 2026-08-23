import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_tokens.dart';

class FarmerNotificationsScreen extends StatelessWidget {
  const FarmerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Alerts & Notices'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.verified, color: AppColors.success),
                  title: Text('Batch #ASH-2026-001 Verified', style: textTheme.titleSmall),
                  subtitle: Text('Laboratory chemical fingerprint analysis completed with 98.4% purity.', style: textTheme.bodySmall),
                  trailing: const Text('2h ago', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.warning_amber, color: AppColors.error),
                  title: Text('Moisture Level Alert', style: textTheme.titleSmall),
                  subtitle: Text('Batch #SHT-2026-003 flagged for excess moisture content. Re-drying requested.', style: textTheme.bodySmall),
                  trailing: const Text('1d ago', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}