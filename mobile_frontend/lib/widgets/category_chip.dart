import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/category.dart';
import '../core/app_theme.dart';

class CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = category.image_url ?? category.image ?? '';
    final hasImage = imageUrl.trim().isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(
                  color: Colors.grey.shade200,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasImage)
              ClipOval(
                child: SvgPicture.network(
                  imageUrl,
                  width: 16,
                  height: 16,
                  fit: BoxFit.contain,
                  placeholderBuilder: (context) =>
                      const SizedBox(
                    width: 16,
                    height: 16,
                  ),
                ),
              ),
            if (hasImage) const SizedBox(width: 6),
            Text(
              category.name,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
