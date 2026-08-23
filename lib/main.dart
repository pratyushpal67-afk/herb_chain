import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

String get _baseUrl {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8000/api'; // Android emulator
  } else if (Platform.isIOS) {
    return 'http://localhost:8000/api'; // iOS simulator
  } else {
    return 'http://localhost:8000/api'; // Web (Chrome), Desktop, etc.
  }
}

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
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        }),
      ),
      home: const FarmerHarvestScreen(),
    );
  }
}

class Species {
  final int id;
  final String name;
  final String scientificName;

  Species({required this.id, required this.name, required this.scientificName});

  factory Species.fromJson(Map<String, dynamic> json) {
    return Species(
      id: json['id'],
      name: json['name'],
      scientificName: json['scientific_name'],
    );
  }

  String get displayName => '$name ($scientificName)';
}

class Collector {
  final int id;
  final String nodeId;
  final String name;
  final String region;

  Collector({
    required this.id,
    required this.nodeId,
    required this.name,
    required this.region,
  });

  factory Collector.fromJson(Map<String, dynamic> json) {
    return Collector(
      id: json['id'],
      nodeId: json['node_id'],
      name: json['name'],
      region: json['region'],
    );
  }
}

class FarmerHarvestScreen extends StatefulWidget {
  const FarmerHarvestScreen({super.key});

  @override
  State<FarmerHarvestScreen> createState() => _FarmerHarvestScreenState();
}

