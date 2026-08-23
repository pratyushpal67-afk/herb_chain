import 'package:flutter/material.dart';
import '../../theme/app_tokens.dart';
import 'status_badge.dart';

class FarmerBatchCard extends StatelessWidget {
  final String batchId;
  final String herbName;
  final String botanicalName;
  final String weight;
  final String harvestDate;
  final FarmerBatchStatus status;
  final VoidCallback onTap;

  const FarmerBatchCard({
    super.key,
    required this.batchId,
    required this.herbName,
    required this.botanicalName,
    required this.weight,
    required this.harvestDate,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.md,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    batchId,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  FarmerStatusBadge(status: status),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(herbName, style: textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(
                botanicalName,
                style: textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
              const Divider(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.scale, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(weight, style: textTheme.bodySmall),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 13, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(harvestDate, style: textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}