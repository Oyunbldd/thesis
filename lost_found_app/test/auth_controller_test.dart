import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lost_found_app/controllers/auth_controller.dart';
import 'package:lost_found_app/services/auth_service.dart';

/// Fake AuthService that never calls Firebase — used for unit tests only.
class FakeAuthService extends AuthService {
  @override
  Future<UserCredential> signIn(String email, String password) async =>
      throw UnimplementedError();

  @override
  Future<void> register(String email, String password) async =>
      throw UnimplementedError();

  @override
  Future<void> resetPassword(String email) async =>
      throw UnimplementedError();

  @override
  Future<void> sendVerificationEmail() async =>
      throw UnimplementedError();

  @override
  Future<void> signOut() async => throw UnimplementedError();
}

void main() {
  late AuthController authController;

  setUp(() {
    authController = AuthController(authService: FakeAuthService());
  });

  // ── validateUniversityEmail ──────────────────────────────────────────────

  group('validateUniversityEmail', () {
    test('returns true for valid @inf.elte.hu email', () {
      expect(authController.validateUniversityEmail('student@inf.elte.hu'), isTrue);
    });

    test('returns false for non-university email', () {
      expect(authController.validateUniversityEmail('student@gmail.com'), isFalse);
    });

    test('returns true for uppercase university email (case-insensitive)', () {
      expect(authController.validateUniversityEmail('STUDENT@INF.ELTE.HU'), isTrue);
    });
  });

  // ── login ────────────────────────────────────────────────────────────────

  group('login', () {
    test('throws when email is empty', () {
      expect(
        () => authController.login(email: '', password: 'password123'),
        throwsA(
          predicate((e) => e.toString().contains('Email and password are required.')),
        ),
      );
    });

    test('throws when password is empty', () {
      expect(
        () => authController.login(email: 'student@inf.elte.hu', password: ''),
        throwsA(
          predicate((e) => e.toString().contains('Email and password are required.')),
        ),
      );
    });

    test('throws when non-university email is used', () {
      expect(
        () => authController.login(email: 'student@gmail.com', password: 'password123'),
        throwsA(
          predicate((e) => e.toString().contains('Only @inf.elte.hu email addresses are allowed.')),
        ),
      );
    });
  });

  // ── register ─────────────────────────────────────────────────────────────

  group('register', () {
    test('throws when passwords do not match', () {
      expect(
        () => authController.register(
          email: 'student@inf.elte.hu',
          password: 'password123',
          confirmPassword: 'different123',
        ),
        throwsA(
          predicate((e) => e.toString().contains('Passwords do not match.')),
        ),
      );
    });

    test('throws when password is shorter than 6 characters', () {
      expect(
        () => authController.register(
          email: 'student@inf.elte.hu',
          password: '123',
          confirmPassword: '123',
        ),
        throwsA(
          predicate((e) => e.toString().contains('Password must be at least 6 characters.')),
        ),
      );
    });

    test('throws when non-university email is used', () {
      expect(
        () => authController.register(
          email: 'student@gmail.com',
          password: 'password123',
          confirmPassword: 'password123',
        ),
        throwsA(
          predicate((e) => e.toString().contains('Only @inf.elte.hu email addresses are allowed.')),
        ),
      );
    });
  });

  // ── resetPassword ─────────────────────────────────────────────────────────

  group('resetPassword', () {
    test('throws when email is empty', () {
      expect(
        () => authController.resetPassword(email: ''),
        throwsA(
          predicate((e) => e.toString().contains('Email is required.')),
        ),
      );
    });

    test('throws when non-university email is used', () {
      expect(
        () => authController.resetPassword(email: 'student@gmail.com'),
        throwsA(
          predicate((e) => e.toString().contains('Only @inf.elte.hu email addresses are allowed.')),
        ),
      );
    });
  });
}
