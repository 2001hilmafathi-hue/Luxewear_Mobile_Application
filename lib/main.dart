import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'state/app_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      child: MaterialApp(
        title: 'LuxeWear',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
  scaffoldBackgroundColor: Colors.white,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      overlayColor: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.hovered)) {
            return const Color(0xFF1B2F5E).withOpacity(0.8);
          }
          return null;
        },
      ),
    ),
  ),
),
        home: const LoginScreen(),
      ),
    );
  }
}
