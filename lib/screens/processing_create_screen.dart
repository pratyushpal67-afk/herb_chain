import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/processing.dart';
import '../utils/constants.dart';

class ProcessingCreateScreen extends StatefulWidget {
  final String batchId;

  const ProcessingCreateScreen({super.key, required this.batchId});

  @override
  State<ProcessingCreateScreen> createState() => _ProcessingCreateScreenState();
}

class _ProcessingCreateScreenState extends State<ProcessingCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _facilityController = TextEditingController();
  final _receivedQuantityController = TextEditingController();
  final _processedQuantityController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedProcessType = 'drying';
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;
  String? _error;

  final List<String> _processTypes = [
    'drying',
    'grinding',
    'extraction',
    'packaging',
    'other',
  ];

  @override
  void dispose() {
    _facilityController.dispose();
    _receivedQuantityController.dispose();
    _processedQuantityController.dispose();
    _notesController.dispose();
    super.dispose();
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

  Future<void> _submitProcessing() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final apiService = context.read<AuthProvider>().apiService;
      await apiService.createProcessing(ProcessingCreateRequest(
        batchId: widget.batchId,
        facility: _facilityController.text.trim(),
        processType: _selectedProcessType,
        receivedQuantityKg: _receivedQuantityController.text,
        startedAt: _selectedDate.toIso8601String(),
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Processing event created successfully'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create processing: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Processing Event'),
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
              _buildProcessTypeCard(),
              const SizedBox(height: 16),
              _buildFacilityCard(),
              const SizedBox(height: 16),
              _buildQuantityCard(),
              const SizedBox(height: 16),
              _buildDateCard(),
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
                  child: const Icon(Icons.precision_manufacturing, color: AppColors.primary, size: 24),
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

  Widget _buildProcessTypeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Process Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedProcessType,
              decoration: InputDecoration(
                labelText: 'Select Process Type',
                prefixIcon: const Icon(Icons.precision_manufacturing_outlined, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              items: _processTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(_getProcessIcon(type), color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(type.capitalize()),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedProcessType = value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Facility',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _facilityController,
              decoration: InputDecoration(
                labelText: 'Facility Name',
                prefixIcon: const Icon(Icons.business_outlined, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
                hintText: 'Enter processing facility name',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Enter facility name';
                return null;
              },
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
              controller: _receivedQuantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Received Quantity (kg) *',
                prefixIcon: const Icon(Icons.input_outlined, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
                hintText: 'Enter received quantity in kg',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter received quantity';
                if (double.tryParse(value) == null) return 'Enter valid number';
                if (double.parse(value) <= 0) return 'Quantity must be positive';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _processedQuantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Processed Quantity (kg) - Optional',
                prefixIcon: const Icon(Icons.output_outlined, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
                hintText: 'Enter processed quantity (can be filled later)',
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (double.tryParse(value) == null) return 'Enter valid number';
                  if (double.parse(value) < 0) return 'Quantity cannot be negative';
                  final received = double.tryParse(_receivedQuantityController.text) ?? 0;
                  if (double.parse(value) > received) return 'Cannot exceed received quantity';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Processed quantity can be updated when completing the processing event',
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
              'Start Date',
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
                            'Processing Start Date',
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
                hintText: 'e.g., Temperature, duration, equipment used...',
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
        onPressed: _isSubmitting ? null : _submitProcessing,
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
                'CREATE PROCESSING EVENT',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  IconData _getProcessIcon(String type) {
    switch (type) {
      case 'drying': return Icons.wb_sunny_outlined;
      case 'grinding': return Icons.construction_outlined;
      case 'extraction': return Icons.science_outlined;
      case 'packaging': return Icons.inventory_2_outlined;
      default: return Icons.precision_manufacturing_outlined;
    }
  }
}