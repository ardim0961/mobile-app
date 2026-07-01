import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../helpers/user_info.dart';
import '../widgets/success_dialog.dart';
import '../widgets/warning_dialog.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isObscureNew = true;
  bool _isObscureCurrent = true;
  String? _currentPicPath;

  final Color darkEcru = const Color(0xFF8B7E55);
  final Color primaryEcru = const Color(0xFFC2B280);
  final Color lightEcru = const Color(0xFFFDFDF5);

  @override
  void initState() {
    super.initState();
    _namaController.text = UserInfo.getNama();
    _emailController.text = UserInfo.getEmail();
    _currentPicPath = UserInfo.getProfilePic();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await UserInfo.updateProfilePic(image.path);
      setState(() => _currentPicPath = image.path);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => SuccessDialog(
            description: "Foto profil berhasil diperbarui",
            okClick: () => Navigator.pop(context),
          ),
        );
      }
    }
  }

  void _removeImage() {
    if (_currentPicPath == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Foto Profil?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () async {
              await UserInfo.updateProfilePic(null);
              setState(() => _currentPicPath = null);
              Navigator.pop(context); // Tutup AlertDialog
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (context) => SuccessDialog(
                    description: "Foto profil berhasil dihapus",
                    okClick: () => Navigator.pop(context),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Ya, Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: lightEcru,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: isMobile ? 360 : 400,
            pinned: true,
            centerTitle: true,
            elevation: 0,
            backgroundColor: darkEcru,
            title: const Text('PROFIL SAYA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18, letterSpacing: 1.2)),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  ClipPath(
                    clipper: HeaderClipper(),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [darkEcru, primaryEcru]),
                      ),
                    ),
                  ),
                  Positioned(right: -20, top: 20, child: Icon(Icons.account_circle_outlined, size: 200, color: Colors.white.withOpacity(0.05))),
                  Positioned.fill(
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),
                          _buildAvatarStack(screenWidth),
                          
                          // Tombol Hapus Foto Transparan (Hanya teks dan ikon)
                          if (_currentPicPath != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: TextButton.icon(
                                onPressed: _removeImage,
                                icon: const Icon(Icons.delete_sweep_rounded, size: 18, color: Colors.redAccent),
                                label: const Text("Hapus Foto", 
                                  style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ),

                          const SizedBox(height: 12),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(UserInfo.getNama(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white24)),
                            child: Text(UserInfo.getEmail(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 850),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Card(
                  elevation: 4,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("Informasi Akun", Icons.badge_outlined),
                          const SizedBox(height: 24),
                          _buildTextField(_namaController, "Nama Lengkap", Icons.person_outline_rounded),
                          const SizedBox(height: 16),
                          _buildTextField(_emailController, "Email Instansi", Icons.alternate_email_rounded),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 32), child: Divider()),
                          _buildSectionTitle("Keamanan Akun", Icons.security_rounded),
                          const SizedBox(height: 24),
                          _buildTextField(_newPasswordController, "Password Baru (Opsional)", Icons.lock_outline_rounded, isObscure: _isObscureNew, onToggle: () => setState(() => _isObscureNew = !_isObscureNew)),
                          const SizedBox(height: 16),
                          _buildTextField(_passwordController, "Password Saat Ini *", Icons.lock_person_rounded, isObscure: _isObscureCurrent, onToggle: () => setState(() => _isObscureCurrent = !_isObscureCurrent)),
                          const SizedBox(height: 48),
                          _buildSaveButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(children: [Icon(icon, color: darkEcru, size: 20), const SizedBox(width: 8), Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkEcru))]);
  }

  Widget _buildAvatarStack(double screenWidth) {
    final double avatarRadius = (screenWidth * 0.12).clamp(45.0, 65.0);
    bool hasImage = _currentPicPath != null && _currentPicPath!.isNotEmpty;
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
          child: CircleAvatar(
            radius: avatarRadius,
            backgroundColor: Colors.white.withOpacity(0.9),
            backgroundImage: hasImage
                ? (kIsWeb || _currentPicPath!.startsWith('http')
                    ? NetworkImage(_currentPicPath!)
                    : FileImage(File(_currentPicPath!)) as ImageProvider)
                : null,
            child: !hasImage ? Text(UserInfo.getNama()[0].toUpperCase(), style: TextStyle(fontSize: avatarRadius * 0.7, color: darkEcru, fontWeight: FontWeight.bold)) : null,
          ),
        ),
        Positioned(
          bottom: 0, right: 0,
          child: Material(elevation: 4, shape: const CircleBorder(), child: CircleAvatar(backgroundColor: Colors.white, radius: 18, child: CircleAvatar(backgroundColor: const Color(0xFF2C3E50), radius: 16, child: IconButton(padding: EdgeInsets.zero, icon: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white), onPressed: _pickImage)))),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isObscure = false, VoidCallback? onToggle}) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        prefixIcon: Icon(icon, color: primaryEcru, size: 20),
        suffixIcon: onToggle != null ? IconButton(icon: Icon(isObscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: primaryEcru, size: 18), onPressed: onToggle) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C3E50), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 4),
        onPressed: _isLoading ? null : () async {
          if (_formKey.currentState!.validate()) {
            if (_passwordController.text == UserInfo.getPassword()) {
               setState(() => _isLoading = true);
               await UserInfo.updateNama(_namaController.text);
               await UserInfo.updateEmail(_emailController.text);
               if (_newPasswordController.text.isNotEmpty) {
                 await UserInfo.updatePassword(_newPasswordController.text);
               }
               setState(() => _isLoading = false);
               if (mounted) {
                 showDialog(
                  context: context, 
                  builder: (c) => SuccessDialog(
                    description: "Profil berhasil diperbarui", 
                    okClick: () {
                      Navigator.pop(context);
                      setState(() {});
                    }
                  )
                 );
               }
            } else {
               showDialog(context: context, builder: (c) => const WarningDialog(description: "Password saat ini salah"));
            }
          }
        },
        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Simpan Perubahan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
