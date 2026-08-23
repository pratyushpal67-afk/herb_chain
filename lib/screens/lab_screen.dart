import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/lab.dart';
import '../utils/constants.dart';
import 'lab_test_submit_screen.dart';

class LabScreen extends StatefulWidget {
  @override
  State<LabScreen> createState() => _LabScreenState();
}

class _LabScreenState extends State<LabScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<LabReport> _labReports = [];
  List<LabTest> _labTests = [];
  bool _isLoadingReports = false;
  bool _isLoadingTests = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadLabReports(),
      _loadLabTests(),
    ]);
  }

  Future<void> _loadLabReports() async {
    setState(() => _isLoadingReports = true);
    try {
      final apiService = context.read<AuthProvider>()._apiService;
      _labReports = await apiService.getLabReports();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoadingReports = false);
    }
  }

  Future<void> _loadLabTests() async {
    setState(() => _isLoadingTests = true);
    try {
      final apiService = context.read<AuthProvider>()._apiService;
      _labTests = await apiService.getLabTests();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoadingTests = false);
    }
  }

  Future<void> _handleTestSubmitted() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Testing'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.assignment), text: 'Reports'),
            Tab(icon: Icon(Icons.science), text: 'Pending Tests'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoadingReports && _isLoadingTests
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _error != null && _labReports.isEmpty && _labTests.isEmpty
              ? _buildErrorState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReportsTab(),
                    _buildTestsTab(),
                  ],
                ),
    );
  }

  Widget _buildReportsTab() {
    if (_labReports.isEmpty && _isLoadingReports) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_labReports.isEmpty) {
      return _buildEmptyState('No lab reports yet');
    }

    return RefreshIndicator(
      onRefresh: _loadLabReports,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _labReports.length,
        itemBuilder: (context, index) => _buildLabReportCard(_labReports[index]),
      ),
    );
  }

  Widget _buildTestsTab() {
    final pendingTests = _labTests.where((t) => t.result == 'pending').toList();

    if (pendingTests.isEmpty && _isLoadingTests) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (pendingTests.isEmpty) {
      return _buildEmptyState('No pending lab tests');
    }

    return RefreshIndicator(
      onRefresh: _loadLabTests,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pendingTests.length,
        itemBuilder: (context, index) => _buildLabTestCard(pendingTests[index]),
      ),
    );
  }

  Widget _buildLabReportCard(LabReport report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showReportDetails(report),
        borderRadius: BorderRadius.circular(12),
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
                      color: report.isPassed
                          ? Colors.green.withOpacity(0.1)
                          : report.isFailed
                              ? Colors.red.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      report.isPassed ? Icons.check_circle : report.isFailed ? Icons.cancel : Icons.pending,
                      color: report.isPassed ? Colors.green : report.isFailed ? Colors.red : Colors.orange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lab Report',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          report.reportId,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(report.overallResult),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow('Sample', report.sampleName),
              _buildInfoRow('Botanical', report.botanicalName),
              _buildInfoRow('Type', report.sampleType),
              _buildInfoRow('Collection', _formatDate(report.collectionDate)),
              _buildInfoRow('Received', _formatDate(report.receivedDate)),
              _buildInfoRow('Tested', _formatDate(report.testDate)),
              if (report.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow('Notes', report.notes),
              ],
              const SizedBox(height: 12),
              if (report.testResults.isNotEmpty) ...[
                const Text(
                  'Test Results (${report.testResults.length})',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                ...report.testResults.map((t) => _buildTestResultTile(t)).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabTestCard(LabTest test) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToSubmitResult(test),
        borderRadius: BorderRadius.circular(12),
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
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.science, color: Colors.orange, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lab Test Pending',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          test.batchId,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(test.result),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow('Test Date', _formatDate(test.testDate)),
              if (test.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow('Notes', test.notes),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToSubmitResult(test),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Submit Result'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSubmitResult(LabTest test) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LabTestSubmitScreen(labTest: test)),
    ).then((_) => _handleTestSubmitted());
  }

  Widget _buildTestResultTile(LabTestResult test) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      color: test.isPassed ? Colors.green.shade50 : test.isFailed ? Colors.red.shade50 : Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Icon(
          test.isPassed ? Icons.check_circle : test.isFailed ? Icons.cancel : Icons.pending,
          color: test.isPassed ? Colors.green : test.isFailed ? Colors.red : Colors.grey,
        ),
        title: Text(test.testName, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Method: ${test.testMethod}'),
            Text('Reference: ${test.referenceRange}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatusChip(test.status),
            if (test.formattedValue != 'N/A')
              Text(
                test.formattedValue,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
          ],
        ),
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
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
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

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.science_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(_tabController.index == 0
              ? 'Lab reports will appear here when created'
              : 'Pending tests will appear here when batches are sent to lab',
              style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text('Failed to load data', style: TextStyle(fontSize: 18, color: Colors.red[700])),
          const SizedBox(height: 8),
          Text(_error ?? 'Unknown error', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDetails(LabReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Text(report.reportId, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildStatusChip(report.overallResult),
                const SizedBox(height: 16),
                _buildInfoRow('Sample', report.sampleName),
                _buildInfoRow('Botanical', report.botanicalName),
                _buildInfoRow('Type', report.sampleType),
                _buildInfoRow('Collection Date', _formatDate(report.collectionDate)),
                _buildInfoRow('Received Date', _formatDate(report.receivedDate)),
                _buildInfoRow('Test Date', _formatDate(report.testDate)),
                _buildInfoRow('Lab', report.labName),
                if (report.notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(report.notes),
                ],
                const SizedBox(height: 16),
                if (report.testResults.isNotEmpty) ...[
                  const Text('Test Results', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...report.testResults.map((t) => _buildTestResultTile(t)).toList(),
                ],
              ],
            ),
          ),
        ),
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