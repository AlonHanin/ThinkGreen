import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/api/api_client.dart';
import '../services/api/api_exception.dart';
import '../services/api/api_payload_utils.dart';
import '../services/api/auth_api_service.dart';
import '../services/api/integration_api_service.dart';
import '../services/oauth/oauth_flow_service.dart';

class SessionProvider with ChangeNotifier {
  SessionProvider({
    required AuthApiService authService,
    required IntegrationApiService integrationService,
    required ApiClient apiClient,
    required OAuthFlowService oauthFlowService,
  }) : _authService = authService,
       _integrationService = integrationService,
       _apiClient = apiClient,
       _oauthFlowService = oauthFlowService;

  final AuthApiService _authService;
  final IntegrationApiService _integrationService;
  final ApiClient _apiClient;
  final OAuthFlowService _oauthFlowService;

  AppUser _currentUser = AppUser.empty();
  bool _isAuthenticated = false;
  bool _isBusy = false;
  Locale _locale = const Locale('en');
  String? _authToken;

  AppUser get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get notificationsEnabled => _currentUser.notificationsEnabled;
  bool get isDarkMode => _currentUser.isDarkMode;
  bool get locationServicesEnabled => _currentUser.locationServicesEnabled;
  Locale get locale => _locale;
  String? get authToken => _authToken;
  bool get isBusy => _isBusy;
  bool get isAdmin => _currentUser.isAdmin;
  String get language => _locale.languageCode == 'he' ? 'Hebrew' : 'English';

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    final validationError = _validateSignIn(email: email, password: password);
    if (validationError != null) return validationError;

