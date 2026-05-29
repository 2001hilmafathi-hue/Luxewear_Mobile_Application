import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import '../data/app_data.dart';
import '../state/app_state.dart';

/// Central Firestore service with all CRUD operations for products,
/// cart, orders, and user profile.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Convenience getter ──────────────────────────────────────────────────
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // ── Products ────────────────────────────────────────────────────────────

  /// Streams all products from the `products` collection.
  Stream<List<ProductModel>> getProductsStream() {
    return _db.collection('products').snapshots().map(
          (snap) => snap.docs
              .map((doc) => ProductModel.fromMap(doc.data()))
              .toList(),
        );
  }

  /// Streams only featured products (`isFeatured == true`).
  Stream<List<ProductModel>> getFeaturedProductsStream() {
    return _db
        .collection('products')
        .where('isFeatured', isEqualTo: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => ProductModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // ── Cart ─────────────────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> _cartRef(String uid) =>
      _db.collection('users').doc(uid).collection('cart');

  /// Real-time stream of the user's cart items.
  Stream<List<CartItem>> getCartStream(String uid) {
    return _cartRef(uid).snapshots().map(
          (snap) => snap.docs
              .map((doc) => CartItem.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Adds an item to the cart. If an item with the same logical ID already
  /// exists, its quantity is incremented.
  Future<void> addToCart(String uid, CartItem item) async {
    final ref = _cartRef(uid);
    // Check for existing item with same product+size+color combo
    final existing = await ref.where('id', isEqualTo: item.id).get();
    if (existing.docs.isNotEmpty) {
      // Increment quantity
      final doc = existing.docs.first;
      final currentQty = doc.data()['quantity'] as int? ?? 0;
      await doc.reference.update({'quantity': currentQty + item.quantity});
    } else {
      await ref.add(item.toMap());
    }
  }

  /// Updates the quantity of a cart item. Deletes the doc if qty ≤ 0.
  Future<void> updateCartQuantity(
      String uid, String docId, int newQuantity) async {
    final docRef = _cartRef(uid).doc(docId);
    if (newQuantity <= 0) {
      await docRef.delete();
    } else {
      await docRef.update({'quantity': newQuantity});
    }
  }

  /// Removes a single cart item.
  Future<void> removeFromCart(String uid, String docId) async {
    await _cartRef(uid).doc(docId).delete();
  }

  /// Deletes all items from the user's cart.
  Future<void> clearCart(String uid) async {
    final snap = await _cartRef(uid).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ── Orders ──────────────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> _ordersRef(String uid) =>
      _db.collection('users').doc(uid).collection('orders');

  /// Streams the user's orders, newest first.
  Stream<List<Order>> getOrdersStream(String uid) {
    return _ordersRef(uid)
        .orderBy('placedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => Order.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Places an order: writes the order doc and clears the cart.
  Future<void> placeOrder(String uid, Order order) async {
    await _ordersRef(uid).add(order.toMap());
    await clearCart(uid);
  }

  // ── Profile ─────────────────────────────────────────────────────────────

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  /// Streams the user profile document.
  Stream<UserProfile?> getUserProfileStream(String uid) {
    return _userDoc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserProfile.fromMap(snap.data()!);
    });
  }

  /// Updates (or creates) the user profile document.
  Future<void> updateUserProfile(String uid, UserProfile profile) async {
    await _userDoc(uid).set(profile.toMap(), SetOptions(merge: true));
  }

  /// Creates an initial profile document after registration.
  Future<void> createUserProfile(
      String uid, String name, String email) async {
    await _userDoc(uid).set({
      'name': name,
      'email': email,
      'phone': '',
      'gender': '',
      'dob': '',
      'address': '',
      'city': '',
      'pincode': '',
    });
  }
}
