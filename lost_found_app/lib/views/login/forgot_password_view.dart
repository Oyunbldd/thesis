import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../utils/app_theme.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final AuthController _authController = AuthController();
  final TextEditingController _emailController = TextEditingController();

  String _errorMessage = '';
  bool _isLoading = false;
  bool _emailSent = false;

  Future<void> _handleResetPassword() async {
    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    try {
      await _authController.resetPassword(email: _emailController.text);
      if (mounted) {
        setState(() => _emailSent = true);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = 'No account found with this email address.';
          case 'too-many-requests':
            _errorMessage = 'Too many attempts. Please try again later.';
          default:
            _errorMessage = 'Something went wrong. Please try again.';
        }
      });
    } on Exception catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _emailSent ? _buildSuccessState(textTheme) : _buildFormState(textTheme),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormState(TextTheme textTheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.lock_reset_outlined, size: 48),
        const SizedBox(height: 16),
        Text(
          'Forgot your password?',
          style: textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your university email and we will send you a link to reset your password.',
          style: textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'University Email',
            hintText: 'yourname@inf.elte.hu',
          ),
        ),
        const SizedBox(height: 16),
        if (_errorMessage.isNotEmpty)
          Text(
            _errorMessage,
            style: textTheme.bodyMedium?.copyWith(color: AppTheme.error),
            textAlign: TextAlign.center,
          ),
        if (_errorMessage.isNotEmpty) const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleResetPassword,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Send Reset Link'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Back to Login'),
        ),
      ],
    );
  }

  Widget _buildSuccessState(TextTheme textTheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.mark_email_read_outlined, size: 48, color: Colors.green),
        const SizedBox(height: 16),
        Text(
          'Check your inbox',
          style: textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'A password reset link has been sent to ${_emailController.text.trim()}. '
          'Follow the link in the email to set a new password.',
          style: textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Back to Login'),
        ),
      ],
    );
  }
}
