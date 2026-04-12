import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class ItemData {
  const ItemData({
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.category,
    required this.contactEmail,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
    required this.isLost,
    this.imageUrl = '',
    this.userId = '',
  });

  final String title;
  final String description;
  final String location;
  final String date;
  final String category;
  final String contactEmail;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;
  final bool isLost;
  final String imageUrl;
  final String userId;
}

class ItemSearchBar extends StatelessWidget {
  const ItemSearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondary.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontSize: 19,
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search items...',
          hintStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 19,
            color: AppTheme.textSecondary.withValues(alpha: 0.75),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 34,
            color: AppTheme.textSecondary.withValues(alpha: 0.7),
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                  icon: const Icon(Icons.close_rounded),
                  color: AppTheme.textSecondary,
                )
              : null,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 20,
          ),
        ),
      ),
    );
  }
}

class ItemCategoryChip extends StatelessWidget {
  const ItemCategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F0FF) : AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFFC7D8FF) : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class ItemEmptyState extends StatelessWidget {
  const ItemEmptyState({
    required this.selectedCategory,
    required this.searchQuery,
  });

  final String selectedCategory;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final filterText = selectedCategory == 'All'
        ? 'all categories'
        : selectedCategory;
    final queryText = searchQuery.trim().isEmpty
        ? 'without a search term'
        : 'for "${searchQuery.trim()}"';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 40,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 14),
          Text(
            'No matching items',
            style: textTheme.titleLarge?.copyWith(
              fontSize: 19,
              color: AppTheme.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search or category. Right now we found nothing in $filterText $queryText.',
            style: textTheme.bodyMedium?.copyWith(height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  const ItemCard({required this.item, required this.onTap});

  final ItemData item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppTheme.secondary.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                child: SizedBox(
                  height: 235,
                  width: double.infinity,
                  child: item.imageUrl.isNotEmpty
                      ? Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) =>
                              progress == null
                              ? child
                              : _ItemImagePlaceholder(item: item),
                          errorBuilder: (_, __, ___) =>
                              _ItemImagePlaceholder(item: item),
                        )
                      : _ItemImagePlaceholder(item: item),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: 24,
                        color: AppTheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      item.description,
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        height: 1.45,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ItemInfoRow(
                      icon: Icons.location_on_outlined,
                      text: item.location,
                    ),
                    const SizedBox(height: 12),
                    ItemInfoRow(
                      icon: Icons.access_time_outlined,
                      text: item.date,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemImagePlaceholder extends StatelessWidget {
  const _ItemImagePlaceholder({required this.item});

  final ItemData item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [item.backgroundColor, item.accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _CategoryBadge(label: item.category),
          const Spacer(),
          Align(
            alignment: Alignment.bottomLeft,
            child: Icon(
              item.icon,
              size: 120,
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE5EEFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppTheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class ItemInfoRow extends StatelessWidget {
  const ItemInfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 28),
        const SizedBox(width: 12),
        Text(
          text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 17,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class ItemDetailsView extends StatefulWidget {
  const ItemDetailsView({super.key, required this.item, this.scrollController});

  final ItemData item;
  final ScrollController? scrollController;

  @override
  State<ItemDetailsView> createState() => _ItemDetailsViewState();
}

class _ItemDetailsViewState extends State<ItemDetailsView> {
  String _resolvedEmail = '';

  @override
  void initState() {
    super.initState();
    _fetchEmail();
  }

  Future<void> _fetchEmail() async {
    print('=== _fetchEmail called, userId: ${widget.item.userId}');
    if (widget.item.userId.isEmpty) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.item.userId)
        .get();
    print('=== doc exists: ${doc.exists}, data: ${doc.data()}');
    final email = doc.data()?['email'] as String? ?? '';
    print('=== resolved email: $email');
    if (email.isNotEmpty && mounted) {
      setState(() => _resolvedEmail = email);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isLost = widget.item.isLost;
    final item = widget.item;
    final contactEmail = _resolvedEmail.isNotEmpty
        ? _resolvedEmail
        : item.contactEmail;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: SingleChildScrollView(
        controller: widget.scrollController,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 54,
                height: 6,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 18, 22, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Item Details',
                      style: textTheme.headlineMedium?.copyWith(
                        color: AppTheme.secondary,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 30),
                    color: AppTheme.secondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: item.imageUrl.isNotEmpty
                      ? Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) =>
                              progress == null
                              ? child
                              : _ItemImagePlaceholder(item: item),
                          errorBuilder: (_, __, ___) =>
                              _ItemImagePlaceholder(item: item),
                        )
                      : _ItemImagePlaceholder(item: item),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 26, 26, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: textTheme.headlineLarge?.copyWith(
                        color: AppTheme.secondary,
                        fontSize: 30,
                        height: 1.15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  _ItemStatusBadge(isLost: isLost),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 18, 26, 0),
              child: Text(
                item.description,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 17,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                children: [
                  ItemDetailInfoCard(
                    icon: Icons.sell_outlined,
                    label: 'Category',
                    value: item.category,
                  ),
                  const SizedBox(height: 12),
                  ItemDetailInfoCard(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    value: item.location,
                  ),
                  const SizedBox(height: 12),
                  ItemDetailInfoCard(
                    icon: Icons.access_time_outlined,
                    label: 'Date',
                    value: item.date,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 24, 26, 0),
              child: Divider(
                color: AppTheme.border.withValues(alpha: 0.85),
                height: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 26, 26, 0),
              child: Text(
                'Contact Information',
                style: textTheme.headlineMedium?.copyWith(
                  color: AppTheme.secondary,
                  fontSize: 22,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 16, 26, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isLost
                        ? const [Color(0xFFEAF2FF), Color(0xFFD9E8FF)]
                        : const [Color(0xFFEAFBF0), Color(0xFFD5F4E0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLost
                          ? 'If you found this item, please contact:'
                          : 'To claim this item, please contact:',
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      contactEmail.isNotEmpty ? contactEmail : 'Not available',
                      style: textTheme.headlineMedium?.copyWith(
                        color: isLost
                            ? AppTheme.primary
                            : const Color(0xFF15803D),
                        fontSize: 22,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 22, 26, 0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemStatusBadge extends StatelessWidget {
  const _ItemStatusBadge({required this.isLost});

  final bool isLost;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        color: isLost ? const Color(0xFFFDE2E2) : const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isLost ? 'Lost' : 'Found',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: isLost ? const Color(0xFFDC2626) : const Color(0xFF15803D),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class ItemDetailInfoCard extends StatelessWidget {
  const ItemDetailInfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, color: AppTheme.primary, size: 30),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: textTheme.headlineMedium?.copyWith(
                    color: AppTheme.secondary,
                    fontSize: 19,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
