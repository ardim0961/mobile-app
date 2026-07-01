import 'package:flutter/material.dart';
import '../helpers/user_info.dart';
import '../widgets/success_dialog.dart';

class RegistrasiPage extends StatefulWidget {
  const RegistrasiPage({super.key});

  @override
  State<RegistrasiPage> createState() => _RegistrasiPageState();
}

class _RegistrasiPageState extends State<RegistrasiPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isKonfirmasiPasswordVisible = false;

  // Consistent Theme Colors
  final Color primaryEcru = const Color(0xFFC2B280);
  final Color darkEcru = const Color(0xFF8B7E55);
  final Color lightEcru = const Color(0xFFFDFDF5); // Diselaraskan
  final Color deepSlate = const Color(0xFF2C3E50); // Penyeimbang elegan

  void _submit() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(const Duration(seconds: 2), () async {
        await UserInfo.setUser(
          _namaController.text,
          _emailController.text,
          _passwordController.text,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => SuccessDialog(
              description: "Registrasi berhasil, silakan login",
              okClick: () {
                Navigator.pop(context); // Tutup dialog
                Navigator.pop(context); // Kembali ke Login
              },
            ),
          );
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
            // Header Profesional Identik dengan Login
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
                
                // Back Button
                Positioned(
                  top: 40,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_add_alt_1_rounded, size: 80, color: Colors.white),
                      const SizedBox(height: 10),
                      const Text(
                        'BUAT AKUN BARU',
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Daftar untuk mulai mengelola jadwal',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                      ),
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
                              _textField(controller: _namaController, label: "Nama Lengkap", icon: Icons.person_outline),
                              const SizedBox(height: 16),
                              _emailField(),
                              const SizedBox(height: 16),
                              _passwordField(),
                              const SizedBox(height: 16),
                              _confirmPasswordField(),
                              const SizedBox(height: 32),
                              _buttonRegistrasi(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Sudah punya akun? Masuk di sini', 
                        style: TextStyle(color: darkEcru, fontWeight: FontWeight.bold),
                      ),
                    ),
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

  Widget _textField({required TextEditingController controller, required String label, required IconData icon}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: darkEcru),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: darkEcru, width: 2)),
      ),
      validator: (v) => (v == null || v.length < 3) ? 'Minimal 3 karakter' : null,
    );
  }

  Widget _emailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: "Email Instansi",
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(Icons.email_outlined, color: darkEcru),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: darkEcru, width: 2)),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Email wajib diisi';
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Email tidak valid';
        return null;
      },
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: "Password",
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(Icons.lock_outline, color: darkEcru),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: darkEcru, width: 2)),
        suffixIcon: IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: darkEcru),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
      ),
      validator: (v) => (v == null || v.length < 6) ? 'Password minimal 6 karakter' : null,
    );
  }

  Widget _confirmPasswordField() {
    return TextFormField(
      controller: _konfirmasiPasswordController,
      obscureText: !_isKonfirmasiPasswordVisible,
      decoration: InputDecoration(
        labelText: "Konfirmasi Password",
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(Icons.lock_reset_rounded, color: darkEcru),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: darkEcru, width: 2)),
        suffixIcon: IconButton(
          icon: Icon(_isKonfirmasiPasswordVisible ? Icons.visibility : Icons.visibility_off, color: darkEcru),
          onPressed: () => setState(() => _isKonfirmasiPasswordVisible = !_isKonfirmasiPasswordVisible),
        ),
      ),
      validator: (v) => (v != _passwordController.text) ? 'Password tidak cocok' : null,
    );
  }

  Widget _buttonRegistrasi() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: deepSlate,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
        onPressed: _isLoading ? null : _submit,
        child: _isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text("DAFTAR SEKARANG", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.0)),
      ),
    );
  }
}
