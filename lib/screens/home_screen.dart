import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../state/app_state.dart';
import '../data/app_data.dart';
import '../services/firestore_service.dart';
import 'product_listing_screen.dart';
import 'product_details_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const navyBlue = Color(0xFF1B2F5E);
  static const gold = Color(0xFFC9A84C);

  // ── emoji helper (local, no Firestore needed) ──────────────────────────
  static String _emojiFor(String category) {
    switch (category) {
      case 'Women':
        return '👗';
      case 'Kids':
        return '🧒';
      case 'Sale':
        return '🏷️';
      default:
        return '🧥'; // Men / fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar: cart badge now driven by Firestore ──────────────
            StreamBuilder<List<CartItem>>(
              stream: uid.isNotEmpty
                  ? firestoreService.getCartStream(uid)
                  : const Stream.empty(),
              builder: (context, snapshot) {
                final cartCount = (snapshot.data ?? []).fold<int>(
                  0,
                  (s, i) => s + i.quantity,
                );
                return _buildTopBar(context, state, cartCount);
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildBanner(context),
                    _buildCategories(context),
                    // ── Featured: now from Firestore ─────────────────────
                    StreamBuilder<List<ProductModel>>(
                      stream: firestoreService.getFeaturedProductsStream(),
                      builder: (context, snapshot) {
                        final products = snapshot.data ?? [];
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            products.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          );
                        }
                        return _buildFeatured(
                          context,
                          uid,
                          firestoreService,
                          products,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            buildBottomNav(context, 0),
          ],
        ),
      ),
    );
  }

  // ── Top bar (cart count passed in from StreamBuilder) ──────────────────
  Widget _buildTopBar(BuildContext context, AppState state, int cartCount) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'LuxeWear',
                style: TextStyle(
                  color: navyBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (state.currentUser != null)
                Text(
                  'Hi, ${state.currentUser!.name}',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                  ),
                ),
            ],
          ),
          Row(
            children: [
              _iconCircle(Icons.search),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
                child: Stack(
                  children: [
                    _iconCircle(Icons.shopping_cart_outlined),
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
        ],
      ),
    );
  }

  Widget _iconCircle(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: navyBlue),
    );
  }

  Widget _buildBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ProductListingScreen(category: 'Sale'),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(16),
        height: 160,
        decoration: BoxDecoration(
          color: navyBlue,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'New Collection',
                      style: TextStyle(color: Color(0xFFA8B8D8), fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Spring 2026',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Up to 40% off',
                      style: TextStyle(color: Color(0xFFA8B8D8), fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: gold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Shop Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Image.asset(
                'assets/images/Banner.jpg',
                width: 160,
                height: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = [
      {'label': 'Men', 'image': 'assets/images/Men.jpg'},
      {'label': 'Women', 'image': 'assets/images/women.jpg'},
      {'label': 'Kids', 'image': 'assets/images/kids.jpg'},
      {'label': 'Sale', 'image': 'assets/images/sale.jpg'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Categories',
                style: TextStyle(
                  color: navyBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProductListingScreen(category: 'All'),
                  ),
                ),
                child: const Text(
                  'See all',
                  style: TextStyle(color: gold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: categories.asMap().entries.map((entry) {
              final i = entry.key;
              final cat = entry.value;
              return Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductListingScreen(category: cat['label']!),
                    ),
                  ),
                  child: Container(
                    margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          Image.asset(
                            cat['image']!,
                            width: double.infinity,
                            height: 80,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: navyBlue.withOpacity(0.55),
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                cat['label']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Featured section: receives live products from Firestore ─────────────
  Widget _buildFeatured(
    BuildContext context,
    String uid,
    FirestoreService firestoreService,
    List<ProductModel> products,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Featured',
                style: TextStyle(
                  color: navyBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProductListingScreen(category: 'All'),
                  ),
                ),
                child: const Text(
                  'See all',
                  style: TextStyle(color: gold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              final emoji = _emojiFor(p.category);
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailsScreen(
                      name: p.name,
                      price: '\$${p.price.toStringAsFixed(0)}',
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: navyBlue,
                                  ),
                                ),
                                Text(
                                  '\$${p.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: gold,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (uid.isEmpty) return;
                                final item = CartItem(
                                  id: '${p.id}_M_${p.colors.isNotEmpty ? p.colors.first : 'default'}',
                                  name: p.name,
                                  price: '\$${p.price.toStringAsFixed(0)}',
                                  emoji: emoji,
                                  image: p.image,
                                  priceValue: p.price,
                                  size: p.sizes.isNotEmpty
                                      ? p.sizes.first
                                      : 'M',
                                  color: p.colors.isNotEmpty
                                      ? p.colors.first
                                      : 'default',
                                );
                                await firestoreService.addToCart(uid, item);
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
          ),
        ],
      ),
    );
  }

  static Widget buildBottomNav(BuildContext context, int current) {
    final items = [
      {'icon': Icons.home_outlined, 'label': 'Home'},
      {'icon': Icons.checkroom_outlined, 'label': 'Shop'},
      {'icon': Icons.shopping_cart_outlined, 'label': 'Cart'},
      {'icon': Icons.person_outline, 'label': 'Profile'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final isActive = i == current;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (i == 0 && current != 0) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (r) => false,
                  );
                }
                if (i == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ProductListingScreen(category: 'All'),
                    ),
                  );
                }
                if (i == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                }
                if (i == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 22,
                      color: isActive ? navyBlue : Colors.grey,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['label'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        color: isActive ? navyBlue : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
