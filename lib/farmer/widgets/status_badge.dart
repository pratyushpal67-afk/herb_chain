import 'package:flutter/material.dart';
import '../../theme/app_tokens.dart';

enum FarmerBatchStatus { verified, pending, rejected }

class FarmerStatusBadge extends StatelessWidget {
  final FarmerBatchStatus status;

  const FarmerStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case FarmerBatchStatus.verified:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF166534);
        label = 'VERIFIED';
        break;
      case FarmerBatchStatus.pending:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        label = 'PENDING';
        break;
      case FarmerBatchStatus.rejected:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        label = 'ACTION REQ.';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.sm,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}