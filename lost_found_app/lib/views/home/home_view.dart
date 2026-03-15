import 'package:flutter/material.dart';
import 'package:lost_found_app/widgets/bottom_nav_bar.dart';
import 'package:lost_found_app/widgets/home_header.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeHeader(),
          Expanded(child: Center(child: Text("Body"))),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
