import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  
  AuthProvider(this._apiService);

  User? _user;
  String? _accessToken;
  String? _refreshToken;
  bool _isLoading = false;
  String? _error;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  User? get user => _user;
  String? get accessToken => _accessToken;
  bool get isAuthenticated => _accessToken != null && _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isCollector => _user?.isCollector ?? false;
  bool get isLab => _user?.isLab ?? false;
  bool get isManufacturer => _user?.isManufacturer ?? false;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isCustomer => _user?.isCustomer ?? false;
  
  ApiService get apiService => _apiService;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  TextEditingController get usernameController => _usernameController;
  TextEditingController get passwordController => _passwordController;

  Future<void> initialize() async {
    await _apiService.initialize();
    _accessToken = _apiService.accessToken;
    _user = _apiService.currentUser;
    notifyListeners();
  }

  void _togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void _toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final authTokens = await _apiService.login(username, password);
      _accessToken = authTokens.access;
      _refreshToken = authTokens.refresh;
      _user = authTokens.user;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String role,
    required String phone,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final authTokens = await _apiService.register(
        username: username,
        email: email,
        password: password,
        role: role,
        phone: phone,
      );
      _accessToken = authTokens.access;
      _refreshToken = authTokens.refresh;
      _user = authTokens.user;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    _accessToken = null;
    _refreshToken = null;
    _user = null;
    _usernameController.clear();
    _passwordController.clear();
    notifyListeners();
  }

  Future<void> refreshUser() async {
    try {
      final user = await _apiService.getCurrentUser();
      _user = user;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}