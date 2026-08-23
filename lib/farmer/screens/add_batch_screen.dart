import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_tokens.dart';
import '../services/location_service.dart';

class AddBatchScreen extends StatefulWidget {
  const AddBatchScreen({super.key});

  @override
  State<AddBatchScreen> createState() => _AddBatchScreenState();
}

class _AddBatchScreenState extends State<AddBatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _weightController = TextEditingController(text: '20.0');
  final TextEditingController _locationNameController =
      TextEditingController(text: 'Hooghly Forest Block, West Bengal, India');

  String _selectedHerb = 'Ashwagandha';
  String _selectedUnit = 'kg';
  DateTime _harvestDate = DateTime(2026, 8, 23);

  double _latitude = 22.879793;
  double _longitude = 88.363842;
  bool _isLocating = false;
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  Uint8List? _imageBytes;

  final List<Map<String, String>> _herbSpecies = [
    {'name': 'Ashwagandha', 'scientific': 'Withania somnifera • Root'},
    {'name': 'Krishna Tulsi', 'scientific': 'Ocimum tenuiflorum • Leaves'},
    {'name': 'Shatavari', 'scientific': 'Asparagus racemosus • Tubers'},
    {'name': 'Brahmi', 'scientific': 'Bacopa monnieri • Whole Plant'},
    {'name': 'Amla', 'scientific': 'Phyllanthus emblica • Fruit'},
  ];

  @override
  void dispose() {
    _weightController.dispose();
    _locationNameController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _pickedImage = file;
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _acquireGpsLocation() async {
    setState(() => _isLocating = true);

    final result = await LocationService.getCurrentLocation();

    if (!mounted) return;
    setState(() => _isLocating = false);

    if (result.isSuccess) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('GPS Coordinates acquired (±${result.accuracy.toStringAsFixed(1)}m)'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Error retrieving device location'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _selectHarvestDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _harvestDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2027),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _harvestDate) {
      setState(() => _harvestDate = picked);
    }
  }

  Future<void> _submitHarvestBatch() async {
    if (!_formKey.currentState!.validate()) return;

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
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 8),
            Text('Batch Registered'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Harvest record logged successfully.'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: const BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: AppRadius.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Batch ID: ASH-2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text('Species: $_selectedHerb'),
                  Text('Quantity: ${_weightController.text.trim()} $_selectedUnit'),
                  Text('Geotag: ${_latitude.toStringAsFixed(6)}°, ${_longitude.toStringAsFixed(6)}°'),
                  if (_pickedImage != null)
                    const Text('Geotagged Photo: Attached ✓',
                        style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
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
            child: const Text('DONE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currentScientific = _herbSpecies.firstWhere(
      (h) => h['name'] == _selectedHerb,
      orElse: () => {'scientific': ''},
    )['scientific']!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Harvest Batch'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. HERB DETAILS CARD
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Herb Species', style: textTheme.labelMedium),
                          const SizedBox(height: AppSpacing.xs),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedHerb,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(borderRadius: AppRadius.md),
                            ),
                            items: _herbSpecies.map((h) {
                              return DropdownMenuItem<String>(
                                value: h['name'],
                                child: Text(h['name']!, style: textTheme.titleSmall),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedHerb = val);
                            },
                          ),
                          const SizedBox(height: AppSpacing.xxs + 2),
                          Text(
                            currentScientific,
                            style: textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: AppColors.textSecondary,
                            ),
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
                                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.scale, color: AppColors.primary, size: 20),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    border: OutlineInputBorder(borderRadius: AppRadius.md),
                                  ),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter quantity' : null,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  initialValue: _selectedUnit,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    border: OutlineInputBorder(borderRadius: AppRadius.md),
                                  ),
                                  items: ['kg', 'quintal', 'g'].map((u) {
                                    return DropdownMenuItem(value: u, child: Text(u, style: textTheme.titleSmall));
                                  }).toList(),
                                  onChanged: (u) {
                                    if (u != null) setState(() => _selectedUnit = u);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text('Harvest Date', style: textTheme.labelMedium),
                          const SizedBox(height: AppSpacing.xs),
                          InkWell(
                            onTap: _selectHarvestDate,
                            borderRadius: AppRadius.md,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSoft,
                                borderRadius: AppRadius.md,
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${_harvestDate.day.toString().padLeft(2, '0')} Aug ${_harvestDate.year}',
                                    style: textTheme.titleSmall,
                                  ),
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

                  // 2. HARVEST LOCATION / GEOTAG CARD
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Harvest Location 📍', style: textTheme.labelMedium),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFEF3C7),
                                  borderRadius: AppRadius.sm,
                                ),
                                child: const Text(
                                  'DEFAULT BLOCK',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFB45309)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Container(
                            height: 110,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: AppRadius.md,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      borderRadius: AppRadius.sm,
                                    ),
                                    child: const Text('Offline Map Layer', style: TextStyle(fontSize: 10)),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: AppRadius.sm,
                                      ),
                                      child: const Text(
                                        'Default Forest Block',
                                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    const Icon(Icons.location_on, color: AppColors.primary, size: 28),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(_locationNameController.text, style: textTheme.titleSmall),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Coordinates', style: textTheme.bodySmall),
                              Text(
                                '${_latitude.toStringAsFixed(6)}°, ${_longitude.toStringAsFixed(6)}°',
                                style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          OutlinedButton.icon(
                            onPressed: _isLocating ? null : _acquireGpsLocation,
                            icon: _isLocating
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.my_location, size: 18),
                            label: Text(_isLocating ? 'ACQUIRING GPS...' : 'USE MY CURRENT LOCATION'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 3. UPLOAD HARVEST PHOTO CARD
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Harvest Geotagged Proof', style: textTheme.labelMedium),
                          const SizedBox(height: AppSpacing.xs),
                          InkWell(
                            onTap: _pickPhoto,
                            borderRadius: AppRadius.md,
                            child: Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSoft,
                                borderRadius: AppRadius.md,
                                border: Border.all(color: AppColors.border),
                              ),
                              child: _imageBytes != null
                                  ? ClipRRect(
                                      borderRadius: AppRadius.md,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.memory(
                                            _imageBytes!,
                                            fit: BoxFit.cover,
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: const BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.edit, size: 16, color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.add_a_photo_outlined, size: 36, color: AppColors.primary),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text('Upload Harvest Photo / Certificate', style: textTheme.titleSmall),
                                        const SizedBox(height: 2),
                                        Text('Tap to select file (JPG, PNG)', style: textTheme.bodySmall),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // SUBMIT ACTION
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitHarvestBatch,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('REGISTER HARVEST BATCH'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}