import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';
import '../farmer/services/location_service.dart';

class RegisterHarvestBatchScreen extends StatefulWidget {
  const RegisterHarvestBatchScreen({super.key});

  @override
  State<RegisterHarvestBatchScreen> createState() => _RegisterHarvestBatchScreenState();
}

class _RegisterHarvestBatchScreenState extends State<RegisterHarvestBatchScreen> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, String> _speciesBotanicalMap = const {
    'Ashwagandha': 'Withania somnifera • Root',
    'Krishna Tulsi': 'Ocimum tenuiflorum • Leaves',
    'Shatavari': 'Asparagus racemosus • Tubers',
    'Brahmi': 'Bacopa monnieri • Whole Plant',
    'Guduchi / Giloy': 'Tinospora cordifolia • Stem',
    'Amla': 'Phyllanthus emblica • Fruit',
  };

  late String _selectedCrop;
  final TextEditingController _weightController = TextEditingController(text: '20.0');
  String _selectedUnit = 'kg';
  DateTime _selectedDate = DateTime(2026, 8, 23);

  LocationResult? _capturedLocation;
  bool _isCapturingGps = false;
  final String _defaultLocationAddress = 'Hooghly Forest Block, West Bengal, India';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedCrop = _speciesBotanicalMap.keys.first;
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _captureLocation() async {
    setState(() => _isCapturingGps = true);

    final loc = await LocationService.getCurrentLocation();

    if (!mounted) return;
    setState(() {
      _isCapturingGps = false;
      _capturedLocation = loc;
    });

    if (loc.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'GPS Captured: ${loc.latitude.toStringAsFixed(4)}°, ${loc.longitude.toStringAsFixed(4)}° (±${loc.accuracy.toStringAsFixed(1)}m)',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.errorMessage ?? 'GPS not available. Using block default.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _submitBatch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 8),
            Text('Batch Registered!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Harvest record signed and registered successfully.'),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: const BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: AppRadius.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Batch ID: ASH-2026-005', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('Crop: $_selectedCrop (${_weightController.text} $_selectedUnit)', style: const TextStyle(fontSize: 11)),
                  const SizedBox(height: 2),
                  const Text('Status: PENDING LAB TEST', style: TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('BACK TO DASHBOARD'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasFix = _capturedLocation?.isSuccess == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Harvest Batch'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Section 1: Crop Information Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('1. CROP INFORMATION', style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w800)),
                          const SizedBox(height: AppSpacing.sm),
                          Text('Plant / Crop Name', style: textTheme.labelMedium),
                          const SizedBox(height: AppSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSoft,
                              borderRadius: AppRadius.md,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedCrop,
                                items: _speciesBotanicalMap.keys.map((herb) {
                                  return DropdownMenuItem(value: herb, child: Text(herb, style: textTheme.titleSmall));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedCrop = val);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _speciesBotanicalMap[_selectedCrop] ?? '',
                            style: textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: AppColors.primary),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          Text('Quantity Harvested', style: textTheme.labelMedium),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: _weightController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: textTheme.titleMedium,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.scale, color: AppColors.primary, size: 20),
                                    hintText: '20.0',
                                  ),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter quantity' : null,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceSoft,
                                    borderRadius: AppRadius.md,
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedUnit,
                                      isExpanded: true,
                                      items: const [
                                        DropdownMenuItem(value: 'kg', child: Text('kg')),
                                        DropdownMenuItem(value: 'quintal', child: Text('quintal')),
                                        DropdownMenuItem(value: 'ton', child: Text('ton')),
                                      ],
                                      onChanged: (v) => setState(() => _selectedUnit = v!),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),

                          Text('Harvest Date', style: textTheme.labelMedium),
                          const SizedBox(height: AppSpacing.xs),
                          InkWell(
                            onTap: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2025),
                                lastDate: DateTime(2027),
                              );
                              if (d != null) setState(() => _selectedDate = d);
                            },
                            borderRadius: AppRadius.md,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSoft,
                                borderRadius: AppRadius.md,
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${_selectedDate.day} Aug ${_selectedDate.year}', style: textTheme.titleSmall),
                                  const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Section 2: Harvest Location Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('2. HARVEST LOCATION 📍', style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w800)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: hasFix ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                                  borderRadius: AppRadius.sm,
                                ),
                                child: Text(
                                  hasFix ? 'GPS LOCKED ✓' : 'DEFAULT BLOCK',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: hasFix ? const Color(0xFF166534) : const Color(0xFFB45309),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          // Responsive Geofence Map Viewport
                          ClipRRect(
                            borderRadius: AppRadius.md,
                            child: Container(
                              height: 180,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Stack(
                                children: [
                                  CustomPaint(
                                    size: const Size(double.infinity, 180),
                                    painter: _MapGridPainter(),
                                  ),
                                  Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: AppRadius.sm,
                                            boxShadow: [
                                              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                            ],
                                          ),
                                          child: Text(
                                            hasFix ? 'Harvest Location Locked' : 'Default Forest Block',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.location_on,
                                          color: AppColors.primary,
                                          size: 38,
                                        ),
                                        Container(
                                          width: 14,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    left: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        borderRadius: AppRadius.sm,
                                        border: Border.all(color: AppColors.border),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.satellite_alt,
                                            size: 11,
                                            color: hasFix ? AppColors.success : AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            hasFix ? 'GPS Active' : 'Offline Mode',
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          Text(_defaultLocationAddress, style: textTheme.titleSmall),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Coordinates', style: textTheme.bodySmall),
                              Text(
                                hasFix
                                    ? '${_capturedLocation!.latitude.toStringAsFixed(6)}°, ${_capturedLocation!.longitude.toStringAsFixed(6)}°'
                                    : '22.879793°, 88.363842°',
                                style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          OutlinedButton.icon(
                            onPressed: _isCapturingGps ? null : _captureLocation,
                            icon: _isCapturingGps
                                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.my_location, color: AppColors.primary, size: 18),
                            label: Text(_isCapturingGps ? 'ACQUIRING GPS LOCK...' : 'USE MY CURRENT LOCATION'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Section 3: Submit Action
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitBatch,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('REGISTER HARVEST BATCH'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.5)
      ..strokeWidth = 1.0;

    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}