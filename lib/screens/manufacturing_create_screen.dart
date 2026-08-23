import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/manufacturing.dart';
import '../utils/constants.dart';

class ManufacturingCreateScreen extends StatefulWidget {
  final String batchId;

  const ManufacturingCreateScreen({super.key, required this.batchId});

  @override
  State<ManufacturingCreateScreen> createState() => _ManufacturingCreateScreenState();
}

class _ManufacturingCreateScreenState extends State<ManufacturingCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _inputQuantityController = TextEditingController();
  final _outputQuantityController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _notesController = TextEditingController();
  
  List<Manufacturer> _manufacturers = [];
  Manufacturer? _selectedManufacturer;
  String _selectedProductType = 'powder';
  DateTime _selectedDate = DateTime.now();
  DateTime? _expiryDate;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  final List<String> _productTypes = [
    'powder',
    'capsule',
    'tablet',
    'extract',
    'oil',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _loadManufacturers();
  }

  @override
  void dispose() {
    _inputQuantityController.dispose();
    _outputQuantityController.dispose();
    _batchNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadManufacturers() async {
    try {
      final apiService = context.read<AuthProvider>().apiService;
      final manufacturers = await apiService.getManufacturers();
      if (mounted) {
        setState(() {
          _manufacturers = manufacturers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load manufacturers: $e';
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  Future<void> _submitManufacturing() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedManufacturer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a manufacturer'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final apiService = context.read<AuthProvider>().apiService;
      await apiService.createManufacturing(ManufacturingCreateRequest(
        batchId: widget.batchId,
        manufacturerId: _selectedManufacturer!.manufacturerId,
        productType: _selectedProductType,
        inputQuantityKg: _inputQuantityController.text,
        manufacturingDate: _selectedDate.toIso8601String(),
        batchNumber: _batchNumberController.text.isNotEmpty ? _batchNumberController.text : null,
        expiryDate: _expiryDate?.toIso8601String().split('T')[0],
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Manufacturing event created successfully'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create manufacturing: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Create Manufacturing Event'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Create Manufacturing Event'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('Failed to load manufacturers', style: TextStyle(fontSize: 18, color: Colors.red[700])),
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadManufacturers,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Manufacturing Event'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBatchInfoCard(),
              const SizedBox(height: 16),
              _buildManufacturerCard(),
              const SizedBox(height: 16),
              _buildProductTypeCard(),
              const SizedBox(height: 16),
              _buildQuantityCard(),
              const SizedBox(height: 16),
              _buildDateCard(),
              const SizedBox(height: 16),
              _buildBatchNumberCard(),
              const SizedBox(height: 16),
              _buildExpiryDateCard(),
              const SizedBox(height: 16),
              _buildNotesCard(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBatchInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [AppColors.primary.withOpacity(0.1), AppColors.primary.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
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
                  child: const Icon(Icons.factory, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Batch Information',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        widget.batchId,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManufacturerCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manufacturer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Manufacturer>(
              value: _selectedManufacturer,
              decoration: InputDecoration(
                labelText: 'Select Manufacturer',
                prefixIcon: const Icon(Icons.factory_outlined, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              items: _manufacturers.map((m) {
                return DropdownMenuItem(
                  value: m,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('${m.manufacturerId} • ${m.region}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedManufacturer = value),
              validator: (value) => value == null ? 'Please select a manufacturer' : null,
            ),
            if (_selectedManufacturer != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        const Text('Manufacturer Details', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildManufacturerInfoRow('License', _selectedManufacturer!.licenseNumber),
                    _buildManufacturerInfoRow('Address', _selectedManufacturer!.address),
                    _buildManufacturerInfoRow('Contact', _selectedManufacturer!.contactPerson),
                    _buildManufacturerInfoRow('Phone', _selectedManufacturer!.contactPhone),
                    _buildManufacturerInfoRow('Email', _selectedManufacturer!.contactEmail),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildManufacturerInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildProductTypeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Product Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedProductType,
              decoration: InputDecoration(
                labelText: 'Select Product Type',
                prefixIcon: const Icon(Icons.category_outlined, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              items: _productTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(_getProductIcon(type), color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(type.capitalize()),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedProductType = value!),
            ),
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
              'Quantities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _inputQuantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Input Quantity (kg) *',
                prefixIcon: const Icon(Icons.input_outlined, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
                hintText: 'Enter input quantity in kg',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter input quantity';
                if (double.tryParse(value) == null) return 'Enter valid number';
                if (double.parse(value) <= 0) return 'Quantity must be positive';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _outputQuantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Output Quantity (kg) - Optional',
                prefixIcon: const Icon(Icons.output_outlined, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
                hintText: 'Enter output quantity (can be filled when completing)',
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (double.tryParse(value) == null) return 'Enter valid number';
                  if (double.parse(value) < 0) return 'Quantity cannot be negative';
                  final input = double.tryParse(_inputQuantityController.text) ?? 0;
                  if (double.parse(value) > input) return 'Cannot exceed input quantity';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Output quantity can be updated when completing the manufacturing event',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manufacturing Date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Manufacturing Date',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            DateFormat('MMM dd, yyyy').format(_selectedDate),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchNumberCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Batch Number (Optional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _batchNumberController,
              decoration: InputDecoration(
                labelText: 'Batch Number',
                prefixIcon: const Icon(Icons.confirmation_number_outlined, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
                hintText: 'Enter manufacturer batch number',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryDateCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expiry Date (Optional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectExpiryDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: _expiryDate != null ? AppColors.primary : Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: Row(
                  children: [
                    Icon(Icons.event_outlined, color: _expiryDate != null ? AppColors.primary : Colors.grey),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Product Expiry Date',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            _expiryDate != null
                                ? DateFormat('MMM dd, yyyy').format(_expiryDate!)
                                : 'Not set (tap to select)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _expiryDate != null ? Colors.black87 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_expiryDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () => setState(() => _expiryDate = null),
                      )
                    else
                      const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
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
                labelText: 'Notes',
                prefixIcon: const Icon(Icons.note_outlined, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
                hintText: 'e.g., Equipment used, batch notes, quality parameters...',
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
        onPressed: _isSubmitting ? null : _submitManufacturing,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              )
            : const Text(
                'CREATE MANUFACTURING EVENT',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  IconData _getProductIcon(String type) {
    switch (type) {
      case 'powder': return Icons.grass;
      case 'capsule': return Icons.medication_outlined;
      case 'tablet': return Icons.medication;
      case 'extract': return Icons.science_outlined;
      case 'oil': return Icons.opacity_outlined;
      default: return Icons.factory_outlined;
    }
  }
}