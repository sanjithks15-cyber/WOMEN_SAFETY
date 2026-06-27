import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/api_service.dart';
import '../services/socket_client_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  String _errorMessage = '';
  String _verificationId = '';
  String _phoneNumber = '';
  bool _mockUserLoggedIn = false;
  Map<String, dynamic>? _backendUser;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get phoneNumber => _phoneNumber;
  User? get currentUser => _authService.currentUser;
  bool get isAuthenticated => _mockUserLoggedIn || currentUser != null;
  Map<String, dynamic>? get backendUser => _backendUser;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> sendOTP(String phoneNumber, VoidCallback onCodeSent) async {
    _setLoading(true);
    _setError('');
    _phoneNumber = phoneNumber;

    // Mock bypass for hackathon presentation
    if (true) { // Always use mock
      await Future.delayed(const Duration(milliseconds: 800));
      _verificationId = "mock_verification_id";
      _setLoading(false);
      onCodeSent();
      return;
    }

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _signInAndCreateUser(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _setLoading(false);
          _setError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _setLoading(false);
          onCodeSent();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
    }
  }

  Future<String?> verifyOTP(String otp) async {
    _setLoading(true);
    _setError('');

    try {
      String phoneNo = _phoneNumber;
      if (phoneNo.isEmpty) {
        phoneNo = "+917019487484"; // Fallback for debugging
      }

      if (_verificationId == "mock_verification_id") {
        await Future.delayed(const Duration(milliseconds: 800));
        _mockUserLoggedIn = true;
      } else if (_verificationId.isEmpty) {
        throw Exception("Verification ID is missing. Request OTP first.");
      } else {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId,
          smsCode: otp,
        );
        await _signInAndCreateUser(credential);
      }

      // Synchronize session with backend API
      final apiService = ApiService.instance;
      var result = await apiService.login(phoneNo, '123456'); // Using a dummy pin for hackathon
      
      if (result == null) {
        // User not found, need onboarding
        _setLoading(false);
        return "NEW_USER";
      }

      _backendUser = result['user'];
      final userId = _backendUser!['id'];
      
      // Initialize real-time WebSocket connection
      SocketClientService.instance.connect(userId);

      _setLoading(false);
      notifyListeners();
      return "SUCCESS";
    } catch (e) {
      _setLoading(false);
      _setError('Failed to authenticate with backend: ${e.toString()}');
      return null;
    }
  }

  Future<bool> registerNewUser(String name, String pin) async {
    _setLoading(true);
    _setError('');
    
    try {
      final apiService = ApiService.instance;
      String phoneNo = _phoneNumber;
      if (phoneNo.isEmpty) {
        phoneNo = "+917019487484"; // Fallback for debugging
      }

      final result = await apiService.register(phoneNo, name, pin);
      if (result != null) {
        _backendUser = result['user'];
        SocketClientService.instance.connect(_backendUser!['id']);
        _setLoading(false);
        notifyListeners();
        return true;
      }
      
      _setError('Failed to register user.');
      _setLoading(false);
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Registration error: ${e.toString()}');
      return false;
    }
  }

  /// Helper to sign in and update Firestore
  Future<void> _signInAndCreateUser(PhoneAuthCredential credential) async {
    final userCredential = await _authService.signInWithCredential(credential);
    final user = userCredential.user;
    
    if (user != null) {
      await _firestoreService.createUserOrUpdateLogin(
        user.uid,
        user.phoneNumber ?? _phoneNumber,
      );
    }
  }

  Future<void> tryAutoLogin() async {
    final apiService = ApiService.instance;
    final cached = await apiService.getCachedUser();
    final token = await apiService.getToken();
    if (cached != null && token != null) {
      _backendUser = cached;
      _mockUserLoggedIn = true;
      SocketClientService.instance.connect(cached['id']);
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _mockUserLoggedIn = false;
    _backendUser = null;
    await _authService.signOut();
    await ApiService.instance.clearAuth();
    SocketClientService.instance.disconnect();
    notifyListeners();
  }
}
