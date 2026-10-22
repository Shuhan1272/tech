import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/empty_state.dart';
import 'product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Fixed: the search field previously had a suffix clear button whose
    // visibility depended on _searchController.text, but nothing ever
    // rebuilt the widget as you typed — so the clear button never
    // appeared until some other setState happened to fire. Listening to
    // the controller keeps the UI in sync with what's actually typed.
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // Fixed: this used to call searchProducts() on EVERY keystroke — a
    // separate network request per character typed, which hammers the
    // backend and causes results to flicker as out-of-order responses
    // land. Debouncing waits until typing pauses.
    _debounce?.cancel();
    final provider = Provider.of<ProductProvider>(context, listen: false);

    if (value.trim().length < 2) {
      provider.resetProducts();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      provider.searchProducts(value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final query = _searchController.text;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          height: 42,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search products, brands...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  _searchController.clear();
                  Provider.of<ProductProvider>(context, listen: false).resetProducts();
                },
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              fillColor: Colors.grey.shade100,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ],
      ),
      body: query.trim().length < 2
          ? const EmptyState(
        icon: Icons.search,
        title: 'Search for products',
        subtitle: 'Type at least 2 characters to start searching',
      )
          : productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : productProvider.products.isEmpty
          ? EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'No results for "$query"',
        subtitle: 'Try a different search term',
      )
          : GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.60,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: productProvider.products.length,
        itemBuilder: (context, index) {
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
}
