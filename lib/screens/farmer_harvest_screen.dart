import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/batch.dart';
import '../utils/constants.dart';

class FarmerHarvestScreen extends StatefulWidget {
  const FarmerHarvestScreen({super.key});

  @override
  State<FarmerHarvestScreen> createState() => _FarmerHarvestScreenState();
}

class _FarmerHarvestScreenState extends State<FarmerHarvestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _clientEventIdController = TextEditingController();
  
  Herb? _selectedHerb;
  List<Herb> _herbs = [];
  Position? _currentPosition;
  File? _photo;
  bool _isLoading = false;
  bool _isLoadingHerbs = true;
  bool _isGettingLocation = false;
  String? _error;
  String _gpsAccuracy = '';

  @override
  void initState() {
    super.initState();
    _loadHerbs();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    _clientEventIdController.dispose();
    super.dispose();
  }

  Future<void> _loadHerbs() async {
    try {
      final apiService = context.read<AuthProvider>().apiService;
      final herbs = await apiService.getHerbs();
      if (mounted) {
        setState(() {
          _herbs = herbs;
          _isLoadingHerbs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingHerbs = false;
          _error = 'Failed to load herbs: $e';
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled. Please enable GPS.'), backgroundColor: Colors.orange),
        );
        setState(() => _isGettingLocation = false);
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied'), backgroundColor: Colors.red),
          );
          setState(() => _isGettingLocation = false);
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions permanently denied'), backgroundColor: Colors.red),
        );
        setState(() => _isGettingLocation = false);
      }
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _gpsAccuracy = position.accuracy.toStringAsFixed(2);
          _isGettingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGettingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1920,
      maxHeight: 1080,
    );
    if (pickedFile != null) {
      setState(() => _photo = File(pickedFile.path));
    }
  }

  Future<void> _pickPhotoFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1920,
      maxHeight: 1080,
    );
    if (pickedFile != null) {
      setState(() => _photo = File(pickedFile.path));
    }
  }

  Future<void> _submitCollection() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedHerb == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a herb'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GPS location not available. Please wait or retry.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = context.read<AuthProvider>().apiService;
      final batch = await apiService.createCollection(
        herbId: _selectedHerb!.herbId,
        quantityKg: _quantityController.text,
        latitude: _currentPosition!.latitude.toString(),
        longitude: _currentPosition!.longitude.toString(),
        gpsAccuracy: _gpsAccuracy,
        capturedAt: DateTime.now().toIso8601String(),
        clientEventId: _clientEventIdController.text.isNotEmpty ? _clientEventIdController.text : null,
        photo: _photo,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Harvest recorded! Batch ID: ${batch.batchId}'), backgroundColor: Colors.green),
        );
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to record harvest: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _quantityController.clear();
    _notesController.clear();
    _clientEventIdController.clear();
    _selectedHerb = null;
    _photo = null;
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Harvest'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getCurrentLocation,
            tooltip: 'Refresh Location',
          ),
        ],
      ),
      body: _isLoadingHerbs
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLocationCard(),
                    const SizedBox(height: 16),
                    _buildHerbSelectionCard(),
                    const SizedBox(height: 16),
                    _buildQuantityCard(),
                    const SizedBox(height: 16),
                    _buildPhotoCard(),
                    const SizedBox(height: 16),
                    _buildNotesCard(),
                    const SizedBox(height: 16),
                    _buildClientEventIdCard(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _currentPosition != null ? Icons.gps_fixed : Icons.gps_off,
                    color: _currentPosition != null ? Colors.green : Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GPS Location',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        _currentPosition != null
                            ? 'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}'
                            : 'Getting location...',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (_currentPosition != null)
                  _buildStatusChip('ACCURACY ±${_gpsAccuracy}m', Colors.blue),
              ],
            ),
            if (_currentPosition != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (_currentPosition != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Location copied to clipboard')),
                          );
                        }
                      },
                      icon: const Icon(Icons.content_copy),
                      label: const Text('Copy'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHerbSelectionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Herb Selection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Herb>(
              value: _selectedHerb,
              decoration: InputDecoration(
                labelText: 'Select Herb',
                prefixIcon: const Icon(Icons.eco_outlined, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              items: _herbs.map((herb) {
                return DropdownMenuItem(
                  value: herb,
                  child: Text(herb.displayName),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedHerb = value),
              validator: (value) => value == null ? 'Please select a herb' : null,
            ),
            if (_selectedHerb != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green[700], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedHerb!.commonName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text('Botanical: ${_selectedHerb!.botanicalName}', style: TextStyle(color: Colors.grey[700])),
                          if (_selectedHerb!.family.isNotEmpty)
                            Text('Family: ${_selectedHerb!.family}', style: TextStyle(color: Colors.grey[700])),
                          if (_selectedHerb!.plantPart.isNotEmpty)
                            Text('Part Used: ${_selectedHerb!.plantPart}', style: TextStyle(color: Colors.grey[700])),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quantity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                prefixIcon: const Icon(Icons.scale_outlined, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
                hintText: 'Enter weight in kilograms',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter quantity';
                if (double.tryParse(value) == null) return 'Enter valid number';
                if (double.parse(value) <= 0) return 'Quantity must be positive';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Harvest Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Optional - Take a photo of the harvest for traceability',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 16),
            if (_photo != null) ...[
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _photo!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => setState(() => _photo = null),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickPhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Retake'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickPhotoFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickPhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickPhotoFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Choose from Gallery'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes (Optional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Additional notes',
                prefixIcon: const Icon(Icons.note_outlined, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
                hintText: 'e.g., Weather conditions, field observations...',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientEventIdCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Client Event ID (Optional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Unique identifier for offline sync. Auto-generated if empty.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _clientEventIdController,
              decoration: InputDecoration(
                labelText: 'Client Event ID',
                prefixIcon: const Icon(Icons.fingerprint, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
                hintText: 'Auto-generated if left empty',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitCollection,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              )
            : const Text(
                'RECORD HARVEST',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}