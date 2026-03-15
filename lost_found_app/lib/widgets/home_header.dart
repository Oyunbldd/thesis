import 'package:flutter/material.dart';
import 'package:lost_found_app/utils/app_theme.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 125,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white24,
                child: Text(
                  "JS",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Lost & Found",
                    style: textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  Text(
                    "Campus Portal",
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Stack(
            children: [
              const Icon(
                Icons.notifications_none,
                size: 28,
                color: Colors.white,
              ),
              // Positioned(
              //   right: 0,
              //   top: 0,
              //   child: Container(
              //     width: 10,
              //     height: 10,
              //     decoration: const BoxDecoration(
              //       color: Colors.red,
              //       shape: BoxShape.circle,
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
