import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/category.dart';
import '../core/app_theme.dart';

/// Extracted from a private method inside home_screen.dart so it's a
/// proper reusable widget — the same way CategoryChip already was. The
/// two were doing near-identical layout work but one lived as a
/// screen-private method for no real reason.
///
/// Updated: the tile used to always draw an emoji, even for real backend
/// categories (which come with an `image` URL — this backend's
/// Category.image defaults to categories/default.jpg). It now renders the
/// API image when one exists and only falls back to the emoji placeholder
/// for the handful of hardcoded categories.
class CategoryGridItem extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryGridItem({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = category.image;
    final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.08), shape: BoxShape.circle),
              child: hasImage
                  ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const SizedBox(width: 20, height: 20),
                  errorWidget: (context, url, error) =>
                      Text(category.icon, style: const TextStyle(fontSize: 20)),
                ),
              )
                  : Text(category.icon, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}