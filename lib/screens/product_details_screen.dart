import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../state/app_state.dart';
import '../services/firestore_service.dart';
import 'cart_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String name;
  final String price;
  final double priceVal;
  final String emoji;
  final String category;
  final String? image;

  const ProductDetailsScreen({
    super.key,
    required this.name,
    required this.price,
    required this.priceVal,
    required this.emoji,
    required this.category,
    this.image,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  static const navyBlue = Color(0xFF1B2F5E);
  static const gold = Color(0xFFC9A84C);

  String _selectedSize = 'M';
  String _selectedColor = 'Navy';
  int _quantity = 1;

  final _sizes = ['XS', 'S', 'M', 'L', 'XL'];
  final _colors = ['Navy', 'Black', 'White', 'Beige'];

  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar: cart badge from Firestore ────────────────────────
            StreamBuilder<List<CartItem>>(
              stream: uid.isNotEmpty
                  ? _firestoreService.getCartStream(uid)
                  : const Stream.empty(),
              builder: (context, snapshot) {
                final cartCount = (snapshot.data ?? []).fold<int>(
                  0,
                  (s, i) => s + i.quantity,
                );
                return _buildTopBar(context, cartCount);
              },
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product image area
                    Container(
                      width: double.infinity,
                      height: 260,
                      color: const Color(0xFFF3F4F6),
                      child: widget.image != null
                          ? Image.asset(
                              widget.image!,
                              width: double.infinity,
                              height: 260,
                              fit: BoxFit.contain,
                            )
                          : Center(
                              child: Text(
                                widget.emoji,
                                style: const TextStyle(fontSize: 100),
                              ),
                            ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.category,
                              style: const TextStyle(
                                color: navyBlue,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.name,
                                  style: const TextStyle(
                                    color: navyBlue,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                widget.price,
                                style: const TextStyle(
                                  color: gold,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Rating
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                (i) => const Icon(
                                  Icons.star,
                                  color: gold,
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                '4.8 (124 reviews)',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'A premium quality piece crafted with attention to detail. '
                            'Perfect for any occasion, this versatile item combines '
                            'style and comfort effortlessly.',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Size selector
                          const Text(
                            'Size',
                            style: TextStyle(
                              color: navyBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: _sizes.map((s) {
                              final selected = s == _selectedSize;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedSize = s),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: selected ? navyBlue : Colors.white,
                                    border: Border.all(
                                      color: selected
                                          ? navyBlue
                                          : const Color(0xFFD1D5DB),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      s,
                                      style: TextStyle(
                                        color: selected
                                            ? Colors.white
                                            : navyBlue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),

                          // Color selector
                          const Text(
                            'Color',
                            style: TextStyle(
                              color: navyBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            children: _colors.map((c) {
                              final selected = c == _selectedColor;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedColor = c),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected ? navyBlue : Colors.white,
                                    border: Border.all(
                                      color: selected
                                          ? navyBlue
                                          : const Color(0xFFD1D5DB),
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    c,
                                    style: TextStyle(
                                      color: selected ? Colors.white : navyBlue,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),

                          // Quantity
                          Row(
                            children: [
                              const Text(
                                'Quantity',
                                style: TextStyle(
                                  color: navyBlue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              _qtyButton(Icons.remove, () {
                                if (_quantity > 1) {
                                  setState(() => _quantity--);
                                }
                              }),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  '$_quantity',
                                  style: const TextStyle(
                                    color: navyBlue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              _qtyButton(Icons.add, () {
                                setState(() => _quantity++);
                              }),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom: Add to Cart → Firestore ───────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '\$${(widget.priceVal * _quantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: navyBlue,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (uid.isEmpty) return;
                        final item = CartItem(
                          id: '${widget.name}_${_selectedSize}_$_selectedColor',
                          name: widget.name,
                          price: widget.price,
                          emoji: widget.emoji,
                          image: widget.image,
                          priceValue: widget.priceVal,
                          size: _selectedSize,
                          color: _selectedColor,
                          quantity: _quantity,
                        );
                        await _firestoreService.addToCart(uid, item);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${widget.name} x$_quantity added to cart',
                            ),
                            duration: const Duration(seconds: 1),
                            action: SnackBarAction(
                              label: 'View Cart',
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CartScreen(),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: navyBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
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
  }

  Widget _buildTopBar(BuildContext context, int cartCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                size: 16,
                color: navyBlue,
              ),
            ),
          ),
          const Text(
            'Product Details',
            style: TextStyle(
              color: navyBlue,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
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

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD1D5DB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: navyBlue),
      ),
    );
  }
}
