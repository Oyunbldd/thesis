import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'services/notification_service.dart';
import 'utils/app_routes.dart';
import 'utils/app_theme.dart';
import 'views/home/home_view.dart';
import 'views/login/login_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lost & Found',
      theme: AppTheme.light(),
      home: const _AuthGate(),
      routes: {AppRoutes.home: (context) => const HomeView()},
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _notificationsInitialized = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data!.emailVerified) {
          // Initialize FCM only once per session
          if (!_notificationsInitialized) {
            _notificationsInitialized = true;
            NotificationService().initialize();
          }
          return const HomeView();
        }
        // Reset so notifications re-initialize on next login
        _notificationsInitialized = false;
        return const LoginView();
      },
    );
  }
}
