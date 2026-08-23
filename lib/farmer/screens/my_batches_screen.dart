import 'package:flutter/material.dart';
import '../../theme/app_tokens.dart';
import '../widgets/farmer_batch_card.dart';
import '../widgets/status_badge.dart';
import 'batch_details_screen.dart';

class MyBatchesScreen extends StatelessWidget {
  const MyBatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Harvest Batches'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              FarmerBatchCard(
                batchId: 'ASH-2026-001',
                herbName: 'Ashwagandha Root Extract',
                botanicalName: 'Withania somnifera',
                weight: '20.0 kg logged',
                harvestDate: '20 Aug 2026',
                status: FarmerBatchStatus.verified,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BatchDetailsScreen(batchId: 'ASH-2026-001'),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xs),
              FarmerBatchCard(
                batchId: 'TUL-2026-004',
                herbName: 'Krishna Tulsi Leaves',
                botanicalName: 'Ocimum tenuiflorum',
                weight: '15.5 kg logged',
                harvestDate: '22 Aug 2026',
                status: FarmerBatchStatus.pending,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BatchDetailsScreen(batchId: 'TUL-2026-004'),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xs),
              FarmerBatchCard(
                batchId: 'SHT-2026-003',
                herbName: 'Shatavari Tubers',
                botanicalName: 'Asparagus racemosus',
                weight: '18.0 kg logged',
                harvestDate: '14 Aug 2026',
                status: FarmerBatchStatus.rejected,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BatchDetailsScreen(batchId: 'SHT-2026-003'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}