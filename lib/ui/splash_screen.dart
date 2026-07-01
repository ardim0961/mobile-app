import 'package:flutter/material.dart';
import '../helpers/user_info.dart';
import 'login_page.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  _startLoading() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    bool isLogin = await UserInfo.getLoginStatus();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => isLogin ? const MainScreen() : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color darkEcru = Color(0xFF8B7E55);
    const Color primaryEcru = Color(0xFFC2B280);
    const Color lightEcru = Color(0xFFFDFDF5);

    return Scaffold(
      backgroundColor: lightEcru, 
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [lightEcru, primaryEcru.withOpacity(0.1)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: darkEcru.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10))
                ],
              ),
              child: const Icon(
                Icons.assignment_ind_rounded,
                size: 80,
                color: darkEcru,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'MANAJEMEN PIKET',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkEcru,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sistem Jadwal Petugas Profesional',
              style: TextStyle(
                fontSize: 14,
                color: darkEcru.withOpacity(0.7),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 64),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(darkEcru),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
