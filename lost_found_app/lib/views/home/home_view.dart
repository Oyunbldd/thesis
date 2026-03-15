import 'package:flutter/material.dart';
import 'package:lost_found_app/widgets/bottom_nav_bar.dart';
import 'package:lost_found_app/widgets/home_header.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HomeHeader(),
          const Expanded(
            child: Center(
              child: Text(
                "Body",
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
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
