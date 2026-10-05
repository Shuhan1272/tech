import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/empty_state.dart';
import 'product_detail_screen.dart';
import 'search_screen.dart';

class ProductListScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialBrand;

  const ProductListScreen({super.key, this.initialCategory, this.initialBrand});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedCategory;
  String? _selectedBrand;
  String? _ordering;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _selectedBrand = widget.initialBrand;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      provider.resetProducts();
      provider.fetchProducts(category: _selectedCategory, brand: _selectedBrand, refresh: true);
      if (provider.categories.isEmpty) provider.fetchCategories();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      if (!provider.isLoading && provider.hasMore) {
        provider.fetchProducts(
          category: _selectedCategory,
          brand: _selectedBrand,
          ordering: _ordering,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _applyFilters({String? category, String? ordering, bool clearCategory = false}) {
    setState(() {
      if (clearCategory) {
        _selectedCategory = null;
      } else if (category != null) {
        _selectedCategory = category;
      }
      if (ordering != null) _ordering = ordering;
    });
    final provider = Provider.of<ProductProvider>(context, listen: false);
    provider.resetProducts();
    provider.fetchProducts(
      category: _selectedCategory,
      brand: _selectedBrand,
      ordering: _ordering,
      refresh: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final hasFilters = _selectedCategory != null || _ordering != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: hasFilters,
              smallSize: 8,
              child: const Icon(Icons.tune),
            ),
            onPressed: () => _showFilterSheet(context, productProvider),
          ),
        ],
      ),
      body: productProvider.isLoading && productProvider.products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : productProvider.products.isEmpty
          ? EmptyState(
        icon: productProvider.errorMessage.isNotEmpty
            ? Icons.cloud_off_outlined
            : Icons.inventory_2_outlined,
        // Surfacing the actual error instead of always claiming
        // "No products found" — a failed request and an empty
        // result set are very different problems, and the old
        // screen made a connection failure look like an empty
        // catalog.
        title: productProvider.errorMessage.isNotEmpty
            ? 'Could not load products'
            : 'No products found',
        subtitle: productProvider.errorMessage.isNotEmpty
            ? productProvider.errorMessage
            : 'Try adjusting your filters',
        actionLabel: productProvider.errorMessage.isNotEmpty
            ? 'Retry'
            : (hasFilters ? 'Clear filters' : null),
        onAction: productProvider.errorMessage.isNotEmpty
            ? () => _applyFilters(clearCategory: false)
            : (hasFilters ? () => _applyFilters(clearCategory: true) : null),
      )
          : GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.60,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: productProvider.products.length + (productProvider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == productProvider.products.length) {
            return const Center(
              child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()),
            );
          }
          final product = productProvider.products[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProductDetailScreen(slug: product.slug)),
            ),
            child: ProductCard(product: product),
          );
        },
      ),
    );
  }

  void _showFilterSheet(BuildContext context, ProductProvider productProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filters', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 20),
                  Text('Category', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  // Fixed: this used to be a hardcoded list of
                  // ['All', 'Electronics', 'Accessories', 'Home'] that had
                  // nothing to do with the categories the app actually
                  // fetches (Trimmer, Mini UPS, AC...), so picking one
                  // would never match any real product. It also passed the
                  // display NAME as the filter value while the API expects
                  // a slug. Both fixed: real categories, filtered by slug.
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _selectedCategory == null,
                        onSelected: (_) {
                          _applyFilters(clearCategory: true);
                          Navigator.pop(sheetContext);
                        },
                      ),
                      ...productProvider.displayCategories.map((category) {
                        return ChoiceChip(
                          label: Text(category.name),
                          selected: _selectedCategory == category.slug,
                          onSelected: (_) {
                            _applyFilters(category: category.slug);
                            Navigator.pop(sheetContext);
                          },
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Sort by', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  // Fixed: the sort chips previously had selected: false
                  // hardcoded and an empty onSelected with a "// Handle
                  // sort" comment — they did nothing. These now pass real
                  // DRF ordering values through to the API.
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _sortChip(sheetContext, 'Newest', '-created_at'),
                      _sortChip(sheetContext, 'Price: Low to High', 'price'),
                      _sortChip(sheetContext, 'Price: High to Low', '-price'),
                      _sortChip(sheetContext, 'Name (A–Z)', 'name'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _ordering = null);
                        _applyFilters(clearCategory: true);
                        Navigator.pop(sheetContext);
                      },
                      child: const Text('Reset Filters'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sortChip(BuildContext sheetContext, String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _ordering == value,
      onSelected: (_) {
        _applyFilters(ordering: value);
        Navigator.pop(sheetContext);
      },
    );
  }
}
