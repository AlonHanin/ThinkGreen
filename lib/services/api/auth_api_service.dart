import 'api_client.dart';

class AuthApiService {
  AuthApiService(this._api);

  final ApiClient _api;

  Future<Map<String, dynamic>> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String dateOfBirth,
    required String password,
    required String confirmPassword,
    String locale = 'en',
  }) {
    return _api.postJson(
      'auth/signup.php',
      body: {
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'date_of_birth': dateOfBirth,
        'password': password,
        'confirm_password': confirmPassword,
        'locale': locale,
      },
    );
  }

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) {
    return _api.postJson(
      'auth/login.php',
      body: {
        'email': email,
        'password': password,
      },
    );
  }

  Future<Map<String, dynamic>> requestResetPin(String email) {
    return _api.postJson(
      'auth/request_reset_pin.php',
      body: {'email': email},
    );
  }

  Future<Map<String, dynamic>> verifyResetPin({
    required String email,
    required String pin,
  }) {
    return _api.postJson(
      'auth/verify_reset_pin.php',
      body: {
        'email': email,
        'pin': pin,
      },
    );
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String pin,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _api.postJson(
      'auth/reset_password.php',
      body: {
        'email': email,
        'pin': pin,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
    );
  }

  Future<Map<String, dynamic>> fetchProfile() {
    return _api.getJson('profile/me.php');
  }

  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String email,
    required String phone,
  }) {
    return _api.postJson(
      'profile/update.php',
      body: {
        'full_name': fullName,
        'email': email,
        'phone': phone,
      },
    );
  }

  Future<Map<String, dynamic>> logout() {
    return _api.postJson('auth/logout.php', body: const {});
  }
}
