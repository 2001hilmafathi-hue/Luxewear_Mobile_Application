import 'package:flutter/material.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

// ✅ Replace with
class CartItem {
  final String id;
  final String name;
  final String price;
  final String emoji;
  final String? image; // ← ADD
  final double priceValue;
  final String size;
  final String color;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.emoji,
    this.image, // ← ADD
    required this.priceValue,
    required this.size,
    required this.color,
    this.quantity = 1,
  });
}

class OrderItem {
  final String name;
  final String price;
  final String emoji;
  final String? image;
  final int quantity;
  final String size;
  final String color;

  OrderItem({
    required this.name,
    required this.price,
    required this.emoji,
    this.image,
    required this.quantity,
    required this.size,
    required this.color,
  });
}

class Order {
  final String orderId;
  final DateTime placedAt;
  final List<OrderItem> items;
  final double total;
  final String address;
  String status; // Processing → Shipped → Delivered

  Order({
    required this.orderId,
    required this.placedAt,
    required this.items,
    required this.total,
    required this.address,
    this.status = 'Processing',
  });
}

class UserProfile {
  String name;
  String email;
  String phone;
  String gender;
  String dob; // dd/mm/yyyy
  String address;
  String city;
  String pincode;
  final String password; // kept for auth

  UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.dob,
    required this.address,
    required this.city,
    required this.pincode,
    required this.password,
  });

  UserProfile copyWith({
    String? name,
    String? phone,
    String? gender,
    String? dob,
    String? address,
    String? city,
    String? pincode,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      address: address ?? this.address,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      password: password,
    );
  }
}

// ─── AppState ─────────────────────────────────────────────────────────────────

class AppState extends ChangeNotifier {
  UserProfile? currentUser;
  final Map<String, UserProfile> _users = {}; // email → profile
  final List<CartItem> cartItems = [];
  final List<Order> orders = [];
  String? appliedCoupon;
  double couponDiscount = 0;

  bool get isLoggedIn => currentUser != null;

  int get cartCount => cartItems.fold(0, (s, i) => s + i.quantity);

  double get cartSubtotal =>
      cartItems.fold(0, (s, i) => s + i.priceValue * i.quantity);

  double get cartTotal =>
      (cartSubtotal - couponDiscount).clamp(0, double.infinity);

  // ── Auth ──────────────────────────────────────────────────────────────────

  String? login(String email, String password) {
    final key = email.trim().toLowerCase();
    final user = _users[key];
    if (user == null) return 'No account found with this email.';
    if (user.password != password) return 'Incorrect password.';
    currentUser = user;
    notifyListeners();
    return null;
  }

  String? register(String name, String email, String password) {
    final key = email.trim().toLowerCase();
    if (name.trim().isEmpty) return 'Please enter your full name.';
    if (!key.contains('@') || !key.contains('.')) return 'Enter a valid email.';
    if (password.length < 6) return 'Password must be at least 6 characters.';
    if (_users.containsKey(key))
      return 'An account with this email already exists.';
    final profile = UserProfile(
      name: name.trim(),
      email: key,
      phone: '',
      gender: '',
      dob: '',
      address: '',
      city: '',
      pincode: '',
      password: password,
    );
    _users[key] = profile;
    currentUser = profile;
    notifyListeners();
    return null;
  }

  void logout() {
    currentUser = null;
    cartItems.clear();
    appliedCoupon = null;
    couponDiscount = 0;
    notifyListeners();
  }

  // ── Profile edit ──────────────────────────────────────────────────────────

  void updateProfile(UserProfile updated) {
    _users[updated.email] = updated;
    currentUser = updated;
    notifyListeners();
  }

  // ── Cart ──────────────────────────────────────────────────────────────────

  void addToCart(CartItem item) {
    final existing = cartItems.where((c) => c.id == item.id).toList();
    if (existing.isNotEmpty) {
      existing.first.quantity += item.quantity;
    } else {
      cartItems.add(item);
    }
    notifyListeners();
  }

  void removeFromCart(String id) {
    cartItems.removeWhere((c) => c.id == id);
    _recalcCoupon();
    notifyListeners();
  }

  void updateQuantity(String id, int delta) {
    final idx = cartItems.indexWhere((c) => c.id == id);
    if (idx == -1) return;
    cartItems[idx].quantity += delta;
    if (cartItems[idx].quantity <= 0) cartItems.removeAt(idx);
    _recalcCoupon();
    notifyListeners();
  }

  void clearCart() {
    cartItems.clear();
    appliedCoupon = null;
    couponDiscount = 0;
    notifyListeners();
  }

  // ── Coupon ────────────────────────────────────────────────────────────────

  static const _coupons = {'LUXE10': 0.10, 'SAVE20': 0.20, 'FIRST15': 0.15};

  String? applyCoupon(String code) {
    final key = code.trim().toUpperCase();
    final rate = _coupons[key];
    if (rate == null) return 'Invalid coupon code.';
    appliedCoupon = key;
    couponDiscount = cartSubtotal * rate;
    notifyListeners();
    return null; // success
  }

  void removeCoupon() {
    appliedCoupon = null;
    couponDiscount = 0;
    notifyListeners();
  }

  void _recalcCoupon() {
    if (appliedCoupon != null) {
      final rate = _coupons[appliedCoupon!] ?? 0;
      couponDiscount = cartSubtotal * rate;
    }
  }

  // ── Orders ────────────────────────────────────────────────────────────────

  void placeOrder() {
    if (cartItems.isEmpty) return;
    final order = Order(
      orderId:
          'LW${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      placedAt: DateTime.now(),
      items: cartItems
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
      total: cartTotal,
      address: currentUser?.address.isNotEmpty == true
          ? '${currentUser!.address}, ${currentUser!.city}'
          : 'No address saved',
    );
    orders.insert(0, order);
    clearCart();
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

class AppStateProvider extends InheritedNotifier<AppState> {
  AppStateProvider({super.key, required super.child})
    : super(notifier: AppState());

  static AppState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppStateProvider>()!
        .notifier!;
  }
}
