import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/ledger.dart';
import '../utils/constants.dart';

class LedgerScreen extends StatefulWidget {
  final String batchId;

  const LedgerScreen({super.key, required this.batchId});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  MerkleTree? _merkleTree;
  List<LedgerTransaction> _transactions = [];
  List<BatchHash> _hashes = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      final apiService = context.read<AuthProvider>().apiService;
      await Future.wait([
        _loadMerkleTree(apiService),
        _loadTransactions(apiService),
        _loadHashes(apiService),
      ]);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMerkleTree(ApiService apiService) async {
    try {
      final data = await apiService.getMerkleTree(widget.batchId);
      if (mounted) setState(() => _merkleTree = MerkleTree.fromJson(data));
    } catch (_) {
      // Merkle tree might not exist yet
    }
  }

  Future<void> _loadTransactions(ApiService apiService) async {
    final txs = await apiService.getLedgerTransactions(widget.batchId);
    if (mounted) setState(() => _transactions = txs);
  }

  Future<void> _loadHashes(ApiService apiService) async {
    // Hashes would be loaded from a separate endpoint if available
    // For now, we'll leave this empty
  }

  Future<void> _buildMerkleTree() async {
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<AuthProvider>().apiService;
      final data = await apiService.buildMerkleTree(widget.batchId);
      if (mounted) {
        setState(() => _merkleTree = MerkleTree.fromJson(data));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Merkle tree built successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to build Merkle tree: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitToLedger() async {
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<AuthProvider>().apiService;
      await apiService.submitToLedger(widget.batchId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submitted to ledger'), backgroundColor: Colors.green),
        );
        _loadTransactions(context.read<AuthProvider>().apiService);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit to ledger: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createBatchHash() async {
    _showCreateHashDialog();
  }

  Future<void> _showCreateHashDialog() async {
    final hashTypes = [
      'batch_data',
      'collection',
      'processing',
      'lab_report',
      'manufacturing',
      'full_batch',
      'photo',
      'document',
    ];
    
    final algorithms = ['sha256', 'sha512', 'keccak256'];
    
    String selectedHashType = 'batch_data';
    String selectedAlgorithm = 'sha256';
    final sourceDataController = TextEditingController(text: '{}');
    final sourceReferenceController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Batch Hash'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedHashType,
                  decoration: const InputDecoration(labelText: 'Hash Type', border: OutlineInputBorder()),
                  items: hashTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                  onChanged: (value) => selectedHashType = value!,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedAlgorithm,
                  decoration: const InputDecoration(labelText: 'Algorithm', border: OutlineInputBorder()),
                  items: algorithms.map((algo) => DropdownMenuItem(value: algo, child: Text(algo))).toList(),
                  onChanged: (value) => selectedAlgorithm = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: sourceDataController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Source Data (JSON)',
                    border: OutlineInputBorder(),
                    hintText: '{"key": "value"}',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: sourceReferenceController,
                  decoration: const InputDecoration(
                    labelText: 'Source Reference (Optional)',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., collection_event_1',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _submitCreateHash(
                hashType: selectedHashType,
                algorithm: selectedAlgorithm,
                sourceData: sourceDataController.text,
                sourceReference: sourceReferenceController.text,
              );
            },
            child: const Text('Create Hash'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitCreateHash({
    required String hashType,
    required String algorithm,
    required String sourceData,
    required String sourceReference,
  }) async {
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<AuthProvider>().apiService;
      
      Map<String, dynamic> parsedData;
      try {
        parsedData = sourceData.isNotEmpty ? json.decode(sourceData) : {};
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid JSON in source data'), backgroundColor: Colors.red),
        );
        return;
      }
      
      final result = await apiService.createBatchHash(
        batchId: widget.batchId,
        hashType: hashType,
        algorithm: algorithm,
        sourceData: parsedData,
        sourceReference: sourceReference.isNotEmpty ? sourceReference : null,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hash created: ${result['hashValue']}'), backgroundColor: Colors.green),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create hash: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyBatchHash() async {
    final hashTypes = [
      'batch_data',
      'collection',
      'processing',
      'lab_report',
      'manufacturing',
      'full_batch',
      'photo',
      'document',
    ];
    
    String selectedHashType = 'batch_data';
    final expectedHashController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Batch Hash'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedHashType,
                  decoration: const InputDecoration(labelText: 'Hash Type', border: OutlineInputBorder()),
                  items: hashTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                  onChanged: (value) => selectedHashType = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: expectedHashController,
                  decoration: const InputDecoration(
                    labelText: 'Expected Hash',
                    border: OutlineInputBorder(),
                    hintText: 'Enter hash to verify',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _submitVerifyHash(
                hashType: selectedHashType,
                expectedHash: expectedHashController.text,
              );
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitVerifyHash({
    required String hashType,
    required String expectedHash,
  }) async {
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<AuthProvider>().apiService;
      final result = await apiService.verifyBatchHash(
        batchId: widget.batchId,
        hashType: hashType,
        expectedHash: expectedHash,
      );
      
      if (mounted) {
        final verified = result['verified'] == true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(verified ? 'Hash verified successfully!' : 'Hash verification failed!'),
            backgroundColor: verified ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to verify hash: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmLedgerTransaction(LedgerTransaction tx) async {
    final blockNumberController = TextEditingController();
    final blockHashController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Ledger Transaction'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Transaction: ${tx.transactionHash}', style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: blockNumberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Block Number *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter block number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: blockHashController,
                  decoration: const InputDecoration(
                    labelText: 'Block Hash (Optional)',
                    border: OutlineInputBorder(),
                    hintText: 'Enter block hash if available',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (blockNumberController.text.isEmpty) return;
              Navigator.pop(context);
              await _submitConfirmTransaction(
                transactionId: tx.transactionId,
                blockNumber: int.parse(blockNumberController.text),
                blockHash: blockHashController.text.isNotEmpty ? blockHashController.text : null,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitConfirmTransaction({
    required String transactionId,
    required int blockNumber,
    String? blockHash,
  }) async {
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<AuthProvider>().apiService;
      await apiService.confirmLedgerTransaction(
        transactionId: transactionId,
        blockNumber: blockNumber,
        blockHash: blockHash,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction confirmed successfully'), backgroundColor: Colors.green),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to confirm transaction: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ledger: ${widget.batchId}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.account_tree), text: 'Merkle Tree'),
            Tab(icon: Icon(Icons.link), text: 'Transactions'),
            Tab(icon: Icon(Icons.fingerprint), text: 'Hashes'),
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
                    _buildMerkleTreeTab(),
                    _buildTransactionsTab(),
                    _buildHashesTab(),
                  ],
                ),
    );
  }

  Widget _buildMerkleTreeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_merkleTree == null) ...[
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.account_tree_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No Merkle Tree Yet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Build a Merkle tree to create a cryptographic proof of the batch data integrity.',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _buildMerkleTree,
                        icon: const Icon(Icons.build),
                        label: const Text('Build Merkle Tree'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
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
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.verified, color: Colors.green, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Merkle Tree Verified',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                'Root hash verified on ${_formatDate(_merkleTree!.createdAt)}',
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Tree ID', _merkleTree!.treeId, mono: true),
                    _buildDetailRow('Root Hash', _merkleTree!.rootHash, mono: true),
                    _buildDetailRow('Leaf Count', _merkleTree!.leafCount.toString()),
                    _buildDetailRow('Created', _formatDateTime(_merkleTree!.createdAt)),
                    const SizedBox(height: 16),
                    const Text(
                      'Tree Data',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        _merkleTree!.treeData.toString(),
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                      ),
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
                    const Text(
                      'Actions',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _submitToLedger,
                            icon: const Icon(Icons.link),
                            label: const Text('Submit to Ledger'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _createBatchHash,
                            icon: const Icon(Icons.fingerprint),
                            label: const Text('Create Hash'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _verifyBatchHash,
                            icon: const Icon(Icons.verified),
                            label: const Text('Verify Hash'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.purple,
                              side: const BorderSide(color: Colors.purple),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _buildMerkleTree,
                            icon: const Icon(Icons.account_tree),
                            label: const Text('Rebuild Merkle Tree'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.link_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No ledger transactions', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('Submit the batch to the ledger to create transactions', style: TextStyle(color: Colors.grey[500])),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _submitToLedger,
              icon: const Icon(Icons.link),
              label: const Text('Submit to Ledger'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _transactions.length,
        itemBuilder: (context, index) => _buildTransactionCard(_transactions[index]),
      ),
    );
  }

  Widget _buildTransactionCard(LedgerTransaction tx) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _getTxStatusColor(tx.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getTxStatusIcon(tx.status),
            color: _getTxStatusColor(tx.status),
            size: 24,
          ),
        ),
        title: Text(tx.transactionHash, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${tx.ledgerType.capitalize()}'),
            Text('Status: ${tx.status.capitalize()}'),
            Text('Submitted: ${_formatDateTime(tx.submittedAt)}'),
            if (tx.blockNumber != null) Text('Block: ${tx.blockNumber}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTxStatusChip(tx.status),
            if (tx.confirmedAt != null)
              Text('Confirmed', style: TextStyle(fontSize: 10, color: Colors.green[700])),
          ],
        ),
        onTap: () => _showTransactionDetails(tx),
      ),
    );
  }

  Widget _buildHashesTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fingerprint_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Batch Hashes', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('Create and verify cryptographic hashes for batch data integrity', style: TextStyle(color: Colors.grey[500]), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _createBatchHash,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Hash'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _verifyBatchHash,
                  icon: const Icon(Icons.verified),
                  label: const Text('Verify Hash'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.purple,
                    side: const BorderSide(color: Colors.purple),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetails(LedgerTransaction tx) {
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
                Text(tx.transactionId, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildTxStatusChip(tx.status),
                const SizedBox(height: 16),
                _buildDetailRow('Transaction Hash', tx.transactionHash, mono: true),
                _buildDetailRow('Type', tx.ledgerType.capitalize()),
                _buildDetailRow('Status', tx.status.capitalize()),
                _buildDetailRow('From', tx.fromAddress.isNotEmpty ? tx.fromAddress : 'N/A', mono: true),
                _buildDetailRow('To', tx.toAddress.isNotEmpty ? tx.toAddress : 'N/A', mono: true),
                if (tx.blockNumber != null) _buildDetailRow('Block Number', tx.blockNumber.toString()),
                if (tx.blockHash.isNotEmpty) _buildDetailRow('Block Hash', tx.blockHash, mono: true),
                _buildDetailRow('Submitted', _formatDateTime(tx.submittedAt)),
                if (tx.confirmedAt != null) _buildDetailRow('Confirmed', _formatDateTime(tx.confirmedAt!)),
                if (tx.errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Error', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[700])),
                  Text(tx.errorMessage, style: TextStyle(color: Colors.red[700])),
                ],
                if (tx.status == 'pending') ...[
                  const SizedBox(height: 16),
                  const Text('Admin Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _confirmLedgerTransaction(tx),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Confirm Transaction (Admin)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Text('Data Payload', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    tx.dataPayload.toString(),
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
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
            width: 100,
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

  Widget _buildTxStatusChip(String status) {
    final color = _getTxStatusColor(status);
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

  Color _getTxStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.green;
      case 'failed': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getTxStatusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.schedule;
      case 'confirmed': return Icons.check_circle;
      case 'failed': return Icons.error;
      default: return Icons.help;
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text('Failed to load ledger data', style: TextStyle(fontSize: 18, color: Colors.red[700])),
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