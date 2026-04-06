import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../controllers/item_controller.dart';
import '../../models/item_report_model.dart';
import '../../utils/app_theme.dart';

class ReportLostItemView extends StatefulWidget {
  const ReportLostItemView({super.key});

  @override
  State<ReportLostItemView> createState() => _ReportLostItemViewState();
}

class _ReportLostItemViewState extends State<ReportLostItemView> {
  static const _itemTemplates = <_OptionTileData>[
    _OptionTileData(label: 'Phone', emoji: '📱', category: 'Electronics'),
    _OptionTileData(label: 'Backpack', emoji: '🎒', category: 'Accessories'),
    _OptionTileData(label: 'ID Card', emoji: '💳', category: 'IDs'),
    _OptionTileData(label: 'Keys', emoji: '🔑', category: 'Keys'),
    _OptionTileData(label: 'Headphones', emoji: '🎧', category: 'Electronics'),
    _OptionTileData(label: 'Textbook', emoji: '📚', category: 'Books'),
    _OptionTileData(
      label: 'Other',
      emoji: '✍️',
      category: 'Other',
      isManual: true,
    ),
  ];

  static const _categories = <String>[
    'Electronics',
    'Accessories',
    'Books',
    'Clothing',
    'Keys',
    'IDs',
    'Other',
  ];

  static const _locations = <String>[
    'Library',
    'Student Center',
    'Engineering\nBuilding',
    'Science Building',
    'Cafeteria',
    'Gym',
    'Parking Lot',
    'Dorms',
    'Other',
  ];

  final ItemController _itemController = ItemController();

  int _step = 0;
  bool _isSubmitting = false;
  String? _selectedTemplate;
  String? _selectedCategory;
  String? _selectedLocation;
  DateTime? _dateLost;
  String? _selectedImagePath;
  String? _photoPermissionMessage;

  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  bool get _canContinue {
    switch (_step) {
      case 0:
        return _itemNameController.text.trim().isNotEmpty &&
            _selectedCategory != null;
      case 1:
        return _selectedLocation != null && _dateLost != null;
      case 2:
        return _descriptionController.text.trim().isNotEmpty;
      case 3:
        return true;
      case 4:
        return _contactController.text.trim().isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> _goNext() async {
    if (!_canContinue || _isSubmitting) return;

    if (_step == 4) {
      setState(() => _isSubmitting = true);
      try {
        final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
        final report = ItemReportModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _itemNameController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory!,
          type: 'lost',
          status: 'open',
          imageUrl: _selectedImagePath ?? '',
          location: _selectedLocation!,
          date: _dateLost!,
          userId: uid,
        );
        await _itemController.createReport(report);
        if (mounted) Navigator.of(context).pop();
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
      return;
    }

    setState(() {
      _step += 1;
    });
  }

  void _goBack() {
    if (_step == 0) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _step -= 1;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateLost ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _dateLost = picked;
      });
    }
  }

  Future<Permission> _galleryPermission() async {
    if (Platform.isIOS || Platform.isMacOS) {
      return Permission.photos;
    }

    if (Platform.isAndroid) {
      return Permission.photos;
    }

    return Permission.storage;
  }

  Future<void> _pickGalleryImage() async {
    final permission = await _galleryPermission();
    final status = await permission.request();

    if (!status.isGranted && !status.isLimited) {
      setState(() {
        _photoPermissionMessage =
            'You didn\'t accept gallery permission, so we couldn\'t open your photos.';
      });
      return;
    }

    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) {
      return;
    }

    setState(() {
      _selectedImagePath = image.path;
      _photoPermissionMessage = null;
    });
  }

  static const _stepTitles = [
    'What Did You Lose?',
    'Where & When?',
    'Describe the Item',
    'Add a Photo',
    'Contact Details',
  ];

  static const _stepNextLabels = [
    'Location & Date',
    'Description',
    'Add Photo',
    'Contact Info',
    'Submit',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _LostReportHeader(onBack: _goBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.secondary.withValues(alpha: 0.08),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProgressHeader(
                      step: _step + 1,
                      totalSteps: 5,
                      title: _stepTitles[_step],
                      nextLabel: _step < 4 ? _stepNextLabels[_step] : null,
                    ),
                    const SizedBox(height: 26),
                    ...switch (_step) {
                      0 => [
                        _StepOne(
                          selectedTemplate: _selectedTemplate,
                          selectedCategory: _selectedCategory,
                          itemNameController: _itemNameController,
                          onTemplateSelected: (value) {
                            setState(() {
                              if (value.isManual) {
                                _selectedTemplate = 'Other';
                                _itemNameController.clear();
                                _selectedCategory = null;
                              } else {
                                _selectedTemplate = value.label;
                                _itemNameController.text = value.label;
                                _selectedCategory = value.category;
                              }
                            });
                          },
                          onCategorySelected: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                          onChanged: () => setState(() {}),
                        ),
                      ],
                      1 => [
                        _StepTwo(
                          selectedLocation: _selectedLocation,
                          dateLost: _dateLost,
                          onLocationSelected: (value) {
                            setState(() {
                              _selectedLocation = value;
                            });
                          },
                          onPickDate: _pickDate,
                        ),
                      ],
                      2 => [
                        _StepThree(
                          controller: _descriptionController,
                          onChanged: () => setState(() {}),
                        ),
                      ],
                      3 => [
                        _StepFour(
                          imagePath: _selectedImagePath,
                          permissionMessage: _photoPermissionMessage,
                          onPickPhoto: _pickGalleryImage,
                          onSkip: _goNext,
                        ),
                      ],
                      _ => [
                        _StepFive(
                          controller: _contactController,
                          itemName: _itemNameController.text.trim(),
                          category: _selectedCategory ?? '-',
                          location: _selectedLocation ?? '-',
                          dateLost: _dateLost,
                          onChanged: () => setState(() {}),
                        ),
                      ],
                    },
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        if (_step > 0)
                          Expanded(
                            child: _SecondaryButton(
                              label: 'Back',
                              onTap: _goBack,
                            ),
                          ),
                        if (_step > 0) const SizedBox(width: 16),
                        Expanded(
                          child: _PrimaryButton(
                            label: _step == 4 ? 'Submit Report' : 'Continue',
                            enabled: _canContinue,
                            onTap: _goNext,
                            icon: _step == 4
                                ? Icons.auto_awesome_outlined
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LostReportHeader extends StatelessWidget {
  const _LostReportHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
      decoration: const BoxDecoration(
        color: Color(0xFFE50008),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: Colors.white,
            iconSize: 30,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Report Lost Item',
                style: textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Fill in the details below',
                style: textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.step,
    required this.totalSteps,
    required this.title,
    this.nextLabel,
  });

  final int step;
  final int totalSteps;
  final String title;
  final String? nextLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final progress = step / totalSteps;

    return Row(
      children: [
        // ── Circular progress indicator ──────────────────────────────
        SizedBox(
          width: 72,
          height: 72,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 6,
                backgroundColor: const Color(0xFFD9DDE5),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFF1A24),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$step',
                      style: textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF111318),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    Text(
                      'of $totalSteps',
                      style: textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF697386),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 18),
        // ── Step title + next label ──────────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF111318),
                  fontSize: 20,
                  height: 1.15,
                ),
              ),
              if (nextLabel != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Next: $nextLabel',
                  style: textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF697386),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Icon(icon, color: const Color(0xFFE50008), size: 76),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: textTheme.headlineLarge?.copyWith(
            color: const Color(0xFF111318),
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: textTheme.titleLarge?.copyWith(
            color: const Color(0xFF667085),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StepOne extends StatelessWidget {
  const _StepOne({
    required this.selectedTemplate,
    required this.selectedCategory,
    required this.itemNameController,
    required this.onTemplateSelected,
    required this.onCategorySelected,
    required this.onChanged,
  });

  final String? selectedTemplate;
  final String? selectedCategory;
  final TextEditingController itemNameController;
  final ValueChanged<_OptionTileData> onTemplateSelected;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _StepHeader(
          icon: Icons.inventory_2_outlined,
          title: 'What item is it?',
          subtitle: 'Choose a template or enter custom details',
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.1,
          children: _ReportLostItemViewState._itemTemplates
              .map(
                (item) => _TemplateTile(
                  data: item,
                  selected: selectedTemplate == item.label,
                  onTap: () => onTemplateSelected(item),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        if (selectedTemplate == null || selectedTemplate == 'Other') ...[
          Row(
            children: const [
              Expanded(child: Divider(color: Color(0xFFD5DAE2))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Or enter manually',
                  style: TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Color(0xFFD5DAE2))),
            ],
          ),
          const SizedBox(height: 28),
          _FieldLabel(label: 'Item Name *'),
          const SizedBox(height: 12),
          _RoundedTextField(
            controller: itemNameController,
            hintText: 'e.g., Blue Backpack, iPhone 15',
            onChanged: (_) => onChanged(),
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4F5),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFFD1D5)),
            ),
            child: Text(
              'Template selected: "$selectedTemplate" auto-filled the item name and category.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFFB42318),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        _FieldLabel(label: 'Category *'),
        const SizedBox(height: 14),
        _OptionGrid(
          options: _ReportLostItemViewState._categories,
          selectedValue: selectedCategory,
          onSelected: onCategorySelected,
        ),
      ],
    );
  }
}

class _StepTwo extends StatelessWidget {
  const _StepTwo({
    required this.selectedLocation,
    required this.dateLost,
    required this.onLocationSelected,
    required this.onPickDate,
  });

  final String? selectedLocation;
  final DateTime? dateLost;
  final ValueChanged<String> onLocationSelected;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _StepHeader(
          icon: Icons.location_on_outlined,
          title: 'Where & When?',
          subtitle: 'Help others locate the item',
        ),
        const SizedBox(height: 28),
        _FieldLabel(label: 'Location *', icon: Icons.location_on_outlined),
        const SizedBox(height: 14),
        _OptionGrid(
          options: _ReportLostItemViewState._locations,
          selectedValue: selectedLocation,
          onSelected: onLocationSelected,
        ),
        const SizedBox(height: 26),
        _FieldLabel(label: 'Date Lost *', icon: Icons.calendar_today_outlined),
        const SizedBox(height: 12),
        _DateField(value: dateLost, onTap: onPickDate),
      ],
    );
  }
}

class _StepThree extends StatelessWidget {
  const _StepThree({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _StepHeader(
          icon: Icons.description_outlined,
          title: 'Describe the item',
          subtitle: 'Add specific details to help identify it',
        ),
        const SizedBox(height: 28),
        _FieldLabel(label: 'Detailed Description *'),
        const SizedBox(height: 12),
        _RoundedTextField(
          controller: controller,
          hintText: 'Include color, brand, size, unique features, condition...',
          maxLines: 6,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Text(
              'Be as detailed as possible',
              style: TextStyle(
                color: Color(0xFF667085),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '${controller.text.characters.length} characters',
              style: const TextStyle(
                color: Color(0xFF667085),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const _QuickTipsCard(),
      ],
    );
  }
}

class _StepFour extends StatelessWidget {
  const _StepFour({
    required this.imagePath,
    required this.permissionMessage,
    required this.onPickPhoto,
    required this.onSkip,
  });

  final String? imagePath;
  final String? permissionMessage;
  final VoidCallback onPickPhoto;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = imagePath != null;

    return Column(
      children: [
        const _StepHeader(
          icon: Icons.photo_camera_outlined,
          title: 'Add a photo',
          subtitle: 'Photos increase match rate by 85%',
        ),
        const SizedBox(height: 26),
        InkWell(
          onTap: onPickPhoto,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FBFF),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFF5B9DFF),
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: Column(
              children: [
                if (hasPhoto)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.file(
                      File(imagePath!),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  const Icon(
                    Icons.photo_camera_outlined,
                    size: 68,
                    color: Color(0xFF98A2B3),
                  ),
                const SizedBox(height: 18),
                Text(
                  hasPhoto ? 'Photo selected' : 'Take Photo or Upload',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF475467),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hasPhoto
                      ? 'Tap again to choose a different image'
                      : 'PNG, JPG up to 10MB',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF98A2B3),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (permissionMessage != null) ...[
          const SizedBox(height: 14),
          Text(
            permissionMessage!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.error,
              fontSize: 15,
            ),
          ),
        ],
        const SizedBox(height: 24),
        TextButton(
          onPressed: onSkip,
          child: const Text(
            'Skip for now',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 17,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

class _StepFive extends StatelessWidget {
  const _StepFive({
    required this.controller,
    required this.itemName,
    required this.category,
    required this.location,
    required this.dateLost,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String itemName;
  final String category;
  final String location;
  final DateTime? dateLost;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _StepHeader(
          icon: Icons.person_outline_rounded,
          title: 'How to reach you?',
          subtitle: 'We\'ll keep your info secure',
        ),
        const SizedBox(height: 26),
        _FieldLabel(label: 'Contact Information *'),
        const SizedBox(height: 12),
        _RoundedTextField(
          controller: controller,
          hintText: 'Email or phone number',
          onChanged: (_) => onChanged(),
          suffixIcon: const Icon(
            Icons.chat_bubble_outline_rounded,
            color: Color(0xFFC0C6D2),
          ),
        ),
        const SizedBox(height: 22),
        _ReviewCard(
          itemName: itemName,
          category: category,
          location: location,
          dateLost: dateLost,
        ),
      ],
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _OptionTileData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE50008) : const Color(0xFFF7F8FB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFFE50008) : const Color(0xFFDCE1EA),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(data.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Text(
              data.label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: selected ? Colors.white : const Color(0xFF3E4A5D),
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionGrid extends StatelessWidget {
  const _OptionGrid({
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options
          .map(
            (option) => _ChoiceButton(
              label: option,
              selected: selectedValue == option,
              onTap: () => onSelected(option),
            ),
          )
          .toList(),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 138,
      height: 74,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFF0F1) : const Color(0xFFF3F5F9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? const Color(0xFFFFC7CC) : Colors.transparent,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF3E4A5D),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundedTextField extends StatelessWidget {
  const _RoundedTextField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.maxLines = 1,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final ValueChanged<String> onChanged;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 17, color: Color(0xFF111318)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF8E8E93),
          fontSize: 18,
          height: 1.4,
        ),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 22,
          vertical: maxLines > 1 ? 22 : 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFFD0D7E2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFFD0D7E2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFFFF1A24), width: 1.5),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.value, required this.onTap});

  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? 'yyyy.mm.dd'
        : '${value!.year}.${value!.month.toString().padLeft(2, '0')}.${value!.day.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFD0D7E2)),
        ),
        child: Row(
          children: [
            Text(
              text,
              style: TextStyle(
                color: value == null
                    ? const Color(0xFF111318)
                    : const Color(0xFF111318),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(Icons.calendar_today_outlined, size: 28),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final labelWidget = Text(
      label,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: const Color(0xFF3E4A5D),
        fontSize: 18,
      ),
    );

    if (icon == null) {
      return Align(alignment: Alignment.centerLeft, child: labelWidget);
    }

    return Row(
      children: [
        Icon(icon, size: 28, color: const Color(0xFF4A5568)),
        const SizedBox(width: 10),
        labelWidget,
      ],
    );
  }
}

class _QuickTipsCard extends StatelessWidget {
  const _QuickTipsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFB7D2FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_outlined,
                color: Color(0xFF2556D8),
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Quick Tips',
                style: TextStyle(
                  color: Color(0xFF2556D8),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          _BulletText(text: 'Mention any distinctive markings or stickers'),
          SizedBox(height: 8),
          _BulletText(text: 'Include approximate age/condition'),
          SizedBox(height: 8),
          _BulletText(text: 'Note any damage or wear patterns'),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.itemName,
    required this.category,
    required this.location,
    required this.dateLost,
  });

  final String itemName;
  final String category;
  final String location;
  final DateTime? dateLost;

  @override
  Widget build(BuildContext context) {
    final dateText = dateLost == null
        ? '-'
        : '${dateLost!.year}-${dateLost!.month.toString().padLeft(2, '0')}-${dateLost!.day.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFDDE2EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review Your Report',
            style: TextStyle(
              color: Color(0xFF445066),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          _ReviewRow(label: 'Item:', value: itemName.isEmpty ? '-' : itemName),
          const SizedBox(height: 10),
          _ReviewRow(label: 'Category:', value: category),
          const SizedBox(height: 10),
          _ReviewRow(label: 'Location:', value: location),
          const SizedBox(height: 10),
          _ReviewRow(label: 'Date:', value: dateText),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.enabled,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final background = enabled
        ? const Color(0xFFE50008)
        : const Color(0xFFD9DDE5);
    final foreground = enabled ? Colors.white : const Color(0xFF98A2B3);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 82,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: foreground, size: 22),
              const SizedBox(width: 10),
            ],
            Text(
              label,
              style: TextStyle(
                color: foreground,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 82,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F7),
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF344054),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  const _BulletText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            '\u2022',
            style: TextStyle(
              color: Color(0xFF2556D8),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF2556D8),
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionTileData {
  const _OptionTileData({
    required this.label,
    required this.emoji,
    required this.category,
    this.isManual = false,
  });

  final String label;
  final String emoji;
  final String category;
  final bool isManual;
}
