import 'package:flutter/material.dart';
import '../helpers/user_info.dart';
import 'main_screen.dart';
import 'registrasi_page.dart';
import '../widgets/warning_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  final Color primaryEcru = const Color(0xFFC2B280);
  final Color darkEcru = const Color(0xFF8B7E55);
  final Color lightEcru = const Color(0xFFFDFDF5);

  void _login() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      Future.delayed(const Duration(seconds: 1), () async {
        if (mounted) {
          setState(() => _isLoading = false);
          if (UserInfo.login(_emailController.text, _passwordController.text)) {
            await UserInfo.setLoginStatus(true);
            if (mounted) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text('Login Berhasil!'), backgroundColor: darkEcru),
              );
            }
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) => const WarningDialog(description: "Login gagal, cek email & password"),
            );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightEcru,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [darkEcru, primaryEcru],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                ),
                _buildDecorationSquare(-20, 40, 150, 0.15, 30),
                _buildDecorationSquare(50, -30, 180, 0.1, 40),
                _buildDecorationSquare(null, 100, 80, 0.05, 20, bottom: 20),
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_person_rounded, size: 80, color: Colors.white),
                      const SizedBox(height: 10),
                      const Text(
                        'MANAJEMEN PIKET', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)
                      ),
                      const SizedBox(height: 4),
                      Text('Silakan login untuk mengelola jadwal', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Card(
                      elevation: 8,
                      shadowColor: Colors.black12,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _emailTextField(),
                              const SizedBox(height: 20),
                              _passwordTextField(),
                              const SizedBox(height: 30),
                              _buttonLogin(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _menuRegistrasi(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorationSquare(double? top, double right, double size, double opacity, double radius, {double? bottom}) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(radius)),
        ),
      ),
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email',
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(Icons.email_outlined, color: darkEcru),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: darkEcru, width: 2)),
      ),
      validator: (value) => (value == null || value.isEmpty) ? 'Email harus diisi' : null,
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(Icons.lock_outline, color: darkEcru),
        suffixIcon: IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: darkEcru),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: darkEcru, width: 2)),
      ),
      validator: (value) => (value == null || value.isEmpty) ? 'Password harus diisi' : null,
    );
  }

  Widget _buttonLogin() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C3E50), // Deep Slate untuk kontras yang elegan
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
        child: _isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('MASUK SEKARANG', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
      ),
    );
  }

  Widget _menuRegistrasi() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Belum punya akun?"),
        TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistrasiPage())),
          child: Text('Daftar di sini', style: TextStyle(color: darkEcru, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
