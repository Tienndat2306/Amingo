import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/languages.dart';
import 'presentation/screens/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amingo - Login',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF775600),
          secondary: Color(0xFF5C5B5B),
          tertiary: Color(0xFFAF2046),
          surface: Color(0xFFFFB300),
          error: Color(0xFFB02500),
          onPrimary: Color(0xFFFFF1DC),
          onSecondary: Color(0xFFF5F2F1),
          onSurface: Color(0xFF1A1600),
          onError: Color(0xFFFFEFEC),
        ),
        useMaterial3: true,
        fontFamily: 'BeVietnamPro',
        scaffoldBackgroundColor: const Color(0xFFFFB300),
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}