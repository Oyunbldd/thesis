import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../controllers/item_controller.dart';
import '../../models/item_report_model.dart';
import '../../services/matching_service.dart';
import '../../utils/app_theme.dart';

class ReportFoundItemView extends StatefulWidget {
  const ReportFoundItemView({super.key});

  @override
  State<ReportFoundItemView> createState() => _ReportFoundItemViewState();
}

class _ReportFoundItemViewState extends State<ReportFoundItemView> {
  static const _categories = <String>[
    'Electronics',
    'Accessories',
    'Books',
    'Clothing',
    'Keys',
    'IDs',
    'Documents',
    'Bottles',
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
  bool _isPickingImage = false;
  String? _selectedImagePath;
  String? _photoPermissionMessage;
  String? _selectedCategory;
  String? _selectedLocation;
  DateTime? _dateFound;

  final TextEditingController _quickDescriptionController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _quickDescriptionController.dispose();
    _notesController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  bool get _canContinue {
    switch (_step) {
      case 0:
        return _selectedImagePath != null;
      case 1:
        return _selectedCategory != null;
      case 2:
        return _selectedLocation != null && _dateFound != null;
      case 3:
        return _contactController.text.trim().isNotEmpty;
      default:
        return false;
    }
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

  void _skipPhoto() {
    setState(() {
      _step += 1;
    });
  }

  Future<void> _goNext() async {
    if (!_canContinue || _isSubmitting) return;

    if (_step == 3) {
      setState(() => _isSubmitting = true);
      try {
        final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
        final email = FirebaseAuth.instance.currentUser?.email ?? '';
        final report = ItemReportModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _quickDescriptionController.text.trim(),
          description: _notesController.text.trim(),
          category: _selectedCategory!,
          type: 'found',
          status: 'open',
          imageUrl: _selectedImagePath ?? '',
          location: _selectedLocation!,
          date: _dateFound!,
          userId: uid,
          userEmail: email,
        );
        await _itemController.createReport(report);
        // Run matching in background — don't await so UI pops immediately
        MatchingService().findMatchesAndNotify(report);
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit report: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
      return;
    }

    setState(() {
      _step += 1;
    });
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

    setState(() => _isPickingImage = true);

    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _selectedImagePath = image.path;
        _photoPermissionMessage = null;
      });
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateFound ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dateFound = picked;
      });
    }
  }

  static const _stepTitles = [
    'Add a Photo',
    'What Type of Item?',
    'Where Did You Find It?',
    'Contact Details',
  ];

  static const _stepNextLabels = [
    'Item Category',
    'Location & Date',
    'Contact Info',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _FoundHeader(onBack: _goBack),
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
                    _FoundProgressHeader(
                      step: _step + 1,
                      totalSteps: 4,
                      title: _stepTitles[_step],
                      nextLabel: _step < 3 ? _stepNextLabels[_step] : null,
                    ),
                    const SizedBox(height: 26),
                    ...switch (_step) {
                      0 => [
                        _FoundPhotoStep(
                          imagePath: _selectedImagePath,
                          permissionMessage: _photoPermissionMessage,
                          isPickingImage: _isPickingImage,
                          onPickPhoto: _pickGalleryImage,
                          onSkip: _skipPhoto,
                        ),
                      ],
                      1 => [
                        _FoundCategoryStep(
                          selectedCategory: _selectedCategory,
                          controller: _quickDescriptionController,
                          onCategorySelected: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                          onChanged: () => setState(() {}),
                        ),
                      ],
                      2 => [
                        _FoundLocationStep(
                          selectedLocation: _selectedLocation,
                          dateFound: _dateFound,
                          notesController: _notesController,
                          onLocationSelected: (value) {
                            setState(() {
                              _selectedLocation = value;
                            });
                          },
                          onPickDate: _pickDate,
                          onChanged: () => setState(() {}),
                        ),
                      ],
                      _ => [
                        _FoundReviewStep(
                          controller: _contactController,
                          imagePath: _selectedImagePath,
                          category: _selectedCategory ?? '-',
                          location: _selectedLocation ?? '-',
                          dateFound: _dateFound,
                          onChanged: () => setState(() {}),
                        ),
                      ],
                    },
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        if (_step > 0)
                          Expanded(
                            child: _FoundSecondaryButton(
                              label: 'Back',
                              onTap: _goBack,
                            ),
                          ),
                        if (_step > 0) const SizedBox(width: 16),
                        Expanded(
                          child: _FoundPrimaryButton(
                            label: _step == 3 ? 'Post Found Item' : 'Continue',
                            enabled: _canContinue,
                            isLoading: _isSubmitting,
                            onTap: _goNext,
                            icon: _step == 3
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

class _FoundHeader extends StatelessWidget {
  const _FoundHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
      decoration: const BoxDecoration(
        color: Color(0xFF3FA247),
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
                'Report Found Item',
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

class _FoundProgressHeader extends StatelessWidget {
  const _FoundProgressHeader({
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
                  Color(0xFF3FA247),
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

class _FoundStepHeader extends StatelessWidget {
  const _FoundStepHeader({
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
        Icon(icon, color: const Color(0xFF3FA247), size: 76),
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

class _FoundPhotoStep extends StatelessWidget {
  const _FoundPhotoStep({
    required this.imagePath,
    required this.permissionMessage,
    required this.isPickingImage,
    required this.onPickPhoto,
    required this.onSkip,
  });

  final String? imagePath;
  final String? permissionMessage;
  final bool isPickingImage;
  final VoidCallback onPickPhoto;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = imagePath != null;

    return Column(
      children: [
        const _FoundStepHeader(
          icon: Icons.photo_camera_outlined,
          title: 'Take a photo of the item',
          subtitle: 'A clear photo helps the owner identify it',
        ),
        const SizedBox(height: 28),
        InkWell(
          onTap: onPickPhoto,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF4FFF6), Color(0xFFEBFFF0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFF97EDAE),
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: Column(
              children: [
                if (isPickingImage)
                  const SizedBox(
                    height: 220,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xFF3FA247),
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading photo...',
                            style: TextStyle(
                              color: Color(0xFF338347),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (hasPhoto)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.file(
                      File(imagePath!),
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else ...[
                  Container(
                    width: 148,
                    height: 148,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3FA247),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_camera_outlined,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Take Photo Now',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF255437),
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Or upload from gallery',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF338347),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'PNG, JPG up to 10MB',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF3FA247),
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
        const SizedBox(height: 22),
        TextButton(
          onPressed: onSkip,
          child: const Text(
            'Skip for now',
            style: TextStyle(
              color: Color(0xFF5D8A66),
              fontSize: 17,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(height: 14),
        const _FoundTipsCard(),
      ],
    );
  }
}

class _FoundCategoryStep extends StatelessWidget {
  const _FoundCategoryStep({
    required this.selectedCategory,
    required this.controller,
    required this.onCategorySelected,
    required this.onChanged,
  });

  final String? selectedCategory;
  final TextEditingController controller;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _FoundStepHeader(
          icon: Icons.inventory_2_outlined,
          title: 'What type of item?',
          subtitle: 'Select the category that fits best',
        ),
        const SizedBox(height: 28),
        _FoundOptionGrid(
          options: _ReportFoundItemViewState._categories,
          selectedValue: selectedCategory,
          onSelected: onCategorySelected,
        ),
        const SizedBox(height: 26),
        _FoundFieldLabel(label: 'Quick Description (Optional)'),
        const SizedBox(height: 12),
        _FoundTextField(
          controller: controller,
          hintText: 'e.g., Red Nike Backpack, iPhone with blue case',
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'The photo is the main identifier',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF667085),
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}

class _FoundLocationStep extends StatelessWidget {
  const _FoundLocationStep({
    required this.selectedLocation,
    required this.dateFound,
    required this.notesController,
    required this.onLocationSelected,
    required this.onPickDate,
    required this.onChanged,
  });

  final String? selectedLocation;
  final DateTime? dateFound;
  final TextEditingController notesController;
  final ValueChanged<String> onLocationSelected;
  final VoidCallback onPickDate;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _FoundStepHeader(
          icon: Icons.location_on_outlined,
          title: 'Where did you find it?',
          subtitle: 'This helps the owner verify ownership',
        ),
        const SizedBox(height: 26),
        _FoundFieldLabel(
          label: 'Location Found *',
          icon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 14),
        _FoundOptionGrid(
          options: _ReportFoundItemViewState._locations,
          selectedValue: selectedLocation,
          onSelected: onLocationSelected,
        ),
        const SizedBox(height: 26),
        _FoundFieldLabel(
          label: 'Date Found *',
          icon: Icons.calendar_today_outlined,
        ),
        const SizedBox(height: 12),
        _FoundDateField(value: dateFound, onTap: onPickDate),
        const SizedBox(height: 24),
        _FoundFieldLabel(label: 'Additional Notes (Optional)'),
        const SizedBox(height: 12),
        _FoundTextField(
          controller: notesController,
          hintText: 'Add anything that may help verify the owner',
          maxLines: 4,
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}

class _FoundReviewStep extends StatelessWidget {
  const _FoundReviewStep({
    required this.controller,
    required this.imagePath,
    required this.category,
    required this.location,
    required this.dateFound,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String? imagePath;
  final String category;
  final String location;
  final DateTime? dateFound;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _FoundStepHeader(
          icon: Icons.person_outline_rounded,
          title: 'Where can you be reached?',
          subtitle: 'For the owner to contact you',
        ),
        const SizedBox(height: 26),
        _FoundFieldLabel(label: 'Contact Information *'),
        const SizedBox(height: 12),
        _FoundTextField(
          controller: controller,
          hintText: 'Email or phone number',
          onChanged: (_) => onChanged(),
          suffixIcon: const Icon(
            Icons.chat_bubble_outline_rounded,
            color: Color(0xFFC0C6D2),
          ),
        ),
        const SizedBox(height: 24),
        _FoundReadyCard(
          imagePath: imagePath,
          category: category,
          location: location,
          dateFound: dateFound,
        ),
        const SizedBox(height: 18),
        const _FoundInfoTip(),
      ],
    );
  }
}

class _FoundTipsCard extends StatelessWidget {
  const _FoundTipsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF2FFF4),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFB6F0C0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_outlined,
                color: Color(0xFF3FA247),
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Photo Tips',
                style: TextStyle(
                  color: Color(0xFF255437),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          _FoundBulletText(text: 'Use good lighting and clear focus'),
          SizedBox(height: 8),
          _FoundBulletText(text: 'Show any distinctive features or labels'),
          SizedBox(height: 8),
          _FoundBulletText(text: 'Avoid including personal info in the photo'),
        ],
      ),
    );
  }
}

class _FoundReadyCard extends StatelessWidget {
  const _FoundReadyCard({
    required this.imagePath,
    required this.category,
    required this.location,
    required this.dateFound,
  });

  final String? imagePath;
  final String category;
  final String location;
  final DateTime? dateFound;

  @override
  Widget build(BuildContext context) {
    final dateText = dateFound == null
        ? '-'
        : '${dateFound!.year}-${dateFound!.month.toString().padLeft(2, '0')}-${dateFound!.day.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF1FFF5), Color(0xFFE6FAEB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFA8EFBE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF255437),
                size: 30,
              ),
              SizedBox(width: 10),
              Text(
                'Ready to Post',
                style: TextStyle(
                  color: Color(0xFF255437),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: imagePath != null
                ? Image.file(
                    File(imagePath!),
                    height: 170,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 170,
                    width: double.infinity,
                    color: Colors.white,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.photo_camera_outlined,
                      size: 52,
                      color: Color(0xFF98A2B3),
                    ),
                  ),
          ),
          const SizedBox(height: 18),
          _FoundReviewRow(label: 'Category:', value: category),
          const SizedBox(height: 10),
          _FoundReviewRow(label: 'Location:', value: location),
          const SizedBox(height: 10),
          _FoundReviewRow(label: 'Date:', value: dateText),
        ],
      ),
    );
  }
}

class _FoundInfoTip extends StatelessWidget {
  const _FoundInfoTip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFB7D2FF)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF2E5CE6), size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tip: When contacted, verify the owner by asking them to describe specific details not visible in your photo.',
              style: TextStyle(
                color: Color(0xFF1E40AF),
                fontSize: 16,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoundOptionGrid extends StatelessWidget {
  const _FoundOptionGrid({
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
            (option) => _FoundChoiceButton(
              label: option,
              selected: selectedValue == option,
              onTap: () => onSelected(option),
            ),
          )
          .toList(),
    );
  }
}

class _FoundChoiceButton extends StatelessWidget {
  const _FoundChoiceButton({
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
      width: 136,
      height: 74,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF41AD4A) : const Color(0xFFF3F5F9),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: selected ? Colors.white : const Color(0xFF3E4A5D),
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

class _FoundTextField extends StatelessWidget {
  const _FoundTextField({
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
          borderSide: const BorderSide(color: Color(0xFF41AD4A), width: 1.5),
        ),
      ),
    );
  }
}

class _FoundDateField extends StatelessWidget {
  const _FoundDateField({required this.value, required this.onTap});

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
              style: const TextStyle(
                color: Color(0xFF111318),
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

class _FoundFieldLabel extends StatelessWidget {
  const _FoundFieldLabel({required this.label, this.icon});

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

class _FoundReviewRow extends StatelessWidget {
  const _FoundReviewRow({required this.label, required this.value});

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
              color: Color(0xFF338347),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF255437),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _FoundPrimaryButton extends StatelessWidget {
  const _FoundPrimaryButton({
    required this.label,
    required this.enabled,
    required this.onTap,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final active = enabled && !isLoading;
    final background = active
        ? const Color(0xFF3FA247)
        : const Color(0xFFD9DDE5);
    final foreground = active ? Colors.white : const Color(0xFF98A2B3);

    return InkWell(
      onTap: active ? onTap : null,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 82,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(24),
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: foreground, size: 22),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _FoundSecondaryButton extends StatelessWidget {
  const _FoundSecondaryButton({required this.label, required this.onTap});

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

class _FoundBulletText extends StatelessWidget {
  const _FoundBulletText({required this.text});

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
              color: Color(0xFF2E7D32),
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
              color: Color(0xFF2E7D32),
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
