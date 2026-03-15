import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(height: 6),
              Text("Lost", style: TextStyle(color: Colors.red)),
            ],
          ),

          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12)],
            ),
            child: const Icon(Icons.add, size: 32, color: Colors.black54),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.inventory_2_outlined, color: Colors.grey),
              SizedBox(height: 6),
              Text("Found", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