    return _wrapApiCall(() async {
      final payload = await _authService.signIn(
        email: email.trim(),
        password: password,
      );
      _applyAuthPayload(
        payload,
        fallbackPassword: password,
        fallbackEmail: email,
      );
      await _enrichUserFromProfile();
      return null;
    });
  }

  Future<String?> signInAdmin({
    required String email,
    required String password,
  }) async {
    final validationError = _validateSignIn(email: email, password: password);
    if (validationError != null) return validationError;

    return _wrapApiCall(() async {
      final payload = await _authService.signIn(
        email: email.trim(),
        password: password,
      );
      final token = extractToken(payload);
      final authUser = _buildAuthUser(
        payload,
        fallbackPassword: password,
        fallbackEmail: email,
      );
      if (!authUser.isAdmin) {
        return 'This account does not have admin access.';
      }

      _setAuthenticatedSession(token: token, user: authUser);
      return null;
    });
  }

  Future<String?> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String dateOfBirth,
    required String password,
    required String confirmPassword,
  }) async {
    final validationError = _validateSignUp(
      fullName: fullName,
      email: email,
      phone: phone,
      dateOfBirth: dateOfBirth,
      password: password,
      confirmPassword: confirmPassword,
    );
    if (validationError != null) return validationError;

    return _wrapApiCall(() async {
      final payload = await _authService.signUp(
        fullName: fullName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        dateOfBirth: dateOfBirth.trim(),
        password: password,
        confirmPassword: confirmPassword,
        locale: _locale.languageCode,
      );
      _applyAuthPayload(
        payload,
        fallbackPassword: password,
        fallbackFullName: fullName,
        fallbackEmail: email,
        fallbackPhone: phone,
        fallbackDob: _parseDate(dateOfBirth),
      );
      await _enrichUserFromProfile();
      return null;
    });
  }

  Future<String?> signInWithGoogle() async {
    return _wrapApiCall(() async {
      final payload = await _authenticateWithOAuth(
        provider: 'google',
        purpose: 'login',
      );
      _applyAuthPayload(payload);
      await _enrichUserFromProfile();
      return null;
    });
  }

  Future<String?> requestResetPin(String email) async {
    if (!_isValidEmail(email)) {
      return 'Please enter a valid email address.';
    }

    return _wrapApiCall(() async {
      await _authService.requestResetPin(email.trim());
      return null;
    });
  }

  Future<String?> verifySecurityPin({
    required String email,
    required String pin,
  }) async {
    if (pin.trim().isEmpty) {
      return 'Enter PIN';
    }

    return _wrapApiCall(() async {
      await _authService.verifyResetPin(email: email.trim(), pin: pin.trim());
      return null;
    });
  }

  Future<String?> resetPassword({
    required String email,
    required String pin,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword.length < 6) {
      return 'Password must contain at least 6 characters.';
    }
    if (newPassword != confirmPassword) {
      return 'Passwords do not match.';
    }

    return _wrapApiCall(() async {
      await _authService.resetPassword(
        email: email.trim(),
        pin: pin.trim(),
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      _isAuthenticated = false;
      _authToken = null;
      _apiClient.setToken(null);
      notifyListeners();
      return null;
    });
  }

  Future<String?> updateProfile({
    required String fullName,
    required String email,
    required String phone,
  }) async {
    final validationError = _validateProfile(
      fullName: fullName,
      email: email,
      phone: phone,
    );
    if (validationError != null) return validationError;

    return _wrapApiCall(() async {
      try {
        final payload = await _authService.updateProfile(
          fullName: fullName.trim(),
          email: email.trim(),
          phone: phone.trim(),
        );
        final parsedUser = AppUser.fromApi(payload);
        _currentUser = _currentUser.copyWith(
          fullName:
              parsedUser.fullName.isEmpty
                  ? fullName.trim()
                  : parsedUser.fullName,
          email: parsedUser.email.isEmpty ? email.trim() : parsedUser.email,
          phone: parsedUser.phone.isEmpty ? phone.trim() : parsedUser.phone,
          dateOfBirth: parsedUser.dateOfBirth ?? _currentUser.dateOfBirth,
          avatarUrl:
              parsedUser.avatarUrl.isEmpty
                  ? _currentUser.avatarUrl
                  : parsedUser.avatarUrl,
          role: parsedUser.role.isEmpty ? _currentUser.role : parsedUser.role,
          notificationsEnabled: parsedUser.notificationsEnabled,
          isDarkMode: parsedUser.isDarkMode,
          locationServicesEnabled: parsedUser.locationServicesEnabled,
          preferredLanguage:
              parsedUser.preferredLanguage.isEmpty
                  ? _currentUser.preferredLanguage
                  : parsedUser.preferredLanguage,
        );
      } catch (_) {
        _currentUser = _currentUser.copyWith(
          fullName: fullName.trim(),
          email: email.trim(),
          phone: phone.trim(),
        );
      }

      notifyListeners();
      return null;
    });
  }

  void setNotificationsEnabled(bool value) {
    _currentUser = _currentUser.copyWith(notificationsEnabled: value);
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _currentUser = _currentUser.copyWith(isDarkMode: value);
    notifyListeners();
  }

  void setLocationServicesEnabled(bool value) {
    _currentUser = _currentUser.copyWith(locationServicesEnabled: value);
    notifyListeners();
  }

  void setLocale(Locale value) {
    if (_locale == value) return;
    _locale = value;
    _currentUser = _currentUser.copyWith(preferredLanguage: value.languageCode);
    notifyListeners();
  }

  void setLanguage(String value) {
    setLocale(
      value.toLowerCase().contains('he')
          ? const Locale('he')
          : const Locale('en'),
    );
  }

  Future<void> logout() async {
    try {
      if (_authToken != null && _authToken!.isNotEmpty) {
        await _authService.logout();
      }
    } catch (_) {
      // Ignore logout network failures and clear local session anyway.
    }

    _isAuthenticated = false;
    _authToken = null;
    _currentUser = AppUser.empty();
    _apiClient.setToken(null);
    notifyListeners();
  }

  String? _validateSignIn({required String email, required String password}) {
    if (!_isValidEmail(email)) {
      return 'Please enter a valid email address.';
    }
    if (password.trim().isEmpty) {
      return 'Password';
    }
    return null;
  }

  String? _validateSignUp({
    required String fullName,
    required String email,
    required String phone,
    required String dateOfBirth,
    required String password,
    required String confirmPassword,
  }) {
    if (fullName.trim().length < 2) {
      return 'Please enter your full name.';
    }
    if (!_isValidEmail(email)) {
      return 'Please enter a valid email address.';
    }
    if (phone.trim().length < 8) {
      return 'Please enter a valid phone number.';
    }
    if (dateOfBirth.trim().isEmpty) {
      return 'Please select your date of birth.';
    }
    if (password.length < 6) {
      return 'Password must contain at least 6 characters.';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match.';
    }
    return null;
  }

  String? _validateProfile({
    required String fullName,
    required String email,
    required String phone,
  }) {
    if (fullName.trim().length < 2) {
      return 'Please enter your full name.';
    }
    if (!_isValidEmail(email)) {
      return 'Please enter a valid email address.';
    }
    if (phone.trim().length < 8) {
      return 'Please enter a valid phone number.';
    }
    return null;
  }

  Future<String?> _wrapApiCall(Future<String?> Function() operation) async {
    _isBusy = true;
    notifyListeners();
    try {
      return await operation();
    } on OAuthFlowException catch (error) {
      return error.message;
    } on ApiException catch (error) {
      return error.message;
    } catch (error, stackTrace) {
      debugPrint('Unexpected session error: $error');
      debugPrintStack(stackTrace: stackTrace);
      return error.toString().trim().isEmpty
          ? 'Something went wrong. Please try again.'
          : error.toString();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> _authenticateWithOAuth({
    required String provider,
    required String purpose,
  }) async {
    final payload = await _integrationService.startOAuth(
      provider: provider,
      purpose: purpose,
    );
    final authorizationUrl = firstString(payload, const [
      'authorization_url',
      'auth_url',
      'url',
    ]);
    if (authorizationUrl == null || authorizationUrl.isEmpty) {
      throw const OAuthFlowException(
        'OAuth start did not return an authorization URL.',
      );
    }

    final handoffCode = await _oauthFlowService.authenticate(authorizationUrl);
    return _integrationService.completeOAuth(handoffCode);
  }

  Future<void> _enrichUserFromProfile() async {
    if (_authToken == null || _authToken!.isEmpty) return;

    try {
      final profilePayload = await _authService.fetchProfile();
      final profileUser = AppUser.fromApi(profilePayload);
      if (profileUser.fullName.isEmpty &&
          profileUser.email.isEmpty &&
          profileUser.id.isEmpty) {
        return;
      }
      _currentUser = _currentUser.copyWith(
        id: profileUser.id.isEmpty ? _currentUser.id : profileUser.id,
        fullName:
            profileUser.fullName.isEmpty
                ? _currentUser.fullName
                : profileUser.fullName,
        email:
            profileUser.email.isEmpty ? _currentUser.email : profileUser.email,
        phone:
            profileUser.phone.isEmpty ? _currentUser.phone : profileUser.phone,
        dateOfBirth: profileUser.dateOfBirth ?? _currentUser.dateOfBirth,
        avatarUrl:
            profileUser.avatarUrl.isEmpty
                ? _currentUser.avatarUrl
                : profileUser.avatarUrl,
        role: profileUser.role.isEmpty ? _currentUser.role : profileUser.role,
        notificationsEnabled: profileUser.notificationsEnabled,
        isDarkMode: profileUser.isDarkMode,
        locationServicesEnabled: profileUser.locationServicesEnabled,
        preferredLanguage:
            profileUser.preferredLanguage.isEmpty
                ? _currentUser.preferredLanguage
                : profileUser.preferredLanguage,
      );
      if (_currentUser.preferredLanguage == 'he' ||
          _currentUser.preferredLanguage == 'en') {
        _locale = Locale(_currentUser.preferredLanguage);
      }
      notifyListeners();
    } catch (_) {
      // Keep the auth payload values if profile enrichment is unavailable.
    }
  }

  AppUser _buildAuthUser(
    Map<String, dynamic> payload, {
    String fallbackPassword = '',
    String fallbackFullName = '',
    String fallbackEmail = '',
    String fallbackPhone = '',
    DateTime? fallbackDob,
  }) {
    final parsedUser = AppUser.fromApi(payload);
    return parsedUser.copyWith(
      fullName:
          parsedUser.fullName.isEmpty
              ? fallbackFullName.trim()
              : parsedUser.fullName,
      email: parsedUser.email.isEmpty ? fallbackEmail.trim() : parsedUser.email,
      phone: parsedUser.phone.isEmpty ? fallbackPhone.trim() : parsedUser.phone,
      dateOfBirth: parsedUser.dateOfBirth ?? fallbackDob,
      password:
          parsedUser.password.isEmpty ? fallbackPassword : parsedUser.password,
      preferredLanguage:
          parsedUser.preferredLanguage.isEmpty
              ? _locale.languageCode
              : parsedUser.preferredLanguage,
    );
  }

  void _setAuthenticatedSession({
    required String? token,
    required AppUser user,
  }) {
    _currentUser = user;

    if (_currentUser.preferredLanguage == 'he' ||
        _currentUser.preferredLanguage == 'en') {
      _locale = Locale(_currentUser.preferredLanguage);
    }

    _authToken = token;
    _apiClient.setToken(token);
    _isAuthenticated = true;
    notifyListeners();
  }

  void _applyAuthPayload(
    Map<String, dynamic> payload, {
    String fallbackPassword = '',
    String fallbackFullName = '',
    String fallbackEmail = '',
    String fallbackPhone = '',
    DateTime? fallbackDob,
  }) {
    final token = extractToken(payload);
    final authUser = _buildAuthUser(
      payload,
      fallbackPassword: fallbackPassword,
      fallbackFullName: fallbackFullName,
      fallbackEmail: fallbackEmail,
      fallbackPhone: fallbackPhone,
      fallbackDob: fallbackDob,
    );
    _setAuthenticatedSession(token: token, user: authUser);
  }

  bool _isValidEmail(String email) {
    final trimmed = email.trim();
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed);
  }

  DateTime? _parseDate(String input) {
    final parts = input.split('/').map((part) => part.trim()).toList();
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;

    return DateTime(year, month, day);
  }
}
