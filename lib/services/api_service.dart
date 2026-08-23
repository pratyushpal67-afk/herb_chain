import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../models/batch.dart';
import '../models/lab.dart';
import '../models/processing.dart';
import '../models/manufacturing.dart';
import '../models/public.dart';
import '../models/sync.dart';
import '../models/ledger.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api';
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final SharedPreferences _prefs;

  ApiService(this._prefs);

  String? _accessToken;
  String? _refreshToken;
  User? _currentUser;

  User? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  bool get isAuthenticated => _accessToken != null && _currentUser != null;

  Future<void> initialize() async {
    _accessToken = await _secureStorage.read(key: _authTokenKey);
    _refreshToken = await _secureStorage.read(key: _refreshTokenKey);
    final userData = await _secureStorage.read(key: _userDataKey);
    if (userData != null) {
      _currentUser = User.fromJson(json.decode(userData));
    }
  }

  Future<void> _saveAuthData(AuthTokens authTokens) async {
    _accessToken = authTokens.access;
    _refreshToken = authTokens.refresh;
    _currentUser = authTokens.user;
    await _secureStorage.write(key: _authTokenKey, value: authTokens.access);
    await _secureStorage.write(key: _refreshTokenKey, value: authTokens.refresh);
    await _secureStorage.write(key: _userDataKey, value: json.encode(authTokens.user.toJson()));
  }

  Future<void> _clearAuthData() async {
    _accessToken = null;
    _refreshToken = null;
    _currentUser = null;
    await _secureStorage.delete(key: _authTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _userDataKey);
  }

  Future<AuthTokens> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final authTokens = AuthTokens.fromJson(json.decode(response.body));
      await _saveAuthData(authTokens);
      return authTokens;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Login failed');
    }
  }

  Future<AuthTokens> register(String username, String email, String password, String role, String phone) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
        'role': role,
        'phone': phone,
      }),
    );

    if (response.statusCode == 201) {
      final authTokens = AuthTokens.fromJson(json.decode(response.body));
      await _saveAuthData(authTokens);
      return authTokens;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Registration failed');
    }
  }

  Future<void> logout() async {
    await _clearAuthData();
  }

  Future<User> getCurrentUser() async {
    if (_currentUser != null) return _currentUser!;
    
    if (_accessToken == null) throw Exception('Not authenticated');
    
    final response = await http.get(
      Uri.parse('$_baseUrl/auth/me/'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      _currentUser = User.fromJson(json.decode(response.body));
      return _currentUser!;
    } else {
      throw Exception('Failed to get user');
    }
  }

  Map<String, String> _getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_accessToken',
    };
  }

  Map<String, String> _getMultipartAuthHeaders() {
    return {
      'Authorization': 'Bearer $_accessToken',
    };
  }

  // ==================== HERBS ====================
  Future<List<Herb>> getHerbs() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/herbs/'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Herb.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load herbs');
    }
  }

  // ==================== COLLECTORS ====================
  Future<List<Collector>> getCollectors() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/collectors/'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Collector.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load collectors');
    }
  }

  // ==================== BATCHES ====================
  Future<Batch> createCollection({
    required String herbId,
    required String quantityKg,
    required String latitude,
    required String longitude,
    required String gpsAccuracy,
    required String capturedAt,
    String? clientEventId,
    File? photo,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/collection/'));
    request.headers.addAll(_getMultipartAuthHeaders());
    request.fields['herb_id'] = herbId;
    request.fields['quantity_kg'] = quantityKg;
    request.fields['latitude'] = latitude;
    request.fields['longitude'] = longitude;
    request.fields['gps_accuracy'] = gpsAccuracy;
    request.fields['captured_at'] = capturedAt;
    if (clientEventId != null) {
      request.fields['client_event_id'] = clientEventId;
    }
    if (photo != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', photo.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return Batch.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to create collection');
    }
  }

  Future<Batch> getBatch(String batchId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/batches/$batchId/'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return Batch.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load batch');
    }
  }

  Future<List<Batch>> getBatches({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/batches/?page=$page'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'] ?? data;
      return results.map((e) => Batch.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load batches');
    }
  }

  Future<void> sendBatchToLab(String batchId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/batches/$batchId/send_to_lab/'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to send to lab');
    }
  }

  // ==================== LAB ====================
  Future<List<LabReport>> getLabReports() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/lab-reports/'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['results'] ?? json.decode(response.body);
      return data.map((e) => LabReport.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load lab reports');
    }
  }

  Future<LabReport> createLabReport({
    required String batchId,
    required String sampleName,
    required String botanicalName,
    required String collectionDate,
    required String receivedDate,
    required String testDate,
    String overallResult = 'pending',
    String? notes,
    List<Map<String, dynamic>>? testResults,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/batches/$batchId/lab-report/'),
      headers: _getAuthHeaders(),
      body: json.encode({
        'batch_id': batchId,
        'sample_name': sampleName,
        'botanical_name': botanicalName,
        'collection_date': collectionDate,
        'received_date': receivedDate,
        'test_date': testDate,
        'overall_result': overallResult,
        'notes': notes ?? '',
        'test_results': testResults ?? [],
      }),
    );

    if (response.statusCode == 201) {
      return LabReport.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Failed to create lab report');
    }
  }

  Future<LabReport> getLabReport(String batchId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/batches/$batchId/lab-report/'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        return LabReport.fromJson(data.first);
      }
      throw Exception('No lab report found');
    } else {
      throw Exception('Failed to load lab report');
    }
  }

  Future<LabTest> submitLabTestResult({
    required String labTestId,
    required String result,
    String? moistureContent,
    String? purityPercentage,
    String? heavyMetalsPpm,
    String? pesticideResiduePpm,
    String? microbialCountCfu,
    String? notes,
    File? certificateFile,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/lab-tests/$labTestId/submit_result/'));
    request.headers.addAll(_getMultipartAuthHeaders());
    request.fields['result'] = result;
    if (moistureContent != null) request.fields['moisture_content'] = moistureContent;
    if (purityPercentage != null) request.fields['purity_percentage'] = purityPercentage;
    if (heavyMetalsPpm != null) request.fields['heavy_metals_ppm'] = heavyMetalsPpm;
    if (pesticideResiduePpm != null) request.fields['pesticide_residue_ppm'] = pesticideResiduePpm;
    if (microbialCountCfu != null) request.fields['microbial_count_cfu'] = microbialCountCfu;
    if (notes != null) request.fields['notes'] = notes;
    if (certificateFile != null) {
      request.files.add(await http.MultipartFile.fromPath('certificate_file', certificateFile.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return LabTest.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to submit lab test result');
    }
  }

  Future<List<LabTest>> getLabTests() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/lab-tests/'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => LabTest.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load lab tests');
    }
  }

  // ==================== PROCESSING ====================
  Future<ProcessingEvent> createProcessing(ProcessingCreateRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/batches/${request.batchId}/processing/'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return ProcessingEvent.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to create processing');
    }
  }

  Future<void> completeProcessing(String processingId, String outputQuantityKg, String? notes) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/processing/$processingId/complete/'),
      headers: _getAuthHeaders(),
      body: json.encode({
        'processing_id': processingId,
        'processed_quantity_kg': outputQuantityKg,
        'notes': notes ?? '',
      }),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to complete processing');
    }
  }

  // ==================== MANUFACTURING ====================
  Future<List<Manufacturer>> getManufacturers() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/manufacturers/'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Manufacturer.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load manufacturers');
    }
  }

  Future<ManufacturingEvent> createManufacturing(ManufacturingCreateRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/batches/${request.batchId}/manufacturing/'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return ManufacturingEvent.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to create manufacturing');
    }
  }

  Future<void> completeManufacturing(String manufacturingId, String outputQuantityKg, String? notes) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/manufacturing/$manufacturingId/complete/'),
      headers: _getAuthHeaders(),
      body: json.encode({
        'manufacturing_id': manufacturingId,
        'output_quantity_kg': outputQuantityKg,
        'notes': notes ?? '',
      }),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to complete manufacturing');
    }
  }

  // ==================== LEDGER/HASH ====================
  Future<Map<String, dynamic>> buildMerkleTree(String batchId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/batches/$batchId/hash/'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to build Merkle tree');
    }
  }

  Future<Map<String, dynamic>> getMerkleTree(String batchId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/batches/$batchId/hash/'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get Merkle tree');
    }
  }

  Future<Map<String, dynamic>> submitToLedger(String batchId, {String? fromAddress, String? toAddress}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/batches/$batchId/ledger/tx/'),
      headers: _getAuthHeaders(),
      body: json.encode({
        'from_address': fromAddress,
        'to_address': toAddress,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to submit to ledger');
    }
  }

  Future<List<LedgerTransaction>> getLedgerTransactions(String batchId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/batches/$batchId/ledger/tx/'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => LedgerTransaction.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load ledger transactions');
    }
  }

  Future<Map<String, dynamic>> createBatchHash({
    required String batchId,
    required String hashType,
    required String algorithm,
    required Map<String, dynamic> sourceData,
    String? sourceReference,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/batches/$batchId/hashes/'),
      headers: _getAuthHeaders(),
      body: json.encode({
        'batch_id': batchId,
        'hash_type': hashType,
        'algorithm': algorithm,
        'source_data': sourceData,
        'source_reference': sourceReference,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to create hash');
    }
  }

  Future<Map<String, dynamic>> verifyBatchHash({
    required String batchId,
    required String hashType,
    required String expectedHash,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/batches/verify-hash/'),
      headers: _getAuthHeaders(),
      body: json.encode({
        'batch_id': batchId,
        'hash_type': hashType,
        'expected_hash': expectedHash,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to verify hash');
    }
  }

  Future<Map<String, dynamic>> confirmLedgerTransaction({
    required String transactionId,
    required int blockNumber,
    String? blockHash,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/ledger/$transactionId/confirm/'),
      headers: _getAuthHeaders(),
      body: json.encode({
        'block_number': blockNumber,
        'block_hash': blockHash ?? '',
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to confirm transaction');
    }
  }

  // ==================== PUBLIC API ====================
  Future<PublicBatch> getPublicBatch(String batchId) async {
    final response = await http.get(Uri.parse('$_baseUrl/public/batches/$batchId/'));
    if (response.statusCode == 200) {
      return PublicBatch.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Batch not found');
    } else {
      throw Exception('Failed to load batch');
    }
  }

  Future<PublicBatchJourney> getPublicBatchJourney(String batchId) async {
    final response = await http.get(Uri.parse('$_baseUrl/public/batches/$batchId/journey/'));
    if (response.statusCode == 200) {
      return PublicBatchJourney.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load journey');
    }
  }

  Future<Map<String, dynamic>> getPublicBatchVerify(String batchId) async {
    final response = await http.get(Uri.parse('$_baseUrl/public/batches/$batchId/verify/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to verify batch');
    }
  }

  Future<Map<String, dynamic>> getPublicBatchQr(String batchId) async {
    final response = await http.get(Uri.parse('$_baseUrl/public/batches/$batchId/qr/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to generate QR');
    }
  }

  // ==================== SYNC ====================
  Future<PendingSyncResponse> getPendingSync() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/sync/pending/'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return PendingSyncResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get pending sync');
    }
  }

  Future<SyncResult> syncCollectionEvents(List<Map<String, dynamic>> events) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/sync/collection/'),
      headers: _getAuthHeaders(),
      body: json.encode({'events': events}),
    );

    if (response.statusCode == 200) {
      return SyncResult.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to sync collection events');
    }
  }

  Future<List<SyncLog>> getSyncHistory() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/sync/history/'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => SyncLog.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load sync history');
    }
  }
}