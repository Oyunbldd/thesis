import 'package:flutter/material.dart';
import '../report/report_page.dart';

class ReportTypeToggle extends StatelessWidget {
  final ReportType type;
  final ValueChanged<ReportType> onChanged;

  const ReportTypeToggle({
    super.key,
    required this.type,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _button(
          text: "I Lost Something",
          icon: Icons.error_outline,
          active: type == ReportType.lost,
          color: Colors.red,
          onTap: () => onChanged(ReportType.lost),
        ),
        const SizedBox(height: 12),
        _button(
          text: "I Found Something",
          icon: Icons.inventory_2_outlined,
          active: type == ReportType.found,
          color: Colors.green,
          onTap: () => onChanged(ReportType.found),
        ),
      ],
    );
  }

  Widget _button({
    required String text,
    required IconData icon,
    required bool active,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: active ? color.withOpacity(0.1) : const Color(0xFFF3F4F6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? color : Colors.black),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: active ? color : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
