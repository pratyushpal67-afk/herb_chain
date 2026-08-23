import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';

class JourneyEventModel {
  final String stageNumber;
  final String title;
  final String description;
  final String location;
  final String timestamp;
  final IconData icon;
  final bool isCompleted;

  const JourneyEventModel({
    required this.stageNumber,
    required this.title,
    required this.description,
    required this.location,
    required this.timestamp,
    required this.icon,
    this.isCompleted = true,
  });
}

class TraceabilityJourneyScreen extends StatelessWidget {
  final String batchId;

  const TraceabilityJourneyScreen({
    super.key,
    required this.batchId,
  });

  static const List<JourneyEventModel> sampleEvents = [
    JourneyEventModel(
      stageNumber: '01',
      title: 'Botanical Harvest Geotagged',
      description: 'Raw Ashwagandha root collected by verified farmer Rahul Das. Specimen photographed and weight logged (20.0 kg).',
      location: 'Hooghly Forest Block, West Bengal',
      timestamp: '20 Aug 2026 • 09:30 AM',
      icon: Icons.eco,
    ),
    JourneyEventModel(
      stageNumber: '02',
      title: 'Primary Processing & Solar Drying',
      description: 'Roots sorted, washed, and dried under monitored solar hygiene conditions.',
      location: 'Regional Processing Facility #1',
      timestamp: '20 Aug 2026 • 02:15 PM',
      icon: Icons.wb_sunny_outlined,
    ),
    JourneyEventModel(
      stageNumber: '03',
      title: 'Laboratory Quality Certification',
      description: 'Passed species authentication (Withania somnifera), heavy metal screens, and purity tests (CoA #LAB-2026-0001).',
      location: 'AYUR Quality Central Lab',
      timestamp: '21 Aug 2026 • 11:00 AM',
      icon: Icons.science,
    ),
    JourneyEventModel(
      stageNumber: '04',
      title: 'Standardized Extraction & Formulation',
      description: 'Processed into pure standardized extract powder and hermetically packaged under AYUSH GMP compliance.',
      location: 'ABC Ayurveda Ltd. (Hooghly Facility)',
      timestamp: '21 Aug 2026 • 04:45 PM',
      icon: Icons.precision_manufacturing_outlined,
    ),
    JourneyEventModel(
      stageNumber: '05',
      title: 'Cryptographic QR Generation & Ledger Lock',
      description: 'Provenance dataset signed and anchored with immutable QR code identifier.',
      location: 'Packaging Line 3',
      timestamp: '22 Aug 2026 • 10:00 AM',
      icon: Icons.qr_code_2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Product Journey',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(
              'Batch #$batchId',
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Journey Summary Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Batch #$batchId', style: textTheme.titleMedium),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: const BoxDecoration(
                                color: Color(0xFFDCFCE7),
                                borderRadius: AppRadius.sm,
                              ),
                              child: Text(
                                '5/5 STAGES COMPLETE',
                                style: textTheme.labelSmall?.copyWith(
                                  color: const Color(0xFF166534),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'End-to-end provenance timeline from field collection to finished product.',
                          style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Vertical Timeline
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sampleEvents.length,
                  itemBuilder: (context, index) {
                    final event = sampleEvents[index];
                    final isLast = index == sampleEvents.length - 1;
                    return _buildTimelineItem(context, event, isLast, textTheme);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('BACK TO VERIFICATION'),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    JourneyEventModel event,
    bool isLast,
    TextTheme textTheme,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: event.isCompleted ? AppColors.primary : AppColors.surfaceSoft,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: event.isCompleted ? AppColors.primaryDark : AppColors.border,
                    width: 2,
                  ),
                ),
                child: Icon(
                  event.icon,
                  size: 16,
                  color: event.isCompleted ? AppColors.white : AppColors.textSecondary,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.primaryLight,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'STAGE ${event.stageNumber}',
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            event.timestamp,
                            style: textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.title,
                        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.description,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location,
                              style: textTheme.labelSmall?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}