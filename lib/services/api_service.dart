import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api';
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final SharedPreferences _prefs;

  ApiService(this._prefs);

  String? get accessToken => _prefs.getString(_authTokenKey);

  Map<String, String> _getHeaders({bool requireAuth = false}) {
    final headers = {'Content-Type': 'application/json'};
    if (requireAuth && accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  // Login
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: _getHeaders(),
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['access'] != null) {
          await _prefs.setString(_authTokenKey, data['access']);
          await _secureStorage.write(key: _refreshTokenKey, value: data['refresh'] ?? '');
        }
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Login failed (${response.statusCode})'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Register - Positional method signature matching auth_provider
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
    String role,
    String phone,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: _getHeaders(),
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'role': role,
          'phone': phone,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Registration failed (${response.statusCode})'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Logout
  Future<void> logout() async {
    await _prefs.remove(_authTokenKey);
    await _prefs.remove(_userDataKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }
}