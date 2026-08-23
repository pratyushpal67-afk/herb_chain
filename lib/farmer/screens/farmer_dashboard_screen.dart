import 'package:flutter/material.dart';
import '../../theme/app_tokens.dart';
import '../widgets/farmer_batch_card.dart';
import '../widgets/status_badge.dart';
import 'add_batch_screen.dart';
import 'my_batches_screen.dart';
import 'batch_details_screen.dart';
import 'notifications_screen.dart';
import 'farmer_profile_screen.dart';

class FarmerDashboardScreen extends StatelessWidget {
  const FarmerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxs + 2),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: AppRadius.sm,
              ),
              child: const Icon(Icons.agriculture, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: AppSpacing.xs),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AYURTRACE FIELD',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Collector & Farm Portal',
                  style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
            tooltip: 'Field Alerts',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FarmerNotificationsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.textPrimary),
            tooltip: 'Collector Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FarmerProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => await Future.delayed(const Duration(milliseconds: 500)),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Good morning, Rahul 👋', style: textTheme.titleLarge),
                          const SizedBox(height: 2),
                          Text('Hooghly Forest Block (WB)', style: textTheme.bodySmall),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const FarmerProfileScreen()),
                          );
                        },
                        borderRadius: AppRadius.full,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: AppRadius.full,
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          child: Text(
                            'ID: FAR-8921',
                            style: textTheme.labelSmall?.copyWith(
                              color: const Color(0xFF166534),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      _buildMetricCard(
                        '12',
                        'Total Batches',
                        AppColors.primary,
                        textTheme,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MyBatchesScreen()),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _buildMetricCard(
                        '8',
                        'Lab Verified',
                        AppColors.success,
                        textTheme,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MyBatchesScreen()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      _buildMetricCard(
                        '3',
                        'Tests Pending',
                        AppColors.warning,
                        textTheme,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MyBatchesScreen()),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _buildMetricCard(
                        '1',
                        'Rejected / Action',
                        AppColors.error,
                        textTheme,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MyBatchesScreen()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddBatchScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('REGISTER NEW HARVEST BATCH'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Batches', style: textTheme.titleMedium),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MyBatchesScreen()),
                          );
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
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
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildMetricCard(
    String value,
    String label,
    Color color,
    TextTheme tt, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.md,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.md,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: tt.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: tt.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}