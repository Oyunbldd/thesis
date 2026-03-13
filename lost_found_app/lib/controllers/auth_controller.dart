class AuthController {
  bool validateUniversityEmail(String email) {
    final trimmedEmail = email.trim().toLowerCase();

    return trimmedEmail.endsWith('@inf.elte.hu');
  }

  bool login({required String email, required String password}) {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      return false;
    }

    if (!validateUniversityEmail(trimmedEmail)) {
      return false;
    }
    return true;
  }

  void logout() {
    // Add some code later
  }
}
