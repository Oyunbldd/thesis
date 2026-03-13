import 'package:flutter/material.dart';
import 'utils/app_routes.dart';
import 'views/login/login_view.dart';
import 'views/home/home_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lost & Found',
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (context) => const LoginView(),
        AppRoutes.home: (context) => const HomeView(),
      },
    );
  }
}
