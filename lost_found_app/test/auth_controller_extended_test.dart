// AI-GENERATED: This entire file was generated using Claude Sonnet 4.6 (Anthropic).
// Tool: Claude Code CLI
// Purpose: Edge-case test coverage for AuthController (whitespace trimming, domain validation, delegation to Firebase)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lost_found_app/controllers/auth_controller.dart';
import 'package:lost_found_app/services/auth_service.dart';

// AI-GENERATED: Fake AuthService stub — prevents real Firebase calls during tests (lines 11–19)
class FakeAuthService extends AuthService {
  @override
  Future<UserCredential> signIn(String email, String password) async =>
      throw UnimplementedError();
  @override
  Future<void> register(String email, String password) async =>
      throw UnimplementedError();
  @override
  Future<void> resetPassword(String email) async => throw UnimplementedError();
  @override
  Future<void> sendVerificationEmail() async => throw UnimplementedError();
  @override
  Future<void> signOut() async => throw UnimplementedError();
}

void main() {
  late AuthController controller;

  setUp(() {
    controller = AuthController(authService: FakeAuthService());
  });

  // AI-GENERATED: validateUniversityEmail edge case tests (lines 32–67)
  group('validateUniversityEmail edge cases', () {
    test('returns false for empty string', () { // AI-GENERATED
      expect(controller.validateUniversityEmail(''), isFalse);
    });

    // NOTE: validateUniversityEmail only checks endsWith('@inf.elte.hu').
    // A bare '@inf.elte.hu' technically passes this check; full email format
    // validation (e.g. rejecting missing username) is delegated to Firebase Auth.
    test('domain-only "@inf.elte.hu" passes endsWith check (Firebase rejects it)', () { // AI-GENERATED
      expect(controller.validateUniversityEmail('@inf.elte.hu'), isTrue);
    });

    test('returns true for mixed-case email', () { // AI-GENERATED
      expect(controller.validateUniversityEmail('User@INF.ELTE.HU'), isTrue);
    });

    test('returns true for email with leading/trailing whitespace', () { // AI-GENERATED
      expect(
        controller.validateUniversityEmail('  student@inf.elte.hu  '),
        isTrue,
      );
    });

    test('returns false for similar-but-wrong domain', () { // AI-GENERATED
      expect(
        controller.validateUniversityEmail('student@inf.elte.hu.evil.com'),
        isFalse,
      );
    });

    test('returns false for missing TLD', () { // AI-GENERATED
      expect(controller.validateUniversityEmail('student@inf.elte'), isFalse);
    });

    test('returns false for @elte.hu without inf subdomain', () { // AI-GENERATED
      expect(controller.validateUniversityEmail('student@elte.hu'), isFalse);
    });
  });

  // AI-GENERATED: login whitespace/trimming edge case tests (lines 71–104)
  group('login trimming behavior', () {
    test('whitespace-only email is treated as empty', () { // AI-GENERATED
      expect(
        () => controller.login(email: '   ', password: 'password123'),
        throwsA(
          predicate(
            (e) => e.toString().contains('Email and password are required.'),
          ),
        ),
      );
    });

    test('whitespace-only password is treated as empty', () { // AI-GENERATED
      expect(
        () => controller.login(email: 'student@inf.elte.hu', password: '   '),
        throwsA(
          predicate(
            (e) => e.toString().contains('Email and password are required.'),
          ),
        ),
      );
    });

    test('both fields whitespace-only throws required error', () { // AI-GENERATED
      expect(
        () => controller.login(email: '   ', password: '   '),
        throwsA(
          predicate(
            (e) => e.toString().contains('Email and password are required.'),
          ),
        ),
      );
    });
  });

  // AI-GENERATED: register edge case tests (lines 108–198)
  group('register edge cases', () {
    test('whitespace-only email is treated as empty', () { // AI-GENERATED
      expect(
        () => controller.register(
          email: '   ',
          password: 'password123',
          confirmPassword: 'password123',
        ),
        throwsA(
          predicate(
            (e) => e.toString().contains('Email and password are required.'),
          ),
        ),
      );
    });

    test('whitespace-only password is treated as empty', () { // AI-GENERATED
      expect(
        () => controller.register(
          email: 'student@inf.elte.hu',
          password: '   ',
          confirmPassword: '   ',
        ),
        throwsA(
          predicate(
            (e) => e.toString().contains('Email and password are required.'),
          ),
        ),
      );
    });

    test('password of exactly 5 characters is rejected', () { // AI-GENERATED
      expect(
        () => controller.register(
          email: 'student@inf.elte.hu',
          password: 'abcde',
          confirmPassword: 'abcde',
        ),
        throwsA(
          predicate(
            (e) => e.toString().contains(
              'Password must be at least 6 characters.',
            ),
          ),
        ),
      );
    });

    test('password of exactly 6 characters passes length validation and proceeds to Firebase', () { // AI-GENERATED
      // 6-char password with matching confirm should NOT throw a validation error;
      // it reaches the (fake) Firebase call which throws UnimplementedError.
      expect(
        () => controller.register(
          email: 'student@inf.elte.hu',
          password: 'abcdef',
          confirmPassword: 'abcdef',
        ),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('password mismatch is caught even when both are valid length', () { // AI-GENERATED
      expect(
        () => controller.register(
          email: 'student@inf.elte.hu',
          password: 'validPassword1',
          confirmPassword: 'differentPassword1',
        ),
        throwsA(
          predicate((e) => e.toString().contains('Passwords do not match.')),
        ),
      );
    });

    test('valid inputs reach Firebase (throws UnimplementedError from fake)', () { // AI-GENERATED
      expect(
        () => controller.register(
          email: 'student@inf.elte.hu',
          password: 'password123',
          confirmPassword: 'password123',
        ),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });

  // AI-GENERATED: resetPassword edge case tests (lines 202–216)
  group('resetPassword edge cases', () {
    test('whitespace-only email is treated as empty', () { // AI-GENERATED
      expect(
        () => controller.resetPassword(email: '   '),
        throwsA(predicate((e) => e.toString().contains('Email is required.'))),
      );
    });

    test('valid university email reaches Firebase (UnimplementedError)', () { // AI-GENERATED
      expect(
        () => controller.resetPassword(email: 'student@inf.elte.hu'),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });

  // AI-GENERATED: logout delegation test (lines 220–226)
  group('logout', () {
    test('logout delegates to AuthService.signOut (throws UnimplementedError)', () { // AI-GENERATED
      expect(() => controller.logout(), throwsA(isA<UnimplementedError>()));
    });
  });

  // AI-GENERATED: sendVerificationEmail delegation test (lines 230–237)
  group('sendVerificationEmail', () {
    test('delegates to AuthService (throws UnimplementedError)', () { // AI-GENERATED
      expect(
        () => controller.sendVerificationEmail(),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