class _FarmerHarvestScreenState extends State<FarmerHarvestScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  List<Species> _speciesList = [];
  Species? _selectedSpecies;
  List<Collector> _collectors = [];
  Collector? _selectedCollector;

  Position? _currentPosition;
  bool _fetchingLocation = false;
  bool _loadingSpecies = true;
  bool _loadingCollectors = true;
  File? _capturedImage;
  bool _isSubmitting = false;
  bool _gpsLocked = false;

  String _batchId = '';

  late AnimationController _pageController;
  late AnimationController _gpsPulseController;
  late AnimationController _submitController;
  late Animation<double> _pageFade;
  late Animation<Offset> _pageSlide;
  late List<AnimationController> _fieldControllers;
  late List<Animation<double>> _fieldFades;
  late List<Animation<Offset>> _fieldSlides;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadInitialData();
    _determinePosition();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _fetchSpecies(),
      _fetchCollectors(),
    ]);
  }

  Future<void> _fetchSpecies() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/species/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _speciesList = data.map((e) => Species.fromJson(e)).toList();
          if (_speciesList.isNotEmpty) {
            _selectedSpecies = _speciesList.first;
          }
          _loadingSpecies = false;
        });
        _generateBatchId();
      } else {
        _setErrorState('Failed to load species');
      }
    } catch (e) {
      _setErrorState('Error loading species: $e');
    }
  }

  Future<void> _fetchCollectors() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/collectors/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _collectors = data.map((e) => Collector.fromJson(e)).toList();
          _selectedCollector = _collectors.isNotEmpty ? _collectors.first : null;
          _loadingCollectors = false;
        });
      } else {
        _setErrorState('Failed to load collectors');
      }
    } catch (e) {
      _setErrorState('Error loading collectors: $e');
    }
  }

  void _generateBatchId() {
    if (_selectedSpecies != null) {
      final prefix = _selectedSpecies!.name.substring(0, 3).toUpperCase();
      setState(() {
        _batchId = '$prefix-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      });
    }
  }

  void _setErrorState(String message) {
    if (!mounted) return;
    setState(() {
      _loadingSpecies = false;
      _loadingCollectors = false;
    });
    _showSnackBar(message);
  }

  void _initAnimations() {
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pageFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pageController, curve: Curves.easeOutCubic),
    );
    _pageSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _pageController, curve: Curves.easeOutCubic),
    );

    _gpsPulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _submitController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fieldControllers = List.generate(6, (index) => AnimationController(
      duration: Duration(milliseconds: 400 + (index * 100)),
      vsync: this,
    ));

    _fieldFades = _fieldControllers.map((c) => Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: c, curve: Curves.easeOutCubic),
    )).toList();

    _fieldSlides = _fieldControllers.map((c) => Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: c, curve: Curves.easeOutCubic),
    )).toList();

    _pageController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      for (int i = 0; i < _fieldControllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 80), () {
          if (mounted) _fieldControllers[i].forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _gpsPulseController.dispose();
    _submitController.dispose();
    for (var c in _fieldControllers) c.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
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
      _gpsLocked = true;
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
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _submitHarvestBatch() async {
    if (!_formKey.currentState!.validate()) return;
    if (_capturedImage == null) {
      _showSnackBar('Please capture a specimen photo for botanical proof.');
      return;
    }
    if (_currentPosition == null) {
      _showSnackBar('GPS lock is required before recording batch.');
      return;
    }
    if (_selectedSpecies == null) {
      _showSnackBar('Please select a species.');
      return;
    }
    if (_selectedCollector == null) {
      _showSnackBar('Please select a collector node.');
      return;
    }

    _submitController.forward();
    setState(() => _isSubmitting = true);

    try {
      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/batches/'));
      
      request.fields['species_id'] = _selectedSpecies!.id.toString();
      request.fields['collector_id'] = _selectedCollector!.id.toString();
      request.fields['weight_kg'] = _weightController.text;
      request.fields['latitude'] = _currentPosition!.latitude.toStringAsFixed(7);
      request.fields['longitude'] = _currentPosition!.longitude.toStringAsFixed(7);
      request.fields['accuracy_meters'] = _currentPosition!.accuracy.toStringAsFixed(2);
      request.fields['notes'] = _notesController.text;

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        _capturedImage!.path,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      setState(() => _isSubmitting = false);
      _submitController.reverse();

      if (!mounted) return;

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        _showSuccessDialog(
          batchId: data['batch_id'],
          species: _selectedSpecies!.displayName,
          weight: _weightController.text,
          position: _currentPosition!,
        );
      } else {
        final error = json.decode(response.body);
        _showSnackBar('Submission failed: ${error['detail'] ?? response.body}');
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      _submitController.reverse();
      if (!mounted) return;
      _showSnackBar('Network error: $e');
    }
  }

  void _showSuccessDialog({
    required String batchId,
    required String species,
    required String weight,
    required Position position,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Success',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => _SuccessDialogContent(
        batchId: batchId,
        species: species,
        weight: weight,
        position: position,
        onConfirm: () {
          Navigator.pop(context);
          setState(() {
            _capturedImage = null;
            _weightController.clear();
            _notesController.clear();
            _generateBatchId();
          });
        },
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  Widget _buildAnimatedField(int index, Widget child) {
    return SlideTransition(
      position: _fieldSlides[index],
      child: FadeTransition(opacity: _fieldFades[index], child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _loadingSpecies || _loadingCollectors;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AYURTRACE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(
              _selectedCollector != null
                  ? 'Collector Node: ${_selectedCollector!.nodeId} (${_selectedCollector!.region})'
                  : 'Loading collector...',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _determinePosition,
            tooltip: 'Refresh GPS',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF1B5E20)),
                  SizedBox(height: 16),
                  Text('Loading data from server...'),
                ],
              ),
            )
          : FadeTransition(
              opacity: _pageFade,
              child: SlideTransition(
                position: _pageSlide,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildAnimatedField(0, _buildBatchCard()),
                        _buildAnimatedField(1, _buildSpeciesDropdown()),
                        _buildAnimatedField(2, _buildCollectorDropdown()),
                        _buildAnimatedField(3, _buildWeightField()),
                        _buildAnimatedField(4, _buildGpsCard()),
                        _buildAnimatedField(5, _buildCameraCard()),
                        const SizedBox(height: 24),
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildBatchCard() {
    return Card(
      elevation: 0,
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.green.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Active Batch Session', style: TextStyle(fontSize: 12, color: Colors.black54)),
                Text(_batchId.isEmpty ? 'Generating...' : _batchId,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B5E20))),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(DateFormat('dd MMM yyyy').format(DateTime.now()),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeciesDropdown() {
    return DropdownButtonFormField<Species>(
      initialValue: _selectedSpecies,
      decoration: InputDecoration(
        labelText: 'Botanical Species',
        prefixIcon: const Icon(Icons.eco, color: Color(0xFF1B5E20)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: _speciesList.map((species) {
        return DropdownMenuItem(value: species, child: Text(species.displayName, style: const TextStyle(fontSize: 14)));
      }).toList(),
      onChanged: (val) {
        setState(() {
          _selectedSpecies = val;
          _generateBatchId();
        });
      },
      validator: (val) => val == null ? 'Select a species' : null,
    );
  }

  Widget _buildCollectorDropdown() {
    return DropdownButtonFormField<Collector>(
      initialValue: _selectedCollector,
      decoration: InputDecoration(
        labelText: 'Collector Node',
        prefixIcon: const Icon(Icons.person_pin, color: Color(0xFF1B5E20)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: _collectors.map((collector) {
        return DropdownMenuItem(value: collector, child: Text('${collector.nodeId} - ${collector.name}', style: const TextStyle(fontSize: 14)));
      }).toList(),
      onChanged: (val) => setState(() => _selectedCollector = val),
      validator: (val) => val == null ? 'Select a collector node' : null,
    );
  }

  Widget _buildWeightField() {
    return TextFormField(
      controller: _weightController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Harvest Weight (kg)',
        prefixIcon: const Icon(Icons.scale, color: Color(0xFF1B5E20)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return 'Enter harvest weight';
        if (double.tryParse(val) == null) return 'Enter a valid number';
        return null;
      },
    );
  }

  Widget _buildGpsCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: _gpsLocked ? Colors.green.shade300 : Colors.grey.shade300, width: _gpsLocked ? 2 : 1),
        borderRadius: BorderRadius.circular(16),
        color: _gpsLocked ? Colors.green.withValues(alpha: 0.08) : Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _gpsPulseController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fetchingLocation ? _gpsPulseController.value : 1.0,
                        child: Icon(
                          _gpsLocked ? Icons.gps_fixed : Icons.location_on,
                          color: _gpsLocked ? Colors.green : Colors.redAccent,
                          size: 24,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text('Origin Geotag', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _gpsLocked ? Colors.green[800] : null)),
                ],
              ),
              if (_fetchingLocation)
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              else if (_gpsLocked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                  child: const Text('LOCKED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const Divider(),
          if (_currentPosition != null) ...[
            _buildGpsRow('Latitude', '${_currentPosition!.latitude.toStringAsFixed(6)}° N'),
            _buildGpsRow('Longitude', '${_currentPosition!.longitude.toStringAsFixed(6)}° E'),
            _buildGpsRow('Accuracy', '±${_currentPosition!.accuracy.toStringAsFixed(1)}m', isAccuracy: true),
          ] else
            const Text('Acquiring high-accuracy satellite lock...', style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildGpsRow(String label, String value, {bool isAccuracy = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          Text(value, style: TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: isAccuracy ? FontWeight.w500 : FontWeight.normal, color: isAccuracy ? Colors.grey.shade700 : null)),
        ],
      ),
    );
  }

  Widget _buildCameraCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        onTap: () => _pickImage(ImageSource.camera),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: _capturedImage != null ? null : Colors.grey.shade100,
            border: Border.all(
              color: _capturedImage != null ? Colors.green.shade300 : Colors.grey.shade400,
              width: _capturedImage != null ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
            image: _capturedImage != null
                ? DecorationImage(image: FileImage(_capturedImage!), fit: BoxFit.cover)
                : null,
          ),
          child: _capturedImage == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E20).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.camera_alt_outlined, size: 40, color: Colors.green[700]),
                    ),
                    const SizedBox(height: 12),
                    const Text('Tap to capture botanical specimen photo', style: TextStyle(fontSize: 13, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text('Required for batch verification', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ],
                )
              : Stack(
                  children: [
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                          onPressed: () => _pickImage(ImageSource.camera),
                          tooltip: 'Retake photo',
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text('Photo captured', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedBuilder(
      animation: _submitController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isSubmitting ? 0.98 : 1.0,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitHarvestBatch,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: _isSubmitting ? 0 : 4,
              shadowColor: const Color(0xFF1B5E20).withValues(alpha: 0.4),
            ),
            child: _isSubmitting
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)),
                      const SizedBox(width: 12),
                      const Text('MINTING ON CHAIN...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  )
                : const Text('RECORD BATCH ON LEDGER', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}

class _SuccessDialogContent extends StatefulWidget {
  final String batchId;
  final String species;
  final String weight;
  final Position position;
  final VoidCallback onConfirm;

  const _SuccessDialogContent({
    required this.batchId,
    required this.species,
    required this.weight,
    required this.position,
    required this.onConfirm,
  });

  @override
  State<_SuccessDialogContent> createState() => _SuccessDialogContentState();
}

class _SuccessDialogContentState extends State<_SuccessDialogContent>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _checkScale;
  late Animation<double> _checkRotation;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _checkScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );
    _checkRotation = Tween<double>(begin: -0.5, end: 0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.easeOutCubic),
    );
    _checkController.forward();
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _checkController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _checkRotation.value,
                    child: Transform.scale(
                      scale: _checkScale.value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.green.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 5),
                          ],
                        ),
                        child: const Icon(Icons.verified, color: Colors.white, size: 48),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text('Batch Minted On-Chain', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Transaction confirmed on blockchain', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Batch ID', widget.batchId, mono: true),
                    _buildDetailRow('Species', widget.species),
                    _buildDetailRow('Weight', '${widget.weight} kg'),
                    _buildDetailRow('GPS', '${widget.position.latitude.toStringAsFixed(4)}° N, ${widget.position.longitude.toStringAsFixed(4)}° E', mono: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.science, color: Colors.green[700], size: 18),
                    const SizedBox(width: 8),
                    Text('Status: Ready for Lab Testing', style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('CONTINUE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool mono = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: mono ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}