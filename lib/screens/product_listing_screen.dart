import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/app_data.dart';
import '../state/app_state.dart';
import '../services/firestore_service.dart';
import 'product_details_screen.dart';
import 'home_screen.dart';
import 'cart_screen.dart';

class ProductListingScreen extends StatefulWidget {
  final String category;
  const ProductListingScreen({super.key, required this.category});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  static const navyBlue = Color(0xFF1B2F5E);
  static const gold = Color(0xFFC9A84C);

  String _sort = 'Default';
  final FirestoreService _firestoreService = FirestoreService();

  static String _emojiFor(String category) {
    switch (category) {
      case 'Women':
        return '👗';
      case 'Kids':
        return '🧒';
      case 'Sale':
        return '🏷️';
      default:
        return '🧥';
    }
  }

  List<ProductModel> _applySort(List<ProductModel> list) {
    final sorted = List<ProductModel>.from(list);
    if (_sort == 'Price: Low') {
      sorted.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sort == 'Price: High') {
      sorted.sort((a, b) => b.price.compareTo(a.price));
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar: cart badge from Firestore ────────────────────────
            StreamBuilder<List<CartItem>>(
              stream: uid.isNotEmpty
                  ? _firestoreService.getCartStream(uid)
                  : const Stream.empty(),
              builder: (context, snapshot) {
                final cartCount = (snapshot.data ?? [])
                    .fold<int>(0, (s, i) => s + i.quantity);
                return _buildTopBar(context, cartCount);
              },
            ),
            // ── Product grid from Firestore ───────────────────────────────
            Expanded(
              child: StreamBuilder<List<ProductModel>>(
                stream: _firestoreService.getProductsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final all = snapshot.data ?? [];
                  final filtered = widget.category == 'All'
                      ? all
                      : all
                          .where((p) => p.category == widget.category)
                          .toList();
                  final products = _applySort(filtered);
                  return _buildGrid(context, uid, products);
                },
              ),
            ),
            HomeScreen.buildBottomNav(context, 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, int cartCount) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child:
                const Icon(Icons.arrow_back_ios, size: 18, color: navyBlue),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.category,
              style: const TextStyle(
                color: navyBlue,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DropdownButton<String>(
            value: _sort,
            underline: const SizedBox(),
            style: const TextStyle(color: navyBlue, fontSize: 12),
            items: ['Default', 'Price: Low', 'Price: High']
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _sort = v!),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
            child: Stack(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    size: 18,
                    color: navyBlue,
                  ),
                ),
                if (cartCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: gold,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(
      BuildContext context, String uid, List<ProductModel> products) {
    if (products.isEmpty) {
      return const Center(
        child:
            Text('No products found.', style: TextStyle(color: Colors.grey)),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        final emoji = _emojiFor(p.category);
        final priceStr = '\$${p.price.toStringAsFixed(0)}';

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(
                name: p.name,
                price: priceStr,
                priceVal: p.price,
                emoji: emoji,
                category: p.category,
                image: p.image,
              ),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.asset(
                        p.image,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: navyBlue,
                              ),
                            ),
                            Text(
                              priceStr,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (uid.isEmpty) return;
                          final item = CartItem(
                            id: '${p.id}_${p.sizes.isNotEmpty ? p.sizes.first : 'M'}_${p.colors.isNotEmpty ? p.colors.first : 'default'}',
                            name: p.name,
                            price: priceStr,
                            emoji: emoji,
                            image: p.image,
                            priceValue: p.price,
                            size: p.sizes.isNotEmpty ? p.sizes.first : 'M',
                            color: p.colors.isNotEmpty
                                ? p.colors.first
                                : 'default',
                          );
                          await _firestoreService.addToCart(uid, item);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${p.name} added to cart'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: navyBlue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}