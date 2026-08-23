import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_tokens.dart';
import '../services/location_service.dart';

class AddBatchScreen extends StatefulWidget {
  const AddBatchScreen({super.key});

  @override
  State<AddBatchScreen> createState() => _AddBatchScreenState();
}

class _AddBatchScreenState extends State<AddBatchScreen> {
  int _currentStep = 0;
  bool _isSubmitting = false;

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
  final String _locationAddress = 'Hooghly Forest Block, West Bengal, India';

  final List<String> _attachedPhotos = [
    'Specimen_Root_01.jpg',
    'Field_Collection_Tag.jpg',
  ];

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

  Future<void> _captureCurrentLocation() async {
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
          content: Text('GPS Fix Acquired: ±${loc.accuracy.toStringAsFixed(1)}m accuracy'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.errorMessage ?? 'Unable to acquire GPS fix'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handleNext() {
    if (_currentStep == 0) {
      if (_weightController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter harvest quantity')),
        );
        return;
      }
    }
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _submitHarvestBatch();
    }
  }

  void _handleBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _submitHarvestBatch() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.verified, color: AppColors.success),
            SizedBox(width: 8),
            Text('Batch Registered!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your harvest batch record is cryptographically logged.'),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: const BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: AppRadius.sm,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Assigned Batch ID: ASH-2026-005', style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(height: 2),
                  Text('Initial Status: PENDING LAB TEST', style: TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.w700)),
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

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Register Harvest Batch', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(
              'Step ${_currentStep + 1} of 4 • ${_getStepTitle(_currentStep)}',
              style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (_currentStep + 1) / 4,
                minHeight: 4,
                backgroundColor: AppColors.surfaceSoft,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: _buildCurrentStepContent(textTheme),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border, width: 1)),
                ),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSubmitting ? null : _handleBack,
                          child: const Text('BACK'),
                        ),
                      )
                    else
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('CANCEL'),
                        ),
                      ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _handleNext,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(_currentStep == 3 ? 'LOG BATCH ON LEDGER' : 'NEXT STEP →'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Crop & Harvest Info';
      case 1:
        return 'Geotag Location';
      case 2:
        return 'Specimen Photos';
      case 3:
        return 'Review & Submit';
      default:
        return '';
    }
  }

  Widget _buildCurrentStepContent(TextTheme tt) {
    switch (_currentStep) {
      case 0:
        return _buildCropInfoStep(tt);
      case 1:
        return _buildLocationStep(tt);
      case 2:
        return _buildPhotosStep(tt);
      case 3:
        return _buildReviewStep(tt);
      default:
        return const SizedBox.shrink();
    }
  }

  // STEP 1: CROP & HARVEST INFO
  Widget _buildCropInfoStep(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Herb / Botanical Species', style: tt.labelMedium),
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
                        return DropdownMenuItem(
                          value: herb,
                          child: Text(herb, style: tt.titleSmall),
                        );
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
                  style: tt.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Quantity Harvested', style: tt.labelMedium),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: tt.titleMedium,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.scale, color: AppColors.primary, size: 20),
                          hintText: '20.0',
                        ),
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
                Text('Harvest Date', style: tt.labelMedium),
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
                        Text('${_selectedDate.day} Aug ${_selectedDate.year}', style: tt.titleSmall),
                        const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // STEP 2: GEOTAG LOCATION
  Widget _buildLocationStep(TextTheme tt) {
    final hasFix = _capturedLocation?.isSuccess == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 190,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: AppRadius.lg,
            border: Border.all(color: AppColors.border, width: 1.2),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, size: 42, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                    const SizedBox(height: 4),
                    Text(
                      'Google Maps Geofence View',
                      style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (hasFix)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: AppRadius.sm,
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        child: const Text('Harvest Point', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                      const Icon(Icons.location_on, color: AppColors.primary, size: 36),
                    ],
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
                    Text('HARVEST ORIGIN', style: tt.labelSmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w800)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: hasFix ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                        borderRadius: AppRadius.sm,
                      ),
                      child: Text(
                        hasFix ? 'GPS LOCKED ✓' : 'AWAITING FIX',
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
                Text(_locationAddress, style: tt.titleSmall),
                const SizedBox(height: AppSpacing.md),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.sm),
                _buildCoordsRow('Latitude', hasFix ? '${_capturedLocation!.latitude.toStringAsFixed(6)}°' : '22.893421° (Hooghly)', tt),
                const SizedBox(height: AppSpacing.xxs),
                _buildCoordsRow('Longitude', hasFix ? '${_capturedLocation!.longitude.toStringAsFixed(6)}°' : '88.396721° (WB)', tt),
                const SizedBox(height: AppSpacing.xxs),
                _buildCoordsRow('GPS Accuracy', hasFix ? '±${_capturedLocation!.accuracy.toStringAsFixed(1)} m' : '±8.2 m (Default Fix)', tt),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: _isCapturingGps ? null : _captureCurrentLocation,
          icon: _isCapturingGps
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.my_location, color: AppColors.primary),
          label: Text(_isCapturingGps ? 'ACQUIRING GPS LOCK...' : 'RE-CAPTURE CURRENT LOCATION'),
        ),
      ],
    );
  }

  static Widget _buildCoordsRow(String label, String value, TextTheme tt) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: tt.bodySmall),
        Text(value, style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }

  // STEP 3: SPECIMEN PHOTOS
  Widget _buildPhotosStep(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Specimen & Weight Evidence', style: tt.titleSmall),
                const SizedBox(height: 2),
                Text('Upload geotagged photos of the harvest lot and weighing scale.', style: tt.bodySmall),
                const SizedBox(height: AppSpacing.md),
                ..._attachedPhotos.map((photo) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      borderRadius: AppRadius.sm,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.image, color: AppColors.primary, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(photo, style: tt.titleSmall?.copyWith(fontSize: 13)),
                              const Text('23 Aug 2026 • Geotagged • 2.4 MB', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _attachedPhotos.add('Field_Sample_${_attachedPhotos.length + 1}.jpg');
                    });
                  },
                  icon: const Icon(Icons.camera_alt_outlined, color: AppColors.accent),
                  label: const Text('ATTACH HARVEST PHOTO'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // STEP 4: REVIEW & SUBMIT
  Widget _buildReviewStep(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BATCH SPECIFICATION', style: tt.labelSmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w800)),
                const SizedBox(height: AppSpacing.sm),
                _buildCoordsRow('Crop Species', _selectedCrop, tt),
                const SizedBox(height: AppSpacing.xs),
                _buildCoordsRow('Botanical Subtype', _speciesBotanicalMap[_selectedCrop] ?? '', tt),
                const SizedBox(height: AppSpacing.xs),
                _buildCoordsRow('Harvest Quantity', '${_weightController.text} $_selectedUnit', tt),
                const SizedBox(height: AppSpacing.xs),
                _buildCoordsRow('Harvest Date', '${_selectedDate.day} Aug ${_selectedDate.year}', tt),
                const SizedBox(height: AppSpacing.sm),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.sm),
                Text('ORIGIN & PROVENANCE', style: tt.labelSmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w800)),
                const SizedBox(height: AppSpacing.sm),
                _buildCoordsRow('Collector ID', 'FAR-8921 (Rahul Das)', tt),
                const SizedBox(height: AppSpacing.xs),
                _buildCoordsRow('Location Block', 'Hooghly Forest Block (WB)', tt),
                const SizedBox(height: AppSpacing.xs),
                _buildCoordsRow('GPS Coordinates', '22.893421°, 88.396721°', tt),
                const SizedBox(height: AppSpacing.xs),
                _buildCoordsRow('Evidence Attached', '${_attachedPhotos.length} Geotagged Photos', tt),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: AppRadius.md,
            border: Border.all(color: const Color(0xFF86EFAC)),
          ),
          child: Row(
            children: [
              const Icon(Icons.shield_outlined, color: Color(0xFF166534), size: 20),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Logging will mint a signed genesis provenance hash and trigger laboratory dispatch.',
                  style: tt.bodySmall?.copyWith(color: const Color(0xFF166534), fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}