import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: const [
        // Your home content widgets (search, filter, cards...)
        Text("Home content here"),
      ],
    );
  }
}
