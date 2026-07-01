import 'package:flutter/material.dart';
import '../models/jadwal_piket.dart';
import '../helpers/user_info.dart';
import 'login_page.dart';
import 'data_form.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  final List<JadwalPiket> dataPiket;
  final VoidCallback onRefresh;
  final Function(int) onNavigateToTab;

  const HomePage({
    super.key,
    required this.dataPiket,
    required this.onRefresh,
    required this.onNavigateToTab,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color primaryEcru = const Color(0xFFC2B280);
  final Color darkEcru = const Color(0xFF8B7E55);
  final Color deepEcru = const Color(0xFF6B5E40);
  final Color lightEcru = const Color(0xFFFDFDF5);

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Datang,';
    if (hour < 17) return 'Selamat Siang,';
    return 'Selamat Sore,';
  }

  String _getHariIni() {
    final days = {
      DateTime.monday: 'Senin', DateTime.tuesday: 'Selasa', DateTime.wednesday: 'Rabu',
      DateTime.thursday: 'Kamis', DateTime.friday: 'Jumat', DateTime.saturday: 'Sabtu', DateTime.sunday: 'Minggu',
    };
    return days[DateTime.now().weekday] ?? 'Senin';
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text('Keluar dari Akun?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin mengakhiri sesi ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () async {
              await UserInfo.setLoginStatus(false);
              if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menampilkan Daftar Tugas yang Tersedia
  void _showTugasTersedia() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: lightEcru,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50, height: 5,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 20),
            Text("Tugas yang Tersedia", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: deepEcru)),
            const SizedBox(height: 20),
            ...JadwalPiket.daftarTugas.map((tugas) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: Icon(Icons.check_circle_outline_rounded, color: darkEcru),
                title: Text(tugas, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Tugas operasional harian"),
              ),
            )).toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _navigateToTambahJadwal() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => DataForm(dataExist: widget.dataPiket)));
    if (result != null && result is JadwalPiket) {
      setState(() => widget.dataPiket.add(result));
      widget.onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    String hariIni = _getHariIni();
    List<JadwalPiket> petugasHariIni = widget.dataPiket.where((item) => item.hariPiket == hariIni).toList();
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    String userNama = UserInfo.getNama();
    String? userPic = UserInfo.getProfilePic();

    return Scaffold(
      backgroundColor: lightEcru,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            centerTitle: true,
            backgroundColor: darkEcru,
            elevation: 0,
            title: const Text('MANAJEMEN PIKET', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white, letterSpacing: 1.2)),
            actions: [
              IconButton(icon: const Icon(Icons.exit_to_app_rounded, color: Colors.white, size: 24), onPressed: () => _confirmLogout(context)),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [darkEcru, primaryEcru]),
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
                ),
                child: Stack(
                  children: [
                    Positioned(top: -20, right: -20, child: CircleAvatar(radius: 60, backgroundColor: Colors.white.withOpacity(0.05))),
                    Positioned(bottom: 40, left: -20, child: CircleAvatar(radius: 40, backgroundColor: Colors.white.withOpacity(0.05))),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 100, 24, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_getGreeting(), style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                                const SizedBox(height: 4),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(userNama, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 14),
                                      const SizedBox(width: 8),
                                      Text(hariIni, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 2)),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.white24,
                              backgroundImage: (userPic != null && !userPic.startsWith('http')) ? FileImage(File(userPic)) : null,
                              child: userPic == null ? Text(userNama[0].toUpperCase(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)) : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Petugas Hari Ini', hariIni),
                  const SizedBox(height: 16),
                  _buildPetugasHariIniCard(petugasHariIni),
                  const SizedBox(height: 40),
                  Text('Menu Utama', style: TextStyle(fontSize: isMobile ? 18 : 22, fontWeight: FontWeight.bold, color: deepEcru)),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isMobile ? 2 : 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isMobile ? 1.3 : 1.5,
                    children: [
                      _buildMenuCard(Icons.calendar_month_rounded, 'Daftar Jadwal', primaryEcru, () => widget.onNavigateToTab(1)),
                      _buildMenuCard(Icons.person_add_rounded, 'Tambah Data', darkEcru, () => _navigateToTambahJadwal()),
                      _buildMenuCard(Icons.account_circle_outlined, 'Profil Saya', deepEcru, () => widget.onNavigateToTab(2)),
                      _buildMenuCard(Icons.assignment_turned_in_rounded, 'Tugas Tersedia', const Color(0xFFAD9F6D), () => _showTugasTersedia()),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        if (subtitle != null)
          Text(subtitle, style: TextStyle(color: darkEcru, fontWeight: FontWeight.bold, fontSize: 11)),
      ],
    );
  }

  Widget _buildMenuCard(IconData icon, String label, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)),
            const SizedBox(height: 10),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87, height: 1.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildPetugasHariIniCard(List<JadwalPiket> petugas) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)],
      ),
      child: Column(
        children: [
          if (petugas.isEmpty)
            const Padding(padding: EdgeInsets.all(40.0), child: Center(child: Text('Tidak ada petugas piket hari ini', style: TextStyle(color: Colors.grey, fontSize: 12))))
          else ...petugas.map((p) => ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: primaryEcru.withOpacity(0.1),
              child: Text(p.namaPetugas[0].toUpperCase(), style: TextStyle(color: darkEcru, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            title: Text(p.namaPetugas, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text('${p.shift} • ${p.statusPiket}', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
            trailing: Text(p.jamPiket, style: TextStyle(color: darkEcru, fontWeight: FontWeight.bold, fontSize: 11)),
          )).toList(),
        ],
      ),
    );
  }
}
