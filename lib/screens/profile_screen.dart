import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../state/app_state.dart';
import '../state/app_state.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const navyBlue = Color(0xFF1B2F5E);
  static const gold = Color(0xFFC9A84C);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final appState = AppStateProvider.of(context);
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        // ── Stream profile + orders together ─────────────────────────────
        child: StreamBuilder<UserProfile?>(
          stream: uid.isNotEmpty
              ? firestoreService.getUserProfileStream(uid)
              : const Stream.empty(),
          builder: (context, profileSnap) {
            final user = profileSnap.data;

            return StreamBuilder<List<Order>>(
              stream: uid.isNotEmpty
                  ? firestoreService.getOrdersStream(uid)
                  : const Stream.empty(),
              builder: (context, ordersSnap) {
                final orders = ordersSnap.data ?? [];

                return StreamBuilder<List<CartItem>>(
                  stream: uid.isNotEmpty
                      ? firestoreService.getCartStream(uid)
                      : const Stream.empty(),
                  builder: (context, cartSnap) {
                    final cartCount = (cartSnap.data ?? []).fold<int>(
                      0,
                      (s, i) => s + i.quantity,
                    );
                    final totalSpent = orders.fold<double>(
                      0.0,
                      (s, o) => s + o.total,
                    );

                    return Column(
                      children: [
                        _topBar(context),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _avatarSection(context, user),
                                const SizedBox(height: 12),
                                _statsRow(orders.length, cartCount, totalSpent),
                                const SizedBox(height: 12),
                                _infoSection(user),
                                const SizedBox(height: 12),
                                _menuSection(
                                  context,
                                  appState,
                                  user,
                                  orders.length,
                                ),
                                const SizedBox(height: 12),
                                _logoutSection(context, appState),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                        HomeScreen.buildBottomNav(context, 3),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
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
          const Expanded(
            child: Text(
              'My Profile',
              style: TextStyle(
                color: navyBlue,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.edit_outlined, size: 14, color: navyBlue),
                  SizedBox(width: 4),
                  Text(
                    'Edit',
                    style: TextStyle(
                      color: navyBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarSection(BuildContext context, UserProfile? user) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: navyBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: gold, width: 2.5),
                ),
                child: Center(
                  child: Text(
                    user != null && user.name.isNotEmpty
                        ? user.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  ),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: gold,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            user?.name.isNotEmpty == true ? user!.name : 'Your Name',
            style: const TextStyle(
              color: navyBlue,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
          ),
          if (user?.phone.isNotEmpty == true) ...[
            const SizedBox(height: 2),
            Text(
              user!.phone,
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  // ── Stats now passed in from Firestore streams ──────────────────────────
  Widget _statsRow(int orderCount, int cartCount, double totalSpent) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          _stat('$orderCount', 'Orders'),
          _vDivider(),
          _stat('$cartCount', 'In Cart'),
          _vDivider(),
          _stat(
            totalSpent > 0 ? '\$${totalSpent.toStringAsFixed(0)}' : '\$0',
            'Spent',
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: navyBlue,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _vDivider() =>
      Container(width: 1, height: 36, color: const Color(0xFFE5E7EB));

  Widget _infoSection(UserProfile? user) {
    if (user == null) return const SizedBox.shrink();
    final fields = <String, String>{
      if (user.phone.isNotEmpty) 'Phone': user.phone,
      if (user.gender.isNotEmpty) 'Gender': user.gender,
      if (user.dob.isNotEmpty) 'Date of Birth': user.dob,
      if (user.address.isNotEmpty) 'Address': user.address,
      if (user.city.isNotEmpty) 'City': user.city,
      if (user.pincode.isNotEmpty) 'Pincode': user.pincode,
    };
    if (fields.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFED7AA)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFFF97316), size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Complete your profile to get a better experience.',
                style: TextStyle(color: Color(0xFFF97316), fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Text(
              'Personal Information',
              style: TextStyle(
                color: navyBlue,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...fields.entries.map((e) => _infoRow(e.key, e.value)),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: navyBlue,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuSection(
    BuildContext context,
    AppState appState,
    UserProfile? user,
    int orderCount,
  ) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _menuItem(
            Icons.shopping_bag_outlined,
            'My Orders',
            '$orderCount order(s)',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrdersScreen()),
            ),
          ),
          _menuItem(
            Icons.location_on_outlined,
            'Saved Address',
            user?.address.isNotEmpty == true ? user!.city : 'Not set',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
          ),
          _menuItem(
            Icons.lock_outline,
            'Change Password',
            '',
            () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password change coming soon.')),
            ),
          ),
          _menuItem(
            Icons.help_outline,
            'Help & Support',
            'help@luxewear.com',
            () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Email us at help@luxewear.com')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String label,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: navyBlue),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: navyBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  Widget _logoutSection(BuildContext context, AppState appState) {
    return Container(
      color: Colors.white,
      child: GestureDetector(
        onTap: () => showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final authService = AuthService();
                  await authService.signOut();
                  appState.logout();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (r) => false,
                  );
                },
                child: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: const Row(
            children: [
              Icon(Icons.logout, size: 20, color: Colors.red),
              SizedBox(width: 14),
              Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
