import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/lab.dart';
import '../utils/constants.dart';

class LabTestSubmitScreen extends StatefulWidget {
  final LabTest labTest;

  const LabTestSubmitScreen({super.key, required this.labTest});

  @override
  State<LabTestSubmitScreen> createState() => _LabTestSubmitScreenState();
}

class _LabTestSubmitScreenState extends State<LabTestSubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedResult = 'pass';
  final _moistureController = TextEditingController();
  final _purityController = TextEditingController();
  final _heavyMetalsController = TextEditingController();
  final _pesticideController = TextEditingController();
  final _microbialController = TextEditingController();
  final _notesController = TextEditingController();
  File? _certificateFile;
  bool _isSubmitting = false;

  final List<String> _results = ['pass', 'fail'];

  @override
  void dispose() {
    _moistureController.dispose();
    _purityController.dispose();
    _heavyMetalsController.dispose();
    _pesticideController.dispose();
    _microbialController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickCertificate() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (pickedFile != null) {
      setState(() => _certificateFile = File(pickedFile.path));
    }
  }

  Future<void> _submitResult() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final apiService = context.read<AuthProvider>()._apiService;
      await apiService.submitLabTestResult(
        labTestId: widget.labTest.id.toString(),
        result: _selectedResult,
        moistureContent: _moistureController.text.isNotEmpty ? _moistureController.text : null,
        purityPercentage: _purityController.text.isNotEmpty ? _purityController.text : null,
        heavyMetalsPpm: _heavyMetalsController.text.isNotEmpty ? _heavyMetalsController.text : null,
        pesticideResiduePpm: _pesticideController.text.isNotEmpty ? _pesticideController.text : null,
        microbialCountCfu: _microbialController.text.isNotEmpty ? _microbialController.text : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        certificateFile: _certificateFile,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lab test result submitted successfully'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final labTest = widget.labTest;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Lab Test Result'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
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
                            child: const Icon(Icons.science, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lab Test',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  labTest.batchId,
                                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          _buildStatusChip(labTest.result),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Test Date', _formatDate(labTest.testDate)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text('Test Result', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _selectedResult,
                        decoration: InputDecoration(
                          labelText: 'Overall Result',
                          prefixIcon: const Icon(Icons.verified_outlined, color: AppColors.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: _results.map((result) {
                          return DropdownMenuItem(
                            value: result,
                            child: Row(
                              children: [
                                Icon(
                                  result == 'pass' ? Icons.check_circle : Icons.cancel,
                                  color: result == 'pass' ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(result.capitalize()),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedResult = val!),
                        validator: (val) => val == null ? 'Select a result' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text('Test Parameters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildNumberField(
                        'Moisture Content (%)',
                        _moistureController,
                        'Enter moisture content',
                        icon: Icons.water_drop_outlined,
                      ),
                      _buildNumberField(
                        'Purity Percentage (%)',
                        _purityController,
                        'Enter purity percentage',
                        icon: Icons.verified_outlined,
                      ),
                      _buildNumberField(
                        'Heavy Metals (ppm)',
                        _heavyMetalsController,
                        'Enter heavy metals ppm',
                        icon: Icons.warning_outlined,
                      ),
                      _buildNumberField(
                        'Pesticide Residue (ppm)',
                        _pesticideController,
                        'Enter pesticide residue ppm',
                        icon: Icons.bug_report_outlined,
                      ),
                      _buildNumberField(
                        'Microbial Count (CFU/g)',
                        _microbialController,
                        'Enter microbial count',
                        icon: Icons.biotech_outlined,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Notes',
                          prefixIcon: const Icon(Icons.note_outlined, color: AppColors.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('Certificate File', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickCertificate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                            color: _certificateFile != null ? Colors.green.shade50 : Colors.grey.shade50,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _certificateFile != null ? Icons.check_circle : Icons.upload_file,
                                color: _certificateFile != null ? Colors.green : Colors.grey[600],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _certificateFile != null
                                      ? 'Certificate attached'
                                      : 'Tap to upload certificate file',
                                  style: TextStyle(
                                    color: _certificateFile != null ? Colors.green[700] : Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitResult,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('SUBMIT RESULT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField(
    String label,
    TextEditingController controller,
    String hint, {
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
          hintText: hint,
        ),
        validator: (val) {
          if (val != null && val.isNotEmpty && double.tryParse(val) == null) {
            return 'Enter a valid number';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = AppConstants.statusColors[status] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.capitalize(),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      return DateTime.parse(dateStr).toLocal().toString().split('.')[0];
    } catch (_) {
      return dateStr;
    }
  }
}