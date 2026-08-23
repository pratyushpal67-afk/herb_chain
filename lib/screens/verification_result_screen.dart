import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';
import 'traceability_journey_screen.dart';

enum VerificationStatus {
  loading,
  verified,
  pending,
  failed,
  notFound,
}

class VerificationResultScreen extends StatefulWidget {
  final String batchId;
  final VerificationStatus initialStatus;

  const VerificationResultScreen({
    super.key,
    required this.batchId,
    this.initialStatus = VerificationStatus.verified,
  });

  @override
  State<VerificationResultScreen> createState() => _VerificationResultScreenState();
}

class _VerificationResultScreenState extends State<VerificationResultScreen> {
  late VerificationStatus _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.initialStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Result'),
        actions: [
          PopupMenuButton<VerificationStatus>(
            icon: const Icon(Icons.tune, color: AppColors.primary),
            tooltip: 'Preview Status States',
            onSelected: (status) => setState(() => _currentStatus = status),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: VerificationStatus.verified,
                child: Text('🟢 Verified State'),
              ),
              PopupMenuItem(
                value: VerificationStatus.pending,
                child: Text('🟡 Pending State'),
              ),
              PopupMenuItem(
                value: VerificationStatus.failed,
                child: Text('🔴 Failed / Altered State'),
              ),
              PopupMenuItem(
                value: VerificationStatus.notFound,
                child: Text('⚠️ Not Found State'),
              ),
              PopupMenuItem(
                value: VerificationStatus.loading,
                child: Text('🔄 Verifying State'),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: _buildBodyForStatus(context),
        ),
      ),
    );
  }

  Widget _buildBodyForStatus(BuildContext context) {
    switch (_currentStatus) {
      case VerificationStatus.loading:
        return _buildLoadingState(context);
      case VerificationStatus.verified:
        return _buildVerifiedState(context);
      case VerificationStatus.pending:
        return _buildPendingState(context);
      case VerificationStatus.failed:
        return _buildFailedState(context);
      case VerificationStatus.notFound:
        return _buildNotFoundState(context);
    }
  }

  // 1. LOADING / VERIFYING STATE 🔄
  Widget _buildLoadingState(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Verifying Provenance Record...',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Querying decentralized ledger & lab certificate hashes for ${widget.batchId}',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  // 2. VERIFIED STATE 🟢
  Widget _buildVerifiedState(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatusBanner(
            icon: Icons.verified,
            bannerColor: const Color(0xFFDCFCE7),
            borderColor: const Color(0xFF86EFAC),
            iconColor: const Color(0xFF15803D),
            title: 'PRODUCT VERIFIED ✓',
            subtitle: 'Authentic Ayurvedic product with verified provenance.',
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ashwagandha Pure Extract',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Withania somnifera • Root',
                  style: textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BATCH INFORMATION',
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: const BoxDecoration(
                          color: Color(0xFFDCFCE7),
                          borderRadius: AppRadius.sm,
                        ),
                        child: Text(
                          'QUALITY VERIFIED',
                          style: textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF166534),
                            fontWeight: FontWeight.w700,
                            fontSize: 9.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildDataRow('Batch ID', widget.batchId, textTheme),
                  const SizedBox(height: AppSpacing.xs),
                  _buildDataRow('Botanical Origin', 'Hooghly Forest Block (WB)', textTheme),
                  const SizedBox(height: AppSpacing.xs),
                  _buildDataRow('Collection Status', 'Verified ✓', textTheme, valueColor: AppColors.success),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: AppRadius.sm,
                        ),
                        child: const Icon(Icons.science, color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'LABORATORY VERIFIED',
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildDataRow('Laboratory', 'AYUR Quality Central Lab', textTheme),
                  const SizedBox(height: AppSpacing.xs),
                  _buildDataRow('Verified Date', '20 Aug 2026', textTheme),
                  const SizedBox(height: AppSpacing.xs),
                  _buildDataRow('Overall Result', 'PASS ✓', textTheme, valueColor: AppColors.success),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening Full Lab Report (CoA)...')),
              );
            },
            icon: const Icon(Icons.description_outlined, color: AppColors.primary),
            label: const Text('VIEW LAB REPORT'),
          ),
          const SizedBox(height: AppSpacing.sm),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TraceabilityJourneyScreen(batchId: widget.batchId),
                ),
              );
            },
            icon: const Icon(Icons.alt_route),
            label: const Text('TRACE PRODUCT JOURNEY'),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildLedgerFootnote(context, textTheme),
        ],
      ),
    );
  }

  // 3. PENDING STATE 🟡
  Widget _buildPendingState(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatusBanner(
            icon: Icons.hourglass_top,
            bannerColor: const Color(0xFFFEF3C7),
            borderColor: const Color(0xFFFCD34D),
            iconColor: const Color(0xFFB45309),
            title: 'VERIFICATION PENDING ⏳',
            subtitle: 'This batch is recorded but undergoing active laboratory testing.',
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BATCH IN PROGRESS', style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                  const SizedBox(height: AppSpacing.md),
                  _buildDataRow('Batch ID', widget.batchId, textTheme),
                  const SizedBox(height: AppSpacing.xs),
                  _buildDataRow('Harvest Location', 'Hooghly Forest Block (WB)', textTheme),
                  const SizedBox(height: AppSpacing.xs),
                  _buildDataRow('Current Stage', 'Under Quality Analysis', textTheme, valueColor: AppColors.warning),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BACK TO SEARCH'),
          ),
        ],
      ),
    );
  }

  // 4. FAILED / SUSPICIOUS STATE 🔴
  Widget _buildFailedState(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatusBanner(
            icon: Icons.dangerous_outlined,
            bannerColor: const Color(0xFFFEE2E2),
            borderColor: const Color(0xFFFCA5A5),
            iconColor: const Color(0xFFB91C1C),
            title: 'VERIFICATION FAILED ✕',
            subtitle: 'This batch failed quality parameters or provenance checks.',
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('QUALITY FAILURE REASON', style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, color: AppColors.error)),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Heavy metal or pesticide limits exceeded acceptable AYUSH safety thresholds.', style: textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.md),
                  _buildDataRow('Batch ID', widget.batchId, textTheme),
                  const SizedBox(height: AppSpacing.xs),
                  _buildDataRow('Status', 'REJECTED', textTheme, valueColor: AppColors.error),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report submitted to regulatory oversight.')),
              );
            },
            child: const Text('REPORT COUNTERFEIT / ISSUE'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BACK TO SEARCH'),
          ),
        ],
      ),
    );
  }

  // 5. NOT FOUND STATE ⚠️
  Widget _buildNotFoundState(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatusBanner(
            icon: Icons.search_off,
            bannerColor: const Color(0xFFF1F5F9),
            borderColor: const Color(0xFFCBD5E1),
            iconColor: const Color(0xFF475569),
            title: 'BATCH NOT FOUND ⚠️',
            subtitle: 'No records exist on the registry for this Batch identifier.',
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Please double check:', style: textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text('• Check spelling or casing (e.g. ASH-2026-001)', style: textTheme.bodySmall),
                  Text('• Make sure you scanned the genuine QR code', style: textTheme.bodySmall),
                  Text('• Check if your network connection is active', style: textTheme.bodySmall),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('TRY ANOTHER BATCH'),
          ),
        ],
      ),
    );
  }

  static Widget _buildStatusBanner({
    required IconData icon,
    required Color bannerColor,
    required Color borderColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required TextTheme textTheme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
      decoration: BoxDecoration(
        color: bannerColor,
        border: Border.all(color: borderColor),
        borderRadius: AppRadius.md,
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.labelLarge?.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: iconColor.withValues(alpha: 0.9),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDataRow(String label, String value, TextTheme textTheme, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textTheme.bodyMedium),
        Text(
          value,
          style: textTheme.titleSmall?.copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildLedgerFootnote(BuildContext context, TextTheme textTheme) {
    return Center(
      child: InkWell(
        onTap: () => _showLedgerProofModal(context),
        borderRadius: AppRadius.sm,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.link, size: 13, color: AppColors.textSecondary.withValues(alpha: 0.6)),
              const SizedBox(width: 4),
              Text(
                'Ledger record verified',
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.info_outline, size: 12, color: AppColors.textSecondary.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }

  void _showLedgerProofModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final tt = Theme.of(ctx).textTheme;
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Cryptographic Record Proof', style: tt.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              _buildDataRow('Network', 'Polygon PoS Mainnet', tt),
              const SizedBox(height: AppSpacing.xs),
              _buildDataRow('Block Anchor', '#194821', tt),
              const SizedBox(height: AppSpacing.xs),
              _buildDataRow('Tx Hash', '0x8F3A91C2...77E1', tt),
              const SizedBox(height: AppSpacing.xs),
              _buildDataRow('IPFS Report CID', 'QmXoypizjW3WknFiJnKLw...6uco', tt),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }
}