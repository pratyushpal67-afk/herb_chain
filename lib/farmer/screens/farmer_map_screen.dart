import 'package:flutter/material.dart';
import '../../theme/app_tokens.dart';
import '../services/location_service.dart';

class FarmerMapScreen extends StatefulWidget {
  const FarmerMapScreen({super.key});

  @override
  State<FarmerMapScreen> createState() => _FarmerMapScreenState();
}

class _FarmerMapScreenState extends State<FarmerMapScreen> {
  LocationResult? _currentLocation;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isLocating = true);

    final result = await LocationService.getCurrentLocation();

    if (!mounted) return;
    setState(() {
      _isLocating = false;
      _currentLocation = result;
    });

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('GPS Locked: ±${result.accuracy.toStringAsFixed(1)}m accuracy'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Error acquiring GPS location'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasFix = _currentLocation?.isSuccess == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Harvest Location & Geotag'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: hasFix ? const Color(0xFFDCFCE7) : AppColors.surfaceSoft,
                    borderRadius: AppRadius.lg,
                    border: Border.all(
                      color: hasFix ? const Color(0xFF86EFAC) : AppColors.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        hasFix ? Icons.check_circle_outline : Icons.location_searching,
                        size: 48,
                        color: hasFix ? const Color(0xFF166534) : AppColors.primary,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        hasFix ? 'GPS Fix Acquired' : 'Searching for Satellites...',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: hasFix ? const Color(0xFF166534) : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasFix
                            ? 'High accuracy coordinates ready for batch minting.'
                            : 'Ensure device GPS is turned on with clear sky view.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall,
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
                              'COLLECTION GEOTAG DATA',
                              style: textTheme.labelSmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: hasFix ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                                borderRadius: AppRadius.sm,
                              ),
                              child: Text(
                                hasFix ? 'LOCKED ✓' : 'STANDBY',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: hasFix ? const Color(0xFF166534) : const Color(0xFFB45309),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildDataRow('Forest / Collection Block', 'Hooghly Forest Block (WB)', textTheme),
                        const Divider(height: AppSpacing.md),
                        _buildDataRow(
                          'Latitude',
                          hasFix ? '${_currentLocation!.latitude.toStringAsFixed(6)}°' : '--',
                          textTheme,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _buildDataRow(
                          'Longitude',
                          hasFix ? '${_currentLocation!.longitude.toStringAsFixed(6)}°' : '--',
                          textTheme,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _buildDataRow(
                          'Accuracy',
                          hasFix ? '±${_currentLocation!.accuracy.toStringAsFixed(1)} m' : '--',
                          textTheme,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton.icon(
                  onPressed: _isLocating ? null : _fetchCurrentLocation,
                  icon: _isLocating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location, color: AppColors.primary),
                  label: Text(_isLocating ? 'ACQUIRING GPS FIX...' : 'RE-CAPTURE CURRENT LOCATION'),
                ),
                const SizedBox(height: AppSpacing.xs),
                ElevatedButton(
                  onPressed: hasFix
                      ? () {
                          Navigator.pop(context, _currentLocation);
                        }
                      : null,
                  child: const Text('CONFIRM HARVEST LOCATION'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildDataRow(String label, String value, TextTheme tt) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: tt.bodySmall),
        Text(value, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}