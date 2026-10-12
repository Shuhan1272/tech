import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../core/app_theme.dart';
import '../core/snackbar_helper.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String slug;
  const ProductDetailScreen({super.key, required this.slug});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Product?> _productFuture;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _productFuture = Provider.of<ProductProvider>(context, listen: false).getProductBySlug(widget.slug);
  }

  void _addToCart(Product product, {required bool buyNow}) {
    // Fixed: both of these buttons previously had EMPTY onPressed
    // callbacks — the core "buy something" action of a shopping app did
    // nothing at all when tapped.
    context.read<CartProvider>().addProduct(product, quantity: _quantity);
    if (buyNow) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
    } else {
      AppSnackbar.showInfo(
        context,
        'Added to cart',
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.white,
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().itemCount;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Badge(
              label: Text('$cartCount'),
              isLabelVisible: cartCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
          ),
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
        ],
      ),
      body: FutureBuilder<Product?>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('Product not found', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Go Back')),
                ],
              ),
            );
          }

          final product = snapshot.data!;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fixed: this used to request an external placeholder
                    // image service for every product. Now it uses the
                    // shared ProductImage widget — real backend image if
                    // present, clean local placeholder otherwise.
                    Container(
                      color: Colors.grey.shade50,
                      child: AspectRatio(
                        aspectRatio: 1.15,
                        child: ProductImage(product: product, fit: BoxFit.contain),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _Tag(text: product.brand, filled: true),
                              const SizedBox(width: 8),
                              Flexible(child: _Tag(text: product.category, filled: false)),
                              const Spacer(),
                              if (product.isOnSale)
                                _Tag(
                                  text: '-${product.discountPercentage.toStringAsFixed(0)}% OFF',
                                  color: AppTheme.danger,
                                  textColor: Colors.white,
                                  filled: true,
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${product.displayPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: product.isOnSale ? AppTheme.danger : AppTheme.primaryDark,
                                ),
                              ),
                              if (product.isOnSale) ...[
                                const SizedBox(width: 10),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '\$${product.originalPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade400,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                product.inStock ? Icons.check_circle_outline : Icons.remove_circle_outline,
                                size: 16,
                                color: product.inStock ? AppTheme.success : AppTheme.danger,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                product.inStock ? '${product.stock} in stock' : 'Out of stock',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: product.inStock ? AppTheme.success : AppTheme.danger,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // NEW: quantity selector. Previously you could
                          // only ever add a single unit (and in fact
                          // couldn't add anything at all).
                          if (product.inStock) ...[
                            Row(
                              children: [
                                Text('Quantity', style: Theme.of(context).textTheme.titleMedium),
                                const Spacer(),
                                _QuantityButton(
                                  icon: Icons.remove,
                                  onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
                                ),
                                Container(
                                  width: 44,
                                  alignment: Alignment.center,
                                  child: Text('$_quantity', style: Theme.of(context).textTheme.titleMedium),
                                ),
                                _QuantityButton(
                                  icon: Icons.add,
                                  onTap: _quantity < product.stock ? () => setState(() => _quantity++) : null,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 12),
                          ],

                          if (product.keyFeature.isNotEmpty) ...[
                            Text('Key Features', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 10),
                            ...product.keyFeature.entries.map(
                                  (entry) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.check_circle, size: 16, color: AppTheme.primary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text('${entry.key}: ${entry.value}',
                                          style: Theme.of(context).textTheme.bodyLarge),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          if (product.colors.isNotEmpty) ...[
                            Text('Colors', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: product.colors
                                  .map((c) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(c, style: const TextStyle(fontSize: 13)),
                              ))
                                  .toList(),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // NEW: renders the `specification` map, which the
                          // Product model has always parsed but no screen
                          // ever displayed — specs are a headline feature
                          // in your project proposal.
                          if (product.specification.isNotEmpty) ...[
                            Text('Specifications', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: product.specification.entries.map((entry) {
                                  final isLast = entry.key == product.specification.entries.last.key;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: isLast
                                          ? null
                                          : Border(bottom: BorderSide(color: Colors.grey.shade200)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 120,
                                          child: Text(entry.key,
                                              style: const TextStyle(
                                                  fontSize: 13, color: AppTheme.textSecondary)),
                                        ),
                                        Expanded(
                                          child: Text('${entry.value}',
                                              style: const TextStyle(
                                                  fontSize: 13, fontWeight: FontWeight.w500)),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          Text('Description', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            product.description.isNotEmpty ? product.description : 'No description available.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Sticky bottom bar — keeps the primary action reachable
              // without scrolling to the end of a long spec list.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -2)),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: OutlinedButton(
                            onPressed: product.inStock ? () => _addToCart(product, buyNow: false) : null,
                            child: const Text('Add to Cart'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                            onPressed: product.inStock ? () => _addToCart(product, buyNow: true) : null,
                            child: Text(product.inStock ? 'Buy Now' : 'Out of Stock'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final bool filled;
  final Color? color;
  final Color? textColor;

  const _Tag({required this.text, required this.filled, this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? (filled ? AppTheme.primary.withOpacity(0.08) : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor ?? (filled ? AppTheme.primaryDark : AppTheme.textSecondary),
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: onTap == null ? Colors.grey.shade300 : AppTheme.textPrimary),
      ),
    );
  }
}
