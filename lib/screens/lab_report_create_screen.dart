import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/lab.dart';
import '../utils/constants.dart';

class LabReportCreateScreen extends StatefulWidget {
  final String batchId;

  const LabReportCreateScreen({super.key, required this.batchId});

  @override
  State<LabReportCreateScreen> createState() => _LabReportCreateScreenState();
}

class _LabReportCreateScreenState extends State<LabReportCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sampleNameController = TextEditingController();
  final _botanicalNameController = TextEditingController();
  final _sampleTypeController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _overallResult = 'pending';
  DateTime _collectionDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _receivedDate = DateTime.now().subtract(const Duration(days: 3));
  DateTime _testDate = DateTime.now();
  
  File? _reportFile;
  File? _certificateFile;
  
  final List<Map<String, dynamic>> _testResults = [
    {'name': 'Species Authentication', 'method': 'DNA Barcoding', 'reference': 'Match', 'controller': TextEditingController(), 'unitController': TextEditingController(), 'status': 'pending'},
    {'name': 'Moisture Content', 'method': 'Gravimetric', 'reference': '< 10%', 'controller': TextEditingController(), 'unitController': TextEditingController(text: '%'), 'status': 'pending'},
    {'name': 'Heavy Metals', 'method': 'ICP-MS', 'reference': 'Pb < 10 ppm, Cd < 0.3 ppm, Hg < 0.1 ppm, As < 3 ppm', 'controller': TextEditingController(), 'unitController': TextEditingController(text: 'ppm'), 'status': 'pending'},
    {'name': 'Pesticide Residue', 'method': 'LC-MS/MS', 'reference': 'Below MRL', 'controller': TextEditingController(), 'unitController': TextEditingController(text: 'ppm'), 'status': 'pending'},
    {'name': 'Microbial Bio-burden', 'method': 'Plate Count', 'reference': 'TPC < 10^5 CFU/g, Y&M < 10^3 CFU/g', 'controller': TextEditingController(), 'unitController': TextEditingController(text: 'CFU/g'), 'status': 'pending'},
  ];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _sampleNameController.dispose();
    _botanicalNameController.dispose();
    _sampleTypeController.dispose();
    _notesController.dispose();
    for (var test in _testResults) {
      test['controller'].dispose();
      test['unitController'].dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate(DateTime initialDate, Function(DateTime) onSelected) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  Future<void> _pickReportFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (pickedFile != null) {
      setState(() => _reportFile = File(pickedFile.path));
    }
  }

  Future<void> _pickCertificateFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (pickedFile != null) {
      setState(() => _certificateFile = File(pickedFile.path));
    }
  }

  Future<void> _submitLabReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final apiService = context.read<AuthProvider>().apiService;
      
      final testResults = _testResults.map((test) => {
        'test_name': test['name'],
        'test_method': test['method'],
        'result_value': test['controller'].text.isNotEmpty ? double.tryParse(test['controller'].text) : null,
        'unit': test['unitController'].text,
        'reference_range': test['reference'],
        'status': test['status'],
        'tested_at': _testDate.toIso8601String(),
        'notes': '',
      }).toList();

      await apiService.createLabReport(
        batchId: widget.batchId,
        sampleName: _sampleNameController.text.trim(),
        botanicalName: _botanicalNameController.text.trim(),
        collectionDate: _collectionDate.toIso8601String(),
        receivedDate: _receivedDate.toIso8601String(),
        testDate: _testDate.toIso8601String(),
        overallResult: _overallResult,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        testResults: testResults,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lab report created successfully'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create lab report: $e'), backgroundColor: Colors.red),
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
        title: const Text('Create Lab Report'),
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
              _buildSampleInfoCard(),
              const SizedBox(height: 16),
              _buildDatesCard(),
              const SizedBox(height: 16),
              _buildOverallResultCard(),
              const SizedBox(height: 16),
              _buildTestResultsCard(),
              const SizedBox(height: 16),
              _buildFilesCard(),
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
                  child: const Icon(Icons.science, color: AppColors.primary, size: 24),
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

  Widget _buildSampleInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sample Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sampleNameController,
              decoration: InputDecoration(
                labelText: 'Sample Name *',
                prefixIcon: const Icon(Icons.label_outlined, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
                hintText: 'Enter sample name/identifier',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Enter sample name';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _botanicalNameController,
              decoration: InputDecoration(
                labelText: 'Botanical Name *',
                prefixIcon: const Icon(Icons.eco_outlined, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
                hintText: 'Enter botanical/scientific name',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Enter botanical name';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _sampleTypeController,
              decoration: InputDecoration(
                labelText: 'Sample Type',
                prefixIcon: const Icon(Icons.category_outlined, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
                hintText: 'e.g., Raw herb, Powder, Extract',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDateField('Collection Date', _collectionDate, () => _selectDate(_collectionDate, (d) => setState(() => _collectionDate = d)))),
                const SizedBox(width: 12),
                Expanded(child: _buildDateField('Received Date', _receivedDate, () => _selectDate(_receivedDate, (d) => setState(() => _receivedDate = d)))),
              ],
            ),
            const SizedBox(height: 12),
            _buildDateField('Test Date', _testDate, () => _selectDate(_testDate, (d) => setState(() => _testDate = d))),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(DateFormat('MMM dd, yyyy').format(date), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallResultCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overall Result',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _overallResult,
              decoration: InputDecoration(
                labelText: 'Overall Result',
                prefixIcon: const Icon(Icons.verified_outlined, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              items: const [
                DropdownMenuItem(value: 'pass', child: Row(children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 8), Text('Pass')])),
                DropdownMenuItem(value: 'fail', child: Row(children: [Icon(Icons.cancel, color: Colors.red), SizedBox(width: 8), Text('Fail')])),
                DropdownMenuItem(value: 'pending', child: Row(children: [Icon(Icons.pending, color: Colors.orange), SizedBox(width: 8), Text('Pending Review')])),
              ],
              onChanged: (value) => setState(() => _overallResult = value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResultsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Results',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter results for each test parameter. Leave blank if not tested.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 16),
            ...List.generate(_testResults.length, (index) => _buildTestResultField(index)),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResultField(int index) {
    final test = _testResults[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.science, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(test['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(test['method'], style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    Text('Ref: ${test['reference']}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
              ),
              DropdownButton<String>(
                value: test['status'],
                items: const [
                  DropdownMenuItem(value: 'pass', child: Text('Pass', style: TextStyle(color: Colors.green))),
                  DropdownMenuItem(value: 'fail', child: Text('Fail', style: TextStyle(color: Colors.red))),
                  DropdownMenuItem(value: 'pending', child: Text('Pending', style: TextStyle(color: Colors.orange))),
                ],
                onChanged: (value) => setState(() => test['status'] = value!),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: test['controller'],
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Result Value',
                    prefixIcon: const Icon(Icons.analytics_outlined, color: AppColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    hintText: 'Enter numeric value',
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                      return 'Enter valid number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: test['unitController'],
                  decoration: InputDecoration(
                    labelText: 'Unit',
                    prefixIcon: const Icon(Icons.straighten_outlined, color: AppColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attachments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFilePicker(
              'Lab Report File',
              'Upload full lab report (PDF/Image)',
              _reportFile,
              _pickReportFile,
              (file) => setState(() => _reportFile = file),
            ),
            const SizedBox(height: 12),
            _buildFilePicker(
              'Certificate File',
              'Upload certificate of analysis',
              _certificateFile,
              _pickCertificateFile,
              (file) => setState(() => _certificateFile = file),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePicker(String label, String hint, File? file, VoidCallback onPick, Function(File) onFileSelected) {
    return InkWell(
      onTap: file == null ? onPick : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: file != null ? Colors.green : Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
          color: file != null ? Colors.green.shade50 : Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(file != null ? Icons.check_circle : Icons.upload_file, color: file != null ? Colors.green : Colors.grey[600], size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(
                    file != null ? 'File attached' : hint,
                    style: TextStyle(color: file != null ? Colors.green[700] : Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            if (file != null)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => onFileSelected(null as File),
              )
            else
              const Icon(Icons.chevron_right, color: Colors.grey),
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
                hintText: 'Additional observations or comments...',
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
        onPressed: _isSubmitting ? null : _submitLabReport,
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
                'CREATE LAB REPORT',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}