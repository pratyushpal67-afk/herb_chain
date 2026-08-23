import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/batch.dart';
import '../models/lab.dart';
import '../models/processing.dart';
import '../models/manufacturing.dart';
import '../utils/constants.dart';
import 'processing_create_screen.dart';
import 'manufacturing_create_screen.dart';
import 'lab_report_create_screen.dart';

class BatchDetailScreen extends StatefulWidget {
  final String batchId;

  const BatchDetailScreen({super.key, required this.batchId});

  @override
  State<BatchDetailScreen> createState() => _BatchDetailScreenState();
}

class _BatchDetailScreenState extends State<BatchDetailScreen> {
  Batch? _batch;
  bool _isLoading = true;
  bool _isSendingToLab = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBatch();
  }

  Future<void> _loadBatch() async {
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<AuthProvider>()._apiService;
      _batch = await apiService.getBatch(widget.batchId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendToLab() async {
    if (_batch == null) return;
    
    setState(() => _isSendingToLab = true);
    
    try {
      final apiService = context.read<AuthProvider>()._apiService;
      await apiService.sendBatchToLab(_batch!.batchId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Batch sent to lab testing'), backgroundColor: Colors.green),
        );
        _loadBatch();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send to lab: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingToLab = false);
    }
  }

  void _handleAction(String action) {
    if (_batch == null) return;
    
    switch (action) {
      case 'processing':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProcessingCreateScreen(batchId: _batch!.batchId)),
        ).then((result) {
          if (result == true) _loadBatch();
        });
        break;
      case 'manufacturing':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ManufacturingCreateScreen(batchId: _batch!.batchId)),
        ).then((result) {
          if (result == true) _loadBatch();
        });
        break;
      case 'lab_report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LabReportCreateScreen(batchId: _batch!.batchId)),
        ).then((result) {
          if (result == true) _loadBatch();
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_batch?.batchId ?? 'Batch Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_batch != null && _batch!.status == 'recorded')
            TextButton.icon(
              onPressed: _isSendingToLab ? null : _sendToLab,
              icon: _isSendingToLab
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.science, color: Colors.white),
              label: Text(_isSendingToLab ? 'Sending...' : 'Send to Lab', style: const TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          if (_batch != null && (_batch!.status == 'recorded' || _batch!.status == 'completed'))
            PopupMenuButton<String>(
              icon: const Icon(Icons.add, color: Colors.white),
              tooltip: 'Add Event',
              onSelected: (value) => _handleAction(value),
              itemBuilder: (context) => [
                if (_batch!.status == 'recorded' || _batch!.status == 'completed')
                  const PopupMenuItem(
                    value: 'processing',
                    child: Row(
                      children: [
                        Icon(Icons.precision_manufacturing, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Add Processing'),
                      ],
                    ),
                  ),
                if (_batch!.status == 'completed')
                  const PopupMenuItem(
                    value: 'manufacturing',
                    child: Row(
                      children: [
                        Icon(Icons.factory, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Add Manufacturing'),
                      ],
                    ),
                  ),
                if (_batch!.status == 'lab_testing' || _batch!.status == 'recorded' || _batch!.status == 'completed')
                  const PopupMenuItem(
                    value: 'lab_report',
                    child: Row(
                      children: [
                        Icon(Icons.description, color: Colors.purple),
                        SizedBox(width: 8),
                        Text('Add Lab Report'),
                      ],
                    ),
                  ),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadBatch(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null && _batch == null) {
      return _buildErrorState();
    }

    if (_batch == null && _isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_batch == null) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadBatch,
      color: AppColors.primary,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildInfoCard(),
            if (_batch!.collectionEvents.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSectionHeader('Collection Events', Icons.eco_outlined),
              const SizedBox(height: 8),
              ...(_batch!.collectionEvents.map((e) => _buildEventCard(e))),
            ],
            if (_batch!.labReports.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSectionHeader('Lab Reports', Icons.science_outlined),
              const SizedBox(height: 8),
              ...(_batch!.labReports.map((r) => _buildLabReportCard(r))),
            ],
            if (_batch!.processingEvents.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSectionHeader('Processing Events', Icons.precision_manufacturing_outlined),
              const SizedBox(height: 8),
              ...(_batch!.processingEvents.map((e) => _buildProcessingCard(e))),
            ],
            if (_batch!.manufacturingEvents.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSectionHeader('Manufacturing Events', Icons.factory_outlined),
              const SizedBox(height: 8),
              ...(_batch!.manufacturingEvents.map((e) => _buildManufacturingCard(e))),
            ],
            if (_batch!.batchEvents.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSectionHeader('Timeline', Icons.timeline_outlined),
              const SizedBox(height: 8),
              ...(_batch!.batchEvents.map((e) => _buildTimelineCard(e))),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.eco, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _batch!.batchId,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _batch!.herb.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildHeaderInfo('Weight', _batch!.formattedWeight, Icons.scale_outlined),
                ),
                Expanded(
                  child: _buildHeaderInfo('Status', _batch!.status.capitalize(), Icons.info_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.white.withOpacity(0.8)),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
          ],
        ),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildStatusCard() {
    final color = AppConstants.statusColors[_batch!.status] ?? Colors.grey;
    final icon = AppConstants.statusIcons[_batch!.status] ?? Icons.help_outline;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Status',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _batch!.status.capitalize(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Batch Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Batch ID', _batch!.batchId),
            _buildInfoRow('Herb', _batch!.herb.displayName),
            _buildInfoRow('Collector', '${_batch!.collector.name} (${_batch!.collector.nodeId})'),
            _buildInfoRow('Region', _batch!.collector.region),
            _buildInfoRow('Weight', _batch!.formattedWeight),
            _buildInfoRow('Coordinates', _batch!.formattedCoordinates),
            _buildInfoRow('GPS Accuracy', '±${_batch!.accuracyMeters} m'),
            _buildInfoRow('Created', _formatDateTime(_batch!.createdAt)),
            if (_batch!.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow('Notes', _batch!.notes),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildEventCard(CollectionEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.eco, color: Colors.green),
        ),
        title: Text('Collection Event', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${event.quantityKg} kg • ${event.herbName}'),
            Text('GPS: ${double.parse(event.latitude).toStringAsFixed(4)}°, ${double.parse(event.longitude).toStringAsFixed(4)}°'),
            Text('Accuracy: ±${event.gpsAccuracyM}m'),
          ],
        ),
        trailing: _buildStatusChip(event.syncStatus),
        onTap: () {},
      ),
    );
  }

  Widget _buildLabReportCard(LabReport report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: report.isPassed ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(report.isPassed ? Icons.check_circle : Icons.cancel, color: report.isPassed ? Colors.green : Colors.red),
        ),
        title: Text('Lab Report', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Result: ${report.overallResult.capitalize()}'),
            Text('Test Date: ${_formatDate(report.testDate)}'),
            Text('${report.testResults.length} tests'),
          ],
        ),
        trailing: _buildStatusChip(report.overallResult),
        onTap: () {},
      ),
    );
  }

  Widget _buildProcessingCard(ProcessingEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.precision_manufacturing, color: Colors.blue),
        ),
        title: Text('${event.processType.capitalize()}', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Facility: ${event.facility}'),
            Text('Input: ${event.formattedReceived} → Output: ${event.formattedProcessed}'),
            Text('Loss: ${event.formattedLoss} (${event.lossPercentage.toStringAsFixed(1)}%)'),
          ],
        ),
        trailing: _buildStatusChip(event.status),
        onTap: () {},
      ),
    );
  }

  Widget _buildManufacturingCard(ManufacturingEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.factory, color: Colors.orange),
        ),
        title: Text('${event.productType.capitalize()}', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manufacturer: ${event.manufacturerName}'),
            Text('Batch: ${event.batchNumber}'),
            Text('Input: ${event.formattedInput} → Output: ${event.formattedOutput} (Yield: ${event.yieldPercentage.toStringAsFixed(1)}%)'),
          ],
        ),
        trailing: _buildStatusChip(event.status),
        onTap: () {},
      ),
    );
  }

  Widget _buildTimelineCard(BatchEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getEventColor(event.eventType).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_getEventIcon(event.eventType), color: _getEventColor(event.eventType)),
        ),
        title: Text(event.eventType.capitalize(), style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.status.capitalize()),
            Text(_formatDateTime(event.timestamp)),
            if (event.metadataJson.isNotEmpty)
              Text('Details: ${event.metadataJson.toString()}'),
          ],
        ),
        trailing: _buildStatusChip(event.status),
        onTap: () {},
      ),
    );
  }

  Color _getEventColor(String eventType) {
    switch (eventType) {
      case 'COLLECTION': return Colors.green;
      case 'PROCESSING': return Colors.blue;
      case 'LAB': return Colors.purple;
      case 'MANUFACTURING': return Colors.orange;
      case 'QR_GENERATED': return Colors.teal;
      default: return Colors.grey;
    }
  }

  IconData _getEventIcon(String eventType) {
    switch (eventType) {
      case 'COLLECTION': return Icons.eco;
      case 'PROCESSING': return Icons.precision_manufacturing;
      case 'LAB': return Icons.science;
      case 'MANUFACTURING': return Icons.factory;
      case 'QR_GENERATED': return Icons.qr_code;
      default: return Icons.circle;
    }
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Batch not found', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
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
          Text('Failed to load batch', style: TextStyle(fontSize: 18, color: Colors.red[700])),
          const SizedBox(height: 8),
          Text(_error ?? 'Unknown error', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadBatch,
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

  String _formatDate(String dateStr) {
    try {
      return DateTime.parse(dateStr).toLocal().toString().split('.')[0];
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