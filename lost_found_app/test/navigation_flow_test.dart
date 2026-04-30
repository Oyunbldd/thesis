import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lost_found_app/utils/app_theme.dart';
import 'package:lost_found_app/views/login/forgot_password_view.dart';
import 'package:lost_found_app/views/login/login_view.dart';
import 'package:lost_found_app/views/login/register_view.dart';

/// Wraps a widget in a themed MaterialApp so navigation and styling work.
Widget _buildApp(Widget home) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: home,
  );
}

void main() {
  setUp(() {
    // Provide empty SharedPreferences so LoginView.initState doesn't fail
    SharedPreferences.setMockInitialValues({});
  });

  // ── LoginView ─────────────────────────────────────────────────────────────

  group('LoginView', () {
    testWidgets('renders email field, password field and login button', (tester) async {
      await tester.pumpWidget(_buildApp(const LoginView()));
      await tester.pump();

      expect(find.text('University Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('renders Remember me checkbox', (tester) async {
      await tester.pumpWidget(_buildApp(const LoginView()));
      await tester.pump();

      expect(find.text('Remember me'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('"Forgot password?" button is hidden by default', (tester) async {
      await tester.pumpWidget(_buildApp(const LoginView()));
      await tester.pump();

      expect(find.text('Forgot password?'), findsNothing);
    });

    testWidgets('tapping "Don\'t have an account?" navigates to RegisterView', (tester) async {
      await tester.pumpWidget(_buildApp(const LoginView()));
      await tester.pump();

      await tester.tap(find.text("Don't have an account? Register"));
      await tester.pumpAndSettle();

      expect(find.text('Create account'), findsOneWidget);
    });
  });

  // ── RegisterView ──────────────────────────────────────────────────────────

  group('RegisterView', () {
    testWidgets('renders email, password and confirm password fields', (tester) async {
      await tester.pumpWidget(_buildApp(const RegisterView()));
      await tester.pump();

      expect(find.text('University Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('renders Create Account button', (tester) async {
      await tester.pumpWidget(_buildApp(const RegisterView()));
      await tester.pump();

      expect(find.widgetWithText(ElevatedButton, 'Create Account'), findsOneWidget);
    });

    testWidgets('tapping "Already have an account?" navigates back to LoginView', (tester) async {
      // Start on LoginView then push to RegisterView
      await tester.pumpWidget(_buildApp(const LoginView()));
      await tester.pump();

      await tester.tap(find.text("Don't have an account? Register"));
      await tester.pumpAndSettle();

      // Now on RegisterView — tap back
      await tester.tap(find.text('Already have an account? Log in'));
      await tester.pumpAndSettle();

      // Back on LoginView
      expect(find.text('Welcome back'), findsOneWidget);
    });
  });

  // ── ForgotPasswordView ────────────────────────────────────────────────────

  group('ForgotPasswordView', () {
    testWidgets('renders email field and Send Reset Link button', (tester) async {
      await tester.pumpWidget(_buildApp(const ForgotPasswordView()));
      await tester.pump();

      expect(find.text('University Email'), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);
    });

    testWidgets('renders Forgot your password? title', (tester) async {
      await tester.pumpWidget(_buildApp(const ForgotPasswordView()));
      await tester.pump();

      expect(find.text('Forgot your password?'), findsOneWidget);
    });

    testWidgets('tapping "Back to Login" navigates back to LoginView', (tester) async {
      // Start on LoginView
      await tester.pumpWidget(_buildApp(const LoginView()));
      await tester.pump();

      // Manually push ForgotPasswordView since the button is hidden by default
      final NavigatorState navigator = tester.state(find.byType(Navigator));
      navigator.push(
        MaterialPageRoute<void>(builder: (_) => const ForgotPasswordView()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Forgot your password?'), findsOneWidget);

      // Tap Back to Login
      await tester.tap(find.text('Back to Login'));
      await tester.pumpAndSettle();

      // Back on LoginView
      expect(find.text('Welcome back'), findsOneWidget);
    });
  });
}
