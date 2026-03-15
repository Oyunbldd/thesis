import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 125,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
        ),
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
                children: const [
                  Text(
                    "Lost & Found",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Campus Portal",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
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
