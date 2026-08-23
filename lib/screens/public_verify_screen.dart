import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/public.dart';
import '../utils/constants.dart';

class PublicVerifyScreen extends StatefulWidget {
  const PublicVerifyScreen({super.key});

  @override
  State<PublicVerifyScreen> createState() => _PublicVerifyScreenState();
}

class _PublicVerifyScreenState extends State<PublicVerifyScreen> with SingleTickerProviderStateMixin {
  final _batchIdController = TextEditingController();
  final _apiService = ApiService(SharedPreferences.getInstance());
  
  PublicBatchVerify? _verifyResult;
  PublicBatchQr? _qrResult;
  PublicBatchJourney? _journeyResult;
  bool _isLoading = false;
  String? _error;
  int _currentTab = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _currentTab = _tabController.index);
        _verifyBatch();
      }
    });
  }

  @override
  void dispose() {
    _batchIdController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _verifyBatch() async {
    final batchId = _batchIdController.text.trim().toUpperCase();
    if (batchId.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _verifyResult = null;
      _qrResult = null;
      _journeyResult = null;
    });

    try {
      final apiService = context.read<AuthProvider>()._apiService;
      
      if (_currentTab == 0) {
        _verifyResult = await apiService.getPublicBatchVerify(batchId);
      } else if (_currentTab == 1) {
        _journeyResult = await apiService.getPublicBatchJourney(batchId);
      } else if (_currentTab == 2) {
        _qrResult = await apiService.getPublicBatchQr(batchId);
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Batch'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.verified), text: 'Verify'),
            Tab(icon: Icon(Icons.timeline), text: 'Journey'),
            Tab(icon: Icon(Icons.qr_code), text: 'QR Code'),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scan or Enter Batch ID',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _batchIdController,
                        decoration: InputDecoration(
                          labelText: 'Batch ID (e.g., ASH-20260823...)',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: _batchIdController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _batchIdController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                        ),
                        textInputAction: TextInputAction.search,
                        onFieldSubmitted: (_) => _verifyBatch(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _verifyBatch,
                      icon: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.verified),
                      label: const Text('Verify'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.red.shade50,
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    if (_verifyResult == null && _journeyResult == null && _qrResult == null && !_isLoading) {
      return _buildEmptyState();
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    switch (_currentTab) {
      case 0:
        return _verifyResult != null ? _buildVerifyContent(_verifyResult!) : _buildEmptyState();
      case 1:
        return _journeyResult != null ? _buildJourneyContent(_journeyResult!) : _buildEmptyState();
      case 2:
        return _qrResult != null ? _buildQrContent(_qrResult!) : _buildEmptyState();
      default:
        return _buildEmptyState();
    }
  }

  Widget _buildVerifyContent(PublicBatchVerify verify) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: verify.verified
                      ? [Colors.green.shade400, Colors.green.shade600]
                      : [Colors.orange.shade400, Colors.orange.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    verify.verified ? Icons.verified : Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    verify.verified ? 'VERIFIED' : 'NOT VERIFIED',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    verify.verified
                        ? 'This batch has completed the full traceability chain'
                        : 'This batch is still in progress or has issues',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            'Batch Information',
            Icons.info_outline,
            [
              _buildDetailRow('Batch ID', verify.batchId, mono: true),
              _buildDetailRow('Herb', verify.herb),
              _buildDetailRow('Botanical Name', verify.botanicalName),
              _buildDetailRow('Origin', verify.origin ?? 'Not specified'),
              _buildDetailRow('Collector Node', verify.collectorNode ?? 'Not specified'),
              _buildDetailRow('Collection Date', _formatDate(verify.collectionDate)),
              _buildDetailRow('Current Status', verify.status.capitalize()),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            'Verification Checks',
            Icons.checklist,
            [
              _buildCheckRow(
                'Lab Test Passed',
                verify.labTestPassed,
                verify.labTestPassed ? 'All lab tests passed' : 'Lab tests pending or failed',
              ),
              _buildCheckRow(
                'Manufacturing Completed',
                verify.manufacturingCompleted,
                verify.manufacturingCompleted ? 'Manufacturing process completed' : 'Manufacturing not started or incomplete',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            'Blockchain Hash',
            Icons.security,
            [
              _buildDetailRow('Hash', verify.hash, mono: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyContent(PublicBatchJourney journey) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
                        child: const Icon(Icons.timeline, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Journey Timeline',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              journey.batchId,
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusChip(journey.currentStatus),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (journey.journey.isEmpty)
            _buildEmptyState(message: 'No journey events recorded yet')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: journey.journey.length,
              itemBuilder: (context, index) {
                final event = journey.journey[index];
                return _buildJourneyEventCard(event, index == journey.journey.length - 1);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildJourneyEventCard(Map<String, dynamic> event, bool isLast) {
    final type = event['type'] as String? ?? '';
    final status = event['status'] as String? ?? '';
    final timestamp = event['timestamp'] as String? ?? '';
    final location = event['location'] as Map<String, dynamic>?;
    final details = event['details'] as Map<String, dynamic>? ?? {};

    final color = _getEventColor(type);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 16 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade300,
                    margin: const EdgeInsets.symmetric(horizontal: 11),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(_getEventIcon(type), color: color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                type.capitalize(),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                _formatDateTime(timestamp),
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        _buildStatusChip(status),
                      ],
                    ),
                    if (location != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Lat: ${location['latitude']}, Lng: ${location['longitude']}',
                            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ],
                    if (details.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Details:',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      ...details.entries.map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '${e.key}: ${e.value}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrContent(PublicBatchQr qr) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Batch QR Code',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    qr.qrData['batchId'] ?? 'Unknown',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Image.memory(
                      base64Decode(qr.qrCodeBase64),
                      width: 200,
                      height: 200,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Scan to verify batch authenticity',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionCard(
                    'QR Data',
                    Icons.data_object,
                    qr.qrData.entries.map((e) => _buildDetailRow(e.key, e.value.toString())).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
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
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool mono = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: mono ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckRow(String label, bool passed, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: passed ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
            child: Icon(passed ? Icons.check : Icons.close, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = AppConstants.statusColors[status] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

  Widget _buildEmptyState({String message = 'Enter a Batch ID to verify'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_scanner_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Find the Batch ID on the product label', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'COLLECTION': return Colors.green;
      case 'PROCESSING': return Colors.blue;
      case 'LAB': return Colors.purple;
      case 'MANUFACTURING': return Colors.orange;
      case 'QR_GENERATED': return Colors.teal;
      default: return Colors.grey;
    }
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'COLLECTION': return Icons.eco;
      case 'PROCESSING': return Icons.precision_manufacturing;
      case 'LAB': return Icons.science;
      case 'MANUFACTURING': return Icons.factory;
      case 'QR_GENERATED': return Icons.qr_code;
      default: return Icons.circle;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDateTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }
}