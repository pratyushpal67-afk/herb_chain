import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const AyurTraceApp());
}

class AyurTraceApp extends StatelessWidget {
  const AyurTraceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AyurTrace Field Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          primary: const Color(0xFF1B5E20),
          secondary: const Color(0xFF2E7D32),
        ),
      ),
      home: const FarmerHarvestScreen(),
    );
  }
}

class FarmerHarvestScreen extends StatefulWidget {
  const FarmerHarvestScreen({super.key});

  @override
  State<FarmerHarvestScreen> createState() => _FarmerHarvestScreenState();
}

class _FarmerHarvestScreenState extends State<FarmerHarvestScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedSpecies = 'Ashwagandha (Withania somnifera)';
  final List<String> _speciesList = [
    'Ashwagandha (Withania somnifera)',
    'Tulsi (Ocimum sanctum)',
    'Brahmi (Bacopa monnieri)',
    'Shatavari (Asparagus racemosus)',
    'Neem (Azadirachta indica)',
  ];

  Position? _currentPosition;
  bool _fetchingLocation = false;
  File? _capturedImage;
  bool _isSubmitting = false;

  final String _batchId = 'ASH-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    setState(() => _fetchingLocation = true);
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _fetchingLocation = false);
      _showSnackBar('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _fetchingLocation = false);
        _showSnackBar('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _fetchingLocation = false);
      _showSnackBar('Location permissions are permanently denied.');
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentPosition = position;
      _fetchingLocation = false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _capturedImage = File(pickedFile.path);
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green[800]),
    );
  }

  void _submitHarvestBatch() async {
    if (!_formKey.currentState!.validate()) return;
    if (_capturedImage == null) {
      _showSnackBar('Please capture a specimen photo for botanical proof.');
      return;
    }
    if (_currentPosition == null) {
      _showSnackBar('GPS lock is required before recording batch.');
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulated network/blockchain dispatch delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isSubmitting = false);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.verified, color: Colors.green, size: 48),
        title: const Text('Batch Minted On-Chain'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Batch ID: $_batchId', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Species: $_selectedSpecies'),
            Text('Weight: ${_weightController.text} kg'),
            Text('GPS: ${_currentPosition!.latitude.toStringAsFixed(4)}° N, ${_currentPosition!.longitude.toStringAsFixed(4)}° E'),
            const SizedBox(height: 8),
            const Text('Status: Ready for Lab Testing', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _capturedImage = null;
                _weightController.clear();
                _notesController.clear();
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AYURTRACE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Collector Node: COL-01 (Hooghly)', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _determinePosition,
            tooltip: 'Refresh GPS',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Batch Identifier Card
              Card(
                elevation: 0,
                color: Colors.green.shade50,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.green.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Active Batch Session', style: TextStyle(fontSize: 12, color: Colors.black54)),
                          Text(_batchId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B5E20))),
                        ],
                      ),
                      Text(DateFormat('dd MMM yyyy').format(DateTime.now()), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Species Dropdown
              DropdownButtonFormField<String>(
                value: _selectedSpecies,
                decoration: InputDecoration(
                  labelText: 'Botanical Species',
                  prefixIcon: const Icon(Icons.eco, color: Color(0xFF1B5E20)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _speciesList.map((species) {
                  return DropdownMenuItem(value: species, child: Text(species, style: const TextStyle(fontSize: 14)));
                }).toList(),
                onChanged: (val) => setState(() => _selectedSpecies = val!),
              ),
              const SizedBox(height: 16),

              // Weight Input
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Harvest Weight (kg)',
                  prefixIcon: const Icon(Icons.scale, color: Color(0xFF1B5E20)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter harvest weight';
                  if (double.tryParse(val) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // GPS Geotag Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.redAccent, size: 20),
                            SizedBox(width: 6),
                            Text('Origin Geotag', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        if (_fetchingLocation)
                          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      ],
                    ),
                    const Divider(),
                    if (_currentPosition != null) ...[
                      Text('Latitude: ${_currentPosition!.latitude.toStringAsFixed(6)}° N', style: const TextStyle(fontFamily: 'monospace')),
                      Text('Longitude: ${_currentPosition!.longitude.toStringAsFixed(6)}° E', style: const TextStyle(fontFamily: 'monospace')),
                      Text('Accuracy: ±${_currentPosition!.accuracy.toStringAsFixed(1)}m', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ] else
                      const Text('Acquiring high-accuracy satellite lock...', style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Camera / Specimen Capture Area
              InkWell(
                onTap: () => _pickImage(ImageSource.camera),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _capturedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_capturedImage!, fit: BoxFit.cover, width: double.infinity),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined, size: 40, color: Colors.grey.shade700),
                            const SizedBox(height: 8),
                            const Text('Tap to capture botanical specimen photo', style: TextStyle(fontSize: 13, color: Colors.black54)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitHarvestBatch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('RECORD BATCH ON LEDGER', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}