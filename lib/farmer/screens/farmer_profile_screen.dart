import 'package:flutter/material.dart';
import '../../theme/app_tokens.dart';

class FarmerProfileScreen extends StatelessWidget {
  const FarmerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collector Profile'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: Color(0xFFDCFCE7),
                  child: Icon(Icons.agriculture, size: 36, color: Color(0xFF166534)),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text('Rahul Das', style: textTheme.titleLarge),
                Text('Collector ID: FAR-8921 • Hooghly Block', style: textTheme.bodySmall),
                const SizedBox(height: AppSpacing.md),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        _buildRow('Assigned Block', 'Hooghly Forest Block (WB)', textTheme),
                        const Divider(),
                        _buildRow('Cooperative Node', 'Hooghly Forest SHG #12', textTheme),
                        const Divider(),
                        _buildRow('Registered Species', 'Ashwagandha, Tulsi, Shatavari', textTheme),
                        const Divider(),
                        _buildRow('Trust Score', '99.2% (Tier 1)', textTheme),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildRow(String label, String val, TextTheme tt) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: tt.bodySmall),
        Text(val, style: tt.titleSmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }
}