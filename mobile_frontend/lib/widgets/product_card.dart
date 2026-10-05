import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../core/app_theme.dart';

/// Fixed the image handling: this used to always request
/// https://via.placeholder.com/... with the product name baked into the
/// URL, regardless of whether the product had a real photo. Since
/// Product.fromJson never parsed an `image` field at all, EVERY product —
/// even ones with real backend images — rendered as a gray box with text.
/// Now: the real image when one exists, otherwise a clean local
/// placeholder (no network call, no dependency on an external service
/// staying up).
class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(aspectRatio: 1.1, child: ProductImage(product: product)),
              if (product.isOnSale)
                Positioned(
                  top: 8,
                  left: 8,
                  child: _Badge(
                    text: '-${product.discountPercentage.toStringAsFixed(0)}%',
                    color: AppTheme.danger,
                  ),
                ),
              if (!product.inStock)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.45),
                    child: const Center(
                      child: Text(
                        'Out of Stock',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    product.brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      if (product.isOnSale) ...[
                        Flexible(
                          child: Text(
                            '\$${product.originalPrice.toStringAsFixed(2)}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          '\$${product.displayPrice.toStringAsFixed(2)}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: product.isOnSale ? AppTheme.danger : AppTheme.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared so product detail and the cart tile render images identically.
class ProductImage extends StatelessWidget {
  final Product product;
  final BoxFit fit;
  const ProductImage({super.key, required this.product, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if (product.image == null || product.image!.isEmpty) return _placeholder();
    return CachedNetworkImage(
      imageUrl: product.image!,
      fit: fit,
      placeholder: (context, url) => Container(
        color: Colors.grey.shade100,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppTheme.primary.withOpacity(0.06),
      child: Center(
        child: Icon(Icons.devices_other_outlined, size: 40, color: AppTheme.primary.withOpacity(0.35)),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
