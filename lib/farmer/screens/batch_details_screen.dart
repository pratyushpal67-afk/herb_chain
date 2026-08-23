import 'package:flutter/material.dart';
import '../../theme/app_tokens.dart';
import '../widgets/status_badge.dart';

class BatchDetailsScreen extends StatelessWidget {
  final String batchId;

  const BatchDetailsScreen({
    super.key,
    required this.batchId,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Batch $batchId'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('BATCH RECORD', style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w800)),
                            FarmerStatusBadge(status: batchId.startsWith('ASH') ? FarmerBatchStatus.verified : (batchId.startsWith('TUL') ? FarmerBatchStatus.pending : FarmerBatchStatus.rejected)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(batchId.startsWith('ASH') ? 'Ashwagandha Root Extract' : (batchId.startsWith('TUL') ? 'Krishna Tulsi Leaves' : 'Shatavari Tubers'), style: textTheme.titleMedium),
                        Text(batchId.startsWith('ASH') ? 'Withania somnifera • Root' : (batchId.startsWith('TUL') ? 'Ocimum tenuiflorum • Leaves' : 'Asparagus racemosus • Tubers'), style: textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                        const Divider(height: AppSpacing.lg),
                        _buildDetailRow('Collector ID', 'FAR-8921 (Rahul)', textTheme),
                        const SizedBox(height: AppSpacing.xs),
                        _buildDetailRow('Harvest Block', 'Hooghly Forest Block (WB)', textTheme),
                        const SizedBox(height: AppSpacing.xs),
                        _buildDetailRow('Geotag Coords', '22.893421°, 88.396721°', textTheme),
                        const SizedBox(height: AppSpacing.xs),
                        _buildDetailRow('Quantity', '20.0 kg logged', textTheme),
                        const SizedBox(height: AppSpacing.xs),
                        _buildDetailRow('Harvest Date', '20 Aug 2026', textTheme),
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

  static Widget _buildDetailRow(String label, String value, TextTheme tt) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: tt.bodySmall),
        Text(value, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}