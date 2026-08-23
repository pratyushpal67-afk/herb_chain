import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/manufacturing.dart';
import '../utils/constants.dart';

class ManufacturerScreen extends StatefulWidget {
  @override
  State<ManufacturerScreen> createState() => _ManufacturerScreenState();
}

class _ManufacturerScreenState extends State<ManufacturerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ManufacturingEvent> _manufacturingEvents = [];
  List<Manufacturer> _manufacturers = [];
  bool _isLoading = false;
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
        _loadManufacturingEvents(),
        _loadManufacturers(),
      ]);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadManufacturingEvents() async {
    final apiService = context.read<AuthProvider>()._apiService;
    final batches = await apiService.getBatches();
    final List<ManufacturingEvent> allEvents = [];
    for (final batch in batches) {
      allEvents.addAll(batch.manufacturingEvents);
    }
    setState(() => _manufacturingEvents = allEvents);
  }

  Future<void> _loadManufacturers() async {
    final apiService = context.read<AuthProvider>()._apiService;
    _manufacturers = await apiService.getManufacturers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manufacturing'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Events'),
            Tab(icon: Icon(Icons.factory), text: 'Manufacturers'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _error != null
              ? _buildErrorState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildEventsTab(),
                    _buildManufacturersTab(),
                  ],
                ),
    );
  }

  Widget _buildEventsTab() {
    if (_manufacturingEvents.isEmpty) {
      return _buildEmptyState('No manufacturing events yet');
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _manufacturingEvents.length,
        itemBuilder: (context, index) => _buildEventCard(_manufacturingEvents[index]),
      ),
    );
  }

  Widget _buildManufacturersTab() {
    if (_manufacturers.isEmpty) {
      return _buildEmptyState('No manufacturers registered');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _manufacturers.length,
      itemBuilder: (context, index) => _buildManufacturerCard(_manufacturers[index]),
    );
  }

  Widget _buildEventCard(ManufacturingEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showEventDetails(event),
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
                      color: _getEventColor(event.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.factory,
                      color: _getEventColor(event.status),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.manufacturingId,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          '${event.productType.capitalize()} • ${event.manufacturerName}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(event.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoColumn('Input', event.formattedInput, Icons.input),
                  ),
                  Expanded(
                    child: _buildInfoColumn('Output', event.formattedOutput, Icons.output),
                  ),
                  Expanded(
                    child: _buildInfoColumn('Loss', event.formattedLoss, Icons.remove),
                  ),
                  Expanded(
                    child: _buildInfoColumn('Yield', '${event.yieldPercentage.toStringAsFixed(1)}%', Icons.trending_up),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow('Facility', event.manufacturerName),
              _buildInfoRow('Product Type', event.productType.capitalize()),
              _buildInfoRow('Batch Number', event.batchNumber.isNotEmpty ? event.batchNumber : 'N/A'),
              if (event.expiryDate != null)
                _buildInfoRow('Expiry', _formatDate(event.expiryDate!)),
              if (event.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow('Notes', event.notes),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManufacturerCard(Manufacturer manufacturer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.factory, color: AppColors.primary, size: 24),
        ),
        title: Text(manufacturer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('License: ${manufacturer.licenseNumber}'),
            Text('${manufacturer.address}'),
            Text('Contact: ${manufacturer.contactPerson}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: manufacturer.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: manufacturer.isActive ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3)),
          ),
          child: Text(
            manufacturer.isActive ? 'Active' : 'Inactive',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: manufacturer.isActive ? Colors.green : Colors.red),
          ),
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
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

  Color _getEventColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'in_progress': return Colors.blue;
      case 'completed': return Colors.green;
      case 'failed': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _formatDate(String dateStr) {
    try {
      return DateTime.parse(dateStr).toLocal().toString().split('.')[0];
    } catch (_) {
      return dateStr;
    }
  }

  void _showEventDetails(ManufacturingEvent event) {
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
                Text(event.manufacturingId, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildStatusChip(event.status),
                const SizedBox(height: 16),
                _buildInfoRow('Product Type', event.productType.capitalize()),
                _buildInfoRow('Manufacturer', event.manufacturerName),
                _buildInfoRow('Input Quantity', event.formattedInput),
                _buildInfoRow('Output Quantity', event.formattedOutput),
                _buildInfoRow('Loss', event.formattedLoss),
                _buildInfoRow('Yield', '${event.yieldPercentage.toStringAsFixed(1)}%'),
                _buildInfoRow('Batch Number', event.batchNumber.isNotEmpty ? event.batchNumber : 'N/A'),
                if (event.expiryDate != null) _buildInfoRow('Expiry Date', _formatDate(event.expiryDate!)),
                _buildInfoRow('Manufacturing Date', _formatDate(event.manufacturingDate)),
                if (event.completedAt != null) _buildInfoRow('Completed At', _formatDateTime(event.completedAt!)),
                _buildInfoRow('Status', event.status.capitalize()),
                if (event.notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(event.notes),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.factory_outlined, size: 80, color: Colors.grey[300]),
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