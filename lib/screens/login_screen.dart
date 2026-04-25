import 'package:flutter/material.dart';
import '../state/app_state.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  bool obscurePassword = true;
  bool obscureConfirm = true;
  String? errorMessage;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  static const navyBlue = Color(0xFF1B2F5E);
  static const gold = Color(0xFFC9A84C);

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    final state = AppStateProvider.of(context);
    setState(() => errorMessage = null);

    if (isLogin) {
      final err = state.login(emailController.text, passwordController.text);
      if (err != null) {
        setState(() => errorMessage = err);
      } else {
        _goHome();
      }
    } else {
      if (passwordController.text != confirmController.text) {
        setState(() => errorMessage = 'Passwords do not match.');
        return;
      }
      final err = state.register(
        nameController.text,
        emailController.text,
        passwordController.text,
      );
      if (err != null) {
        setState(() => errorMessage = err);
      } else {
        _goHome();
      }
    }
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top navy header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(32, 64, 32, 36),
              color: navyBlue,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: gold,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Text('L',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('LuxeWear',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Dress to impress, every day',
                      style:
                          TextStyle(color: Color(0xFFa8b8d8), fontSize: 13)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tab switcher
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFf3f4f6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        _tabButton('Login', isLogin,
                            () => setState(() {
                                  isLogin = true;
                                  errorMessage = null;
                                })),
                        _tabButton('Register', !isLogin,
                            () => setState(() {
                                  isLogin = false;
                                  errorMessage = null;
                                })),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (!isLogin) ...[
                    _label('Full Name'),
                    _inputField('John Doe', nameController, false),
                    const SizedBox(height: 16),
                  ],

                  _label('Email address'),
                  _inputField('you@example.com', emailController, false,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),

                  _label('Password'),
                  _passwordField(obscurePassword, passwordController, () {
                    setState(() => obscurePassword = !obscurePassword);
                  }),
                  const SizedBox(height: 16),

                  if (!isLogin) ...[
                    _label('Confirm Password'),
                    _passwordField(obscureConfirm, confirmController, () {
                      setState(() => obscureConfirm = !obscureConfirm);
                    }),
                    const SizedBox(height: 16),
                  ],

                  if (isLogin) ...[
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Password reset not available in demo.')),
                          );
                        },
                        child: const Text('Forgot password?',
                            style:
                                TextStyle(color: navyBlue, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Error message
                  if (errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(errorMessage!,
                          style: const TextStyle(
                              color: Color(0xFFDC2626), fontSize: 13)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Main button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: navyBlue,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        isLogin ? 'Sign In' : 'Create Account',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or continue with',
                          style: TextStyle(
                              color: Colors.grey[400], fontSize: 12)),
                    ),
                    const Expanded(child: Divider()),
                  ]),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Google sign-in not available in demo.')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Continue with Google',
                          style: TextStyle(
                              color: Color(0xFF374151), fontSize: 14)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        isLogin = !isLogin;
                        errorMessage = null;
                      }),
                      child: RichText(
                        text: TextSpan(
                          text: isLogin
                              ? "Don't have an account? "
                              : "Already have an account? ",
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                          children: [
                            TextSpan(
                              text: isLogin ? 'Register' : 'Login',
                              style: const TextStyle(
                                  color: navyBlue,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
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

  Widget _tabButton(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? navyBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                  color: active ? Colors.white : Colors.grey,
                  fontSize: 14,
                  fontWeight:
                      active ? FontWeight.w500 : FontWeight.normal,
                )),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      );

  Widget _inputField(
    String hint,
    TextEditingController controller,
    bool obscure, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFfafafa),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFd1d5db)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFd1d5db)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _passwordField(
      bool obscure, TextEditingController controller, VoidCallback toggle) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFfafafa),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFd1d5db)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFd1d5db)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        suffixIcon: GestureDetector(
          onTap: toggle,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(obscure ? 'Show' : 'Hide',
                style: const TextStyle(
                    color: Color(0xFF1B2F5E), fontSize: 12)),
          ),
        ),
      ),
    );
  }
}
