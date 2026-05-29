import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


// ─── Models ───────────────────────────────────────────────────────────────────

// ✅ Replace with
class CartItem {
  final String id;
  final String name;
  final String price;
  final String emoji;
  final String? image;
  final double priceValue;
  final String size;
  final String color;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.emoji,
    this.image,
    required this.priceValue,
    required this.size,
    required this.color,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'emoji': emoji,
      'image': image,
      'priceValue': priceValue,
      'size': size,
      'color': color,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map, String docId) {
    return CartItem(
      id: docId,
      name: map['name'] as String,
      price: map['price'] as String,
      emoji: map['emoji'] as String,
      image: map['image'] as String?,
      priceValue: (map['priceValue'] as num).toDouble(),
      size: map['size'] as String,
      color: map['color'] as String,
      quantity: map['quantity'] as int? ?? 1,
    );
  }
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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'emoji': emoji,
      'image': image,
      'quantity': quantity,
      'size': size,
      'color': color,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      name: map['name'] as String,
      price: map['price'] as String,
      emoji: map['emoji'] as String,
      image: map['image'] as String?,
      quantity: map['quantity'] as int,
      size: map['size'] as String,
      color: map['color'] as String,
    );
  }
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

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'placedAt': Timestamp.fromDate(placedAt),
      'items': items.map((i) => i.toMap()).toList(),
      'total': total,
      'address': address,
      'status': status,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map, String docId) {
    return Order(
      orderId: map['orderId'] as String? ?? docId,
      placedAt: (map['placedAt'] as Timestamp).toDate(),
      items: (map['items'] as List)
          .map((i) => OrderItem.fromMap(i as Map<String, dynamic>))
          .toList(),
      total: (map['total'] as num).toDouble(),
      address: map['address'] as String,
      status: map['status'] as String? ?? 'Processing',
    );
  }
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
  final String password; // kept for backward compat, not stored in Firestore

  UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.dob,
    required this.address,
    required this.city,
    required this.pincode,
    this.password = '',
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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'dob': dob,
      'address': address,
      'city': city,
      'pincode': pincode,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      gender: map['gender'] as String? ?? '',
      dob: map['dob'] as String? ?? '',
      address: map['address'] as String? ?? '',
      city: map['city'] as String? ?? '',
      pincode: map['pincode'] as String? ?? '',
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
    if (_users.containsKey(key)) {
      return 'An account with this email already exists.';
    }
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
