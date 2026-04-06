import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return const HomeView();
          }
          return const LoginView();
        },
      ),
      routes: {
        AppRoutes.home: (context) => const HomeView(),
      },
    );
  }
}
