import 'package:flutter/material.dart';

class ReportUploadBox extends StatelessWidget {
  const ReportUploadBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
        color: const Color(0xFFF9FAFB),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.upload_rounded, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            "Click to upload image",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4),
          Text("PNG, JPG up to 10MB", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
