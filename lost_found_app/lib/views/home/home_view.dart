import 'package:flutter/material.dart';
import 'package:lost_found_app/utils/app_theme.dart';
import 'package:lost_found_app/widgets/bottom_nav_bar.dart';
import 'package:lost_found_app/widgets/home_header.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HomeHeader(),
          Expanded(
            child: Center(
              child: Text(
                "Body",
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(
        currentItem: BottomNavItem.report,
      ),
    );
  }
}
