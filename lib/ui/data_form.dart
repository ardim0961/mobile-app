import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/jadwal_piket.dart';
import '../widgets/success_dialog.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DataForm extends StatefulWidget {
  final JadwalPiket? initialData;
  final List<JadwalPiket> dataExist;
  const DataForm({super.key, this.initialData, required this.dataExist});

  @override
  State<DataForm> createState() => _DataFormState();
}

class _DataFormState extends State<DataForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _kodeController;
  late TextEditingController _namaController;

  String? _hariTerpilih;
  String? _shiftTerpilih;
  String? _tugasTerpilih;
  String? _imagePath;
  bool _isLoading = false;

  final Color darkEcru = const Color(0xFF8B7E55);
  final Color primaryEcru = const Color(0xFFC2B280);
  final Color lightEcru = const Color(0xFFFDFDF5);

  @override
  void initState() {
    super.initState();
    _kodeController = TextEditingController(text: widget.initialData?.kodePetugas);
    _namaController = TextEditingController(text: widget.initialData?.namaPetugas);
    _hariTerpilih = widget.initialData?.hariPiket;
    _shiftTerpilih = widget.initialData?.shift;
    _tugasTerpilih = widget.initialData?.tugas;
    _imagePath = widget.initialData?.imagePath;
  }

  @override
  void dispose() {
    _kodeController.dispose();
    _namaController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      
      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengambil foto: $e")),
      );
    }
  }

  void _simpanData() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      Future.delayed(const Duration(seconds: 1), () {
        String jamOtomatis = JadwalPiket.jamPerShift[_shiftTerpilih] ?? '-';

        final dataBaru = JadwalPiket(
          id: widget.initialData?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          kodePetugas: _kodeController.text,
          namaPetugas: _namaController.text,
          hariPiket: _hariTerpilih!,
          shift: _shiftTerpilih!,
          tugas: _tugasTerpilih!,
          jamPiket: jamOtomatis,
          // Status awal selalu "Belum Piket" jika data baru, atau preservasi status lama jika edit
          statusPiket: widget.initialData?.statusPiket ?? 'Belum Piket',
          imagePath: _imagePath,
          // Preservasi bukti piket jika ada (hanya bisa diubah di halaman detail)
          buktiPiketPath: widget.initialData?.buktiPiketPath,
        );

        if (mounted) {
          setState(() => _isLoading = false);
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => SuccessDialog(
              description: widget.initialData == null ? "DATA PETUGAS BERHASIL DITAMBAHKAN" : "DATA PETUGAS BERHASIL DIPERBARUI",
              okClick: () {
                Navigator.pop(context);
                Navigator.pop(context, dataBaru);
              },
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.initialData != null;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: lightEcru,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            centerTitle: true,
            backgroundColor: darkEcru,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              isEdit ? 'EDIT JADWAL' : 'TAMBAH JADWAL',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18, letterSpacing: 1.2),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [darkEcru, primaryEcru.withOpacity(0.9)],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -10,
                    top: 10,
                    child: Icon(isEdit ? Icons.edit_calendar_rounded : Icons.add_task_rounded, size: 160, color: Colors.white.withOpacity(0.05)),
                  ),
                  Positioned.fill(
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(isEdit ? Icons.edit_note_rounded : Icons.post_add_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 8),
                                const Text(
                                  'FORMULIR DATA PETUGAS',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                                ),
                              ],
                            ),
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
                constraints: const BoxConstraints(maxWidth: 1000),
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildProfileImagePicker(),
                      const SizedBox(height: 40),
                      Card(
                        elevation: 4,
                        shadowColor: Colors.black12,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 32, vertical: 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 0),
                                child: Text("INFORMASI PETUGAS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkEcru, letterSpacing: 0.5)),
                              ),
                              const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider(height: 1)),
                              _buildTextField(_kodeController, "KODE PETUGAS", Icons.vpn_key_outlined),
                              const SizedBox(height: 20),
                              _buildTextField(_namaController, "NAMA LENGKAP", Icons.person_outline),
                              const SizedBox(height: 20),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildDropdownField("HARI", Icons.calendar_today_rounded, _hariTerpilih, JadwalPiket.daftarHari, (v) => setState(() => _hariTerpilih = v), isMobile)),
                                  SizedBox(width: isMobile ? 6 : 16),
                                  Expanded(child: _buildDropdownField("SHIFT", Icons.access_time_rounded, _shiftTerpilih, JadwalPiket.daftarShift, (v) => setState(() => _shiftTerpilih = v), isMobile)),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildDropdownField("TUGAS", Icons.assignment_outlined, _tugasTerpilih, JadwalPiket.daftarTugas, (v) => setState(() => _tugasTerpilih = v), isMobile),
                              const SizedBox(height: 48),
                              SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _simpanData,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2C3E50),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 4,
                                  ),
                                  child: _isLoading 
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text("SIMPAN DATA JADWAL", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImagePicker() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickProfileImage,
          child: Container(
            width: 140, height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: primaryEcru.withOpacity(0.3), width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
              image: _imagePath != null
                ? DecorationImage(
                    image: (kIsWeb || _imagePath!.startsWith('http'))
                        ? NetworkImage(_imagePath!)
                        : FileImage(File(_imagePath!)) as ImageProvider,
                    fit: BoxFit.cover)
                : null,
            ),
            child: _imagePath == null 
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 40, color: primaryEcru),
                    const SizedBox(height: 8),
                    Text("FOTO PROFIL", style: TextStyle(color: primaryEcru, fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ) 
              : null,
          ),
        ),
        if (_imagePath != null)
          TextButton.icon(
            onPressed: () => setState(() => _imagePath = null),
            icon: const Icon(Icons.delete_sweep_rounded, size: 18),
            label: const Text("HAPUS FOTO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
          ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label, 
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        prefixIcon: Icon(icon, color: primaryEcru, size: 22), 
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primaryEcru, width: 2)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
    );
  }

  Widget _buildDropdownField(String label, IconData icon, String? value, List<String> items, Function(String?) onChanged, bool isMobile) {
    bool isNarrow = label.toUpperCase() == "HARI" || label.toUpperCase() == "SHIFT";

    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      icon: Icon(Icons.arrow_drop_down_rounded, size: isMobile ? 18 : 24, color: primaryEcru),
      style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.black87, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label, 
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: isMobile ? 8 : 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        prefixIcon: isMobile && isNarrow ? null : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Icon(icon, color: primaryEcru, size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primaryEcru, width: 2)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.fromLTRB(isMobile && isNarrow ? 8 : 12, 16, 2, 16),
      ),
      items: items.map((item) => DropdownMenuItem(
        value: item, 
        child: Text(item, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: isMobile ? 11 : 14))
      )).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Pilih' : null,
    );
  }
}
