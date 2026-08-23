import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/sync.dart';
import '../utils/constants.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PendingSyncResponse? _pendingSync;
  List<SyncLog> _syncHistory = [];
  bool _isLoading = false;
  bool _isSyncing = false;
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
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<AuthProvider>()._apiService;
      await Future.wait([
        _loadPendingSync(apiService),
        _loadSyncHistory(apiService),
      ]);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPendingSync(ApiService apiService) async {
    final pending = await apiService.getPendingSync();
    if (mounted) setState(() => _pendingSync = pending);
  }

  Future<void> _loadSyncHistory(ApiService apiService) async {
    final history = await apiService.getSyncHistory();
    if (mounted) setState(() => _syncHistory = history);
  }

  Future<void> _syncNow() async {
    if (_pendingSync == null || _pendingSync!.collectionEvents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pending events to sync')),
      );
      return;
    }

    setState(() => _isSyncing = true);

    try {
      final apiService = context.read<AuthProvider>()._apiService;
      final events = _pendingSync!.collectionEvents.map((e) => e.toJson()).toList();
      final result = await apiService.syncCollectionEvents(events);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.success
                  ? 'Synced ${result.eventsSynced} events successfully'
                  : 'Sync completed with ${result.eventsFailed} failures',
            ),
            backgroundColor: result.success ? Colors.green : Colors.orange,
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Sync'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.cloud_upload), text: 'Pending'),
            Tab(icon: Icon(Icons.history), text: 'History'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? _buildErrorState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPendingTab(),
                    _buildHistoryTab(),
                  ],
                ),
    );
  }

  Widget _buildPendingTab() {
    final pendingEvents = _pendingSync?.collectionEvents ?? [];
    final pendingCount = _pendingSync?.pendingCount ?? 0;
    final lastSync = _pendingSync?.lastSync;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: AppColors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.cloud_queue, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Pending Sync',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '$pendingCount events waiting to sync',
                style: TextStyle(color: Colors.grey[600]),
              ),
              if (lastSync != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Last sync: ${_formatDateTime(lastSync)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (_isSyncing || pendingEvents.isEmpty) ? null : _syncNow,
                  icon: _isSyncing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_upload),
                  label: Text(_isSyncing ? 'Syncing...' : 'Sync Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: pendingEvents.isEmpty
              ? _buildEmptyState('No pending events to sync')
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: pendingEvents.length,
                    itemBuilder: (context, index) => _buildPendingEventCard(pendingEvents[index]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPendingEventCard(CollectionEventSync event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
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
                    color: _getSyncStatusColor(event.syncStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getSyncStatusIcon(event.syncStatus),
                    color: _getSyncStatusColor(event.syncStatus),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.herbName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '${event.collectorName} • ${event.quantityKg} kg',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                _buildSyncStatusChip(event.syncStatus),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Event ID', event.eventId),
            _buildInfoRow('Batch ID', event.batchId),
            _buildInfoRow('Captured', _formatDateTime(event.capturedAt)),
            _buildInfoRow('GPS', 'Lat: ${event.latitude}, Lng: ${event.longitude}'),
            _buildInfoRow('Accuracy', '±${event.gpsAccuracyM}m'),
            if (event.clientEventId != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow('Client ID', event.clientEventId!),
            ],
            if (event.syncError.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, size: 16, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.syncError,
                        style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (event.lastSyncAttempt != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow('Last Attempt', _formatDateTime(event.lastSyncAttempt!)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_syncHistory.isEmpty) {
      return _buildEmptyState('No sync history yet');
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _syncHistory.length,
        itemBuilder: (context, index) => _buildHistoryCard(_syncHistory[index]),
      ),
    );
  }

  Widget _buildHistoryCard(SyncLog log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _getSyncLogColor(log.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getSyncLogIcon(log.status),
            color: _getSyncLogColor(log.status),
            size: 24,
          ),
        ),
        title: Text(log.syncId, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${log.collectorName} • ${log.syncType.capitalize()}'),
            Text('Processed: ${log.eventsProcessed} • Synced: ${log.eventsSynced} • Failed: ${log.eventsFailed}'),
            Text(_formatDateTime(log.startedAt)),
          ],
        ),
        trailing: _buildSyncStatusChip(log.status),
        onTap: () => _showSyncDetails(log),
      ),
    );
  }

  void _showSyncDetails(SyncLog log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
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
                Text(log.syncId, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildSyncStatusChip(log.status),
                const SizedBox(height: 16),
                _buildInfoRow('Collector', log.collectorName),
                _buildInfoRow('Type', log.syncType.capitalize()),
                _buildInfoRow('Status', log.status.capitalize()),
                _buildInfoRow('Started', _formatDateTime(log.startedAt)),
                if (log.completedAt != null) _buildInfoRow('Completed', _formatDateTime(log.completedAt!)),
                _buildInfoRow('Events Processed', log.eventsProcessed.toString()),
                _buildInfoRow('Events Synced', log.eventsSynced.toString()),
                _buildInfoRow('Events Failed', log.eventsFailed.toString()),
                _buildInfoRow('Events Conflicts', log.eventsConflicts.toString()),
                if (log.errorSummary.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Errors', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(log.errorSummary, style: TextStyle(color: Colors.red.shade700)),
                ],
              ],
            ),
          ),
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

  Widget _buildSyncStatusChip(String status) {
    final color = _getSyncStatusColor(status);
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

  Color _getSyncStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'synced': return Colors.green;
      case 'conflict': return Colors.red;
      case 'failed': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getSyncStatusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.schedule;
      case 'synced': return Icons.check_circle;
      case 'conflict': return Icons.warning;
      case 'failed': return Icons.error;
      default: return Icons.help;
    }
  }

  Color _getSyncLogColor(String status) {
    switch (status) {
      case 'started': return Colors.blue;
      case 'completed': return Colors.green;
      case 'partial': return Colors.orange;
      case 'failed': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getSyncLogIcon(String status) {
    switch (status) {
      case 'started': return Icons.play_circle;
      case 'completed': return Icons.check_circle;
      case 'partial': return Icons.warning;
      case 'failed': return Icons.error;
      default: return Icons.help;
    }
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(fontSize: 18, color: Colors.grey[600])),
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
          Text('Failed to load sync data', style: TextStyle(fontSize: 18, color: Colors.red[700])),
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