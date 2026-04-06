import '../services/auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();

  bool validateUniversityEmail(String email) {
    return email.trim().toLowerCase().endsWith('@inf.elte.hu');
  }

  Future<void> login({required String email, required String password}) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      throw Exception('Email and password are required.');
    }

    if (!validateUniversityEmail(trimmedEmail)) {
      throw Exception('Only @inf.elte.hu email addresses are allowed.');
    }

    await _authService.signIn(trimmedEmail, trimmedPassword);
  }

  Future<void> logout() async {
    await _authService.signOut();
  }
}
