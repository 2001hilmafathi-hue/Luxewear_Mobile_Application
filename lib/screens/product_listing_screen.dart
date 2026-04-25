import 'package:flutter/material.dart';
import '../state/app_state.dart';
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

  static const _allProducts = [
    {
      'name': 'Classic Blazer',
      'price': r'$89',
      'priceVal': 89.0,
      'emoji': '🧥',
      'category': 'Men',
      'image': 'assets/images/Classic blazer.jpg',
    },
    {
      'name': 'Slim Chinos',
      'price': r'$55',
      'priceVal': 55.0,
      'emoji': '👖',
      'category': 'Men',
      'image': 'assets/images/Slim Chinos.jpg',
    },
    {
      'name': 'Oxford Shirt',
      'price': r'$48',
      'priceVal': 48.0,
      'emoji': '👔',
      'category': 'Men',
      'image': 'assets/images/Oxford Shirt.jpg',
    },
    {
      'name': 'Floral Dress',
      'price': r'$65',
      'priceVal': 65.0,
      'emoji': '👗',
      'category': 'Women',
      'image': 'assets/images/Floral Dress.jpg',
    },
    {
      'name': 'Silk Blouse',
      'price': r'$72',
      'priceVal': 72.0,
      'emoji': '👚',
      'category': 'Women',
      'image': 'assets/images/Silk Blouse.jpg',
    },
    {
      'name': 'Maxi Skirt',
      'price': r'$58',
      'priceVal': 58.0,
      'emoji': '🩱',
      'category': 'Women',
      'image': 'assets/images/Maxi Skirt.jpg',
    },
    {
      'name': 'Kids Hoodie',
      'price': r'$35',
      'priceVal': 35.0,
      'emoji': '🧒',
      'category': 'Kids',
      'image': "assets/images/Kid's Hoodie.jpg",
    },
    {
      'name': 'Kids Jeans',
      'price': r'$30',
      'priceVal': 30.0,
      'emoji': '👦',
      'category': 'Kids',
      'image': 'assets/images/Denim Jeans & Jacket.jpg',
    },
    {
      'name': 'White Embossed Monogram Co-ord Set',
      'price': r'$22',
      'priceVal': 22.0,
      'emoji': '👕',
      'category': 'Sale',
      'image': 'assets/images/White Embossed Monogram Co-ord Set.jpg',
    },
    {
      'name': 'WOOD Oversized Tee & Shorts Set',
      'price': r'$40',
      'priceVal': 40.0,
      'emoji': '🩲',
      'category': 'Sale',
      'image': 'assets/images/WOOD Oversized Tee & Shorts Set.jpg',
    },
  ];

  List<Map<String, Object>> get _filtered {
    final list = List<Map<String, Object>>.from(
      _allProducts.where(
        (p) => widget.category == 'All' || p['category'] == widget.category,
      ),
    );
    if (_sort == 'Price: Low') {
      list.sort(
        (a, b) => (a['priceVal'] as double).compareTo(b['priceVal'] as double),
      );
    } else if (_sort == 'Price: High') {
      list.sort(
        (a, b) => (b['priceVal'] as double).compareTo(a['priceVal'] as double),
      );
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final products = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, state),
            Expanded(child: _buildGrid(context, state, products)),
            HomeScreen.buildBottomNav(context, 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AppState state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios, size: 18, color: navyBlue),
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
            items: [
              'Default',
              'Price: Low',
              'Price: High',
            ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
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
                if (state.cartCount > 0)
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
                          '${state.cartCount}',
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
    BuildContext context,
    AppState state,
    List<Map<String, Object>> products,
  ) {
    if (products.isEmpty) {
      return const Center(
        child: Text('No products found.', style: TextStyle(color: Colors.grey)),
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
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              // ✅ Replace with
              builder: (_) => ProductDetailsScreen(
                name: p['name'] as String,
                price: p['price'] as String,
                priceVal: p['priceVal'] as double,
                emoji: p['emoji'] as String,
                category: p['category'] as String,
                image: p['image'] as String?, // ← ADD THIS
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
                    child: p['image'] != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.asset(
                              p['image'] as String,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Text(
                              p['emoji'] as String,
                              style: const TextStyle(fontSize: 48),
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
                              p['name'] as String,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: navyBlue,
                              ),
                            ),
                            Text(
                              p['price'] as String,
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
                        onTap: () {
                          // ✅ Replace with
                          state.addToCart(
                            CartItem(
                              id: '${p['name']}_M_Navy',
                              name: p['name'] as String,
                              price: p['price'] as String,
                              emoji: p['emoji'] as String,
                              image: p['image'] as String?, // ← ADD
                              priceValue: p['priceVal'] as double,
                              size: 'M',
                              color: 'Navy',
                            ),
                          );
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
