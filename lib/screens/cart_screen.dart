import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../state/app_state.dart';
import '../services/firestore_service.dart';
import 'home_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const navyBlue = Color(0xFF1B2F5E);
  static const gold = Color(0xFFC9A84C);

  final _couponController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  String? _couponError;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final appState = AppStateProvider.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: StreamBuilder<List<CartItem>>(
          stream: uid.isNotEmpty
              ? _firestoreService.getCartStream(uid)
              : const Stream.empty(),
          builder: (context, snapshot) {
            final items = snapshot.data ?? [];
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;

            if (isLoading && items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // ── Compute totals locally from Firestore items ───────────────
            final subtotal = items.fold<double>(
              0,
              (s, i) => s + i.priceValue * i.quantity,
            );
            final double discount = appState.appliedCoupon != null
                ? subtotal * (_couponRates[appState.appliedCoupon] ?? 0)
                : 0.0;
            final double total = (subtotal - discount)
                .clamp(0.0, double.infinity)
                .toDouble();
            final cartCount = items.fold<int>(0, (s, i) => s + i.quantity);

            return Column(
              children: [
                _buildTopBar(context, uid, items, cartCount),
                Expanded(
                  child: items.isEmpty
                      ? _buildEmpty(context)
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            ...items.map(
                              (item) => _buildCartItem(context, uid, item),
                            ),
                            const SizedBox(height: 8),
                            _buildCouponBox(context, appState, subtotal),
                            const SizedBox(height: 8),
                            _buildSummary(appState, subtotal, discount, total),
                          ],
                        ),
                ),
                if (items.isNotEmpty)
                  _buildCheckoutButton(
                    context,
                    uid,
                    appState,
                    items,
                    cartCount,
                    total,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Coupon rates (kept local — no Firestore needed) ────────────────────
  static const _couponRates = {'LUXE10': 0.10, 'SAVE20': 0.20, 'FIRST15': 0.15};

  Widget _buildTopBar(
    BuildContext context,
    String uid,
    List<CartItem> items,
    int cartCount,
  ) {
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
              'My Cart${items.isNotEmpty ? ' ($cartCount)' : ''}',
              style: const TextStyle(
                color: navyBlue,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (items.isNotEmpty)
            GestureDetector(
              onTap: () => _confirmClear(context, uid),
              child: const Text(
                'Clear all',
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, String uid) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _firestoreService.clearCart(uid);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🛒', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              color: navyBlue,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add some items to get started',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (r) => false,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: navyBlue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Continue Shopping',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, String uid, CartItem item) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red, size: 24),
      ),
      onDismissed: (_) => _firestoreService.removeFromCart(uid, item.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: item.image != null
                    ? Image.asset(
                        item.image!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.contain,
                      )
                    : Center(
                        child: Text(
                          item.emoji,
                          style: const TextStyle(fontSize: 34),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: navyBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _chip('Size: ${item.size}'),
                      const SizedBox(width: 6),
                      _chip('Color: ${item.color}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${(item.priceValue * item.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: gold,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      // ── Qty stepper → Firestore ─────────────────
                      Row(
                        children: [
                          _qtyBtn(Icons.remove, () async {
                            await _firestoreService.updateCartQuantity(
                              uid,
                              item.id,
                              item.quantity - 1,
                            );
                          }),
                          Container(
                            width: 32,
                            alignment: Alignment.center,
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                color: navyBlue,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          _qtyBtn(Icons.add, () async {
                            await _firestoreService.updateCartQuantity(
                              uid,
                              item.id,
                              item.quantity + 1,
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(color: navyBlue, fontSize: 10)),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD1D5DB)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: navyBlue),
      ),
    );
  }

  Widget _buildCouponBox(
    BuildContext context,
    AppState appState,
    double subtotal,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Coupon Code',
            style: TextStyle(
              color: navyBlue,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          if (appState.appliedCoupon != null)
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${appState.appliedCoupon} applied — \$${(subtotal * (_couponRates[appState.appliedCoupon] ?? 0)).toStringAsFixed(2)} off',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    appState.removeCoupon();
                    _couponController.clear();
                    setState(() => _couponError = null);
                  },
                  child: const Icon(Icons.close, size: 16, color: Colors.grey),
                ),
              ],
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Enter coupon (e.g. LUXE10)',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFAFAFA),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    final err = appState.applyCoupon(_couponController.text);
                    setState(() => _couponError = err);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navyBlue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
            if (_couponError != null) ...[
              const SizedBox(height: 6),
              Text(
                _couponError!,
                style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12),
              ),
            ],
            const SizedBox(height: 6),
            const Text(
              'Try: LUXE10 · SAVE20 · FIRST15',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummary(
    AppState appState,
    double subtotal,
    double discount,
    double total,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}', false),
          const SizedBox(height: 8),
          _summaryRow(
            'Shipping',
            'Free',
            false,
            valueColor: const Color(0xFF10B981),
          ),
          if (appState.appliedCoupon != null) ...[
            const SizedBox(height: 8),
            _summaryRow(
              'Discount (${appState.appliedCoupon})',
              '- \$${discount.toStringAsFixed(2)}',
              false,
              valueColor: const Color(0xFF10B981),
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          _summaryRow('Total', '\$${total.toStringAsFixed(2)}', true),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value,
    bool bold, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: bold ? navyBlue : const Color(0xFF6B7280),
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? navyBlue,
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton(
    BuildContext context,
    String uid,
    AppState appState,
    List<CartItem> items,
    int cartCount,
    double total,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _showCheckoutSheet(
            context,
            uid,
            appState,
            items,
            cartCount,
            total,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: navyBlue,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Checkout  •  \$${total.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _showCheckoutSheet(
    BuildContext context,
    String uid,
    AppState appState,
    List<CartItem> items,
    int cartCount,
    double total,
  ) {
    final user = appState.currentUser;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                color: navyBlue,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: navyBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Delivery to',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          user?.address.isNotEmpty == true
                              ? '${user!.address}, ${user.city}'
                              : 'No address saved — add in Profile',
                          style: TextStyle(
                            color: user?.address.isNotEmpty == true
                                ? navyBlue
                                : Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$cartCount item(s)  •  Total: \$${total.toStringAsFixed(2)}',
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Build order from current Firestore cart items
                  final address = user?.address.isNotEmpty == true
                      ? '${user!.address}, ${user.city}'
                      : 'No address saved';
                  final order = Order(
                    orderId:
                        'LW${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                    placedAt: DateTime.now(),
                    items: items
                        .map(
                          (c) => OrderItem(
                            name: c.name,
                            price: c.price,
                            emoji: c.emoji,
                            image: c.image,
                            quantity: c.quantity,
                            size: c.size,
                            color: c.color,
                          ),
                        )
                        .toList(),
                    total: total,
                    address: address,
                  );
                  await _firestoreService.placeOrder(uid, order);
                  appState.removeCoupon();
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _showOrderSuccess(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: navyBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Place Order',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderSuccess(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text(
              'Order Placed!',
              style: TextStyle(
                color: navyBlue,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your order has been placed successfully. You can track it in My Orders.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (r) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: navyBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Continue Shopping',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
