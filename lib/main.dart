import 'package:flutter/material.dart';
import 'ui/splash_screen.dart';
import 'helpers/user_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserInfo.loadUserData();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manajemen Piket',
      theme: ThemeData(
        useMaterial3: true,
        // Konsep Earthy Modern: Ecru, Slate, and Sage
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC2B280), // Ecru Utama
          primary: const Color(0xFFC2B280),    // Ecru
          secondary: const Color(0xFF2C3E50),  // Deep Slate (Teks & Kontras)
          surface: const Color(0xFFFAF9F6),    // Bone/Warm White (Latar Belakang)
          onSurface: const Color(0xFF2C3E50),  // Teks Utama
          tertiary: const Color(0xFF829356),   // Sage Green (Aksen)
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF8B7E55), // Dark Ecru
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
