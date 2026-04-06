import 'package:flutter/material.dart';
import '../features/splash/splash_page.dart';
import '../features/shell/app_shell.dart';
import '../features/auth/login_page.dart';

class AppRouter {
  static const splash = "/";
  static const shell = "/app";
  static const login = "/login";

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case shell:
        return MaterialPageRoute(builder: (_) => const AppShell());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("Route not found"))),
        );
    }
  }
}
