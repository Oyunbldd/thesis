class Validators {
  static bool isEmail(String value) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(value.trim());
  }

  static bool isElteStudentEmail(String value) {
    final v = value.trim().toLowerCase();
    return v.endsWith("@inf.elte.hu");
  }
}
