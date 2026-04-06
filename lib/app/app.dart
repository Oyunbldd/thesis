import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/constants/app_strings.dart';
import 'router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.light(),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.splash,
      debugShowCheckedModeBanner: false,
    );
  }
}
