import 'package:flutter/material.dart';

import './report_type_toggle.dart';
import './report_text_field.dart';
import './report_dropdown.dart';
import './report_upload_box.dart';
import './report_submit_button.dart';

enum ReportType { lost, found }

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormState>();

  ReportType type = ReportType.lost;

  final itemCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final contactCtrl = TextEditingController();

  String? category;
  String? location;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 130),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  "Report an Item",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 16),
                ReportTypeToggle(
                  type: type,
                  onChanged: (t) => setState(() => type = t),
                ),
                const SizedBox(height: 20),

                ReportTextField(
                  label: "Item Name *",
                  hint: "e.g., Blue Backpack",
                  controller: itemCtrl,
                ),

                ReportTextField(
                  label: "Description *",
                  hint: "Provide detailed description...",
                  controller: descCtrl,
                  maxLines: 4,
                ),

                Row(
                  children: [
                    Expanded(
                      child: ReportDropdown(
                        label: "Category *",
                        value: category,
                        items: const [
                          "Electronics",
                          "Books",
                          "Keys",
                          "Documents",
                        ],
                        onChanged: (v) => setState(() => category = v),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ReportDropdown(
                        label: "Location *",
                        value: location,
                        items: const ["Library", "Student Center", "Dormitory"],
                        onChanged: (v) => setState(() => location = v),
                      ),
                    ),
                  ],
                ),

                ReportTextField(
                  label: "Date *",
                  hint: "yyyy.mm.dd",
                  controller: dateCtrl,
                  suffixIcon: Icons.calendar_today_outlined,
                ),

                ReportTextField(
                  label: "Contact Information *",
                  hint: "Email or phone number",
                  controller: contactCtrl,
                ),

                const SizedBox(height: 14),
                const ReportUploadBox(),
                const SizedBox(height: 20),

                ReportSubmitButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Submitted ✅")),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
