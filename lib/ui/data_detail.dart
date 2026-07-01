import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/jadwal_piket.dart';
import '../widgets/success_dialog.dart';
import 'data_form.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DataDetail extends StatefulWidget {
  final JadwalPiket jadwal;
  final Function(JadwalPiket) onUpdate;
  final VoidCallback onDelete;
  final List<JadwalPiket> dataExist;

  const DataDetail({
    super.key,
    required this.jadwal,
    required this.onUpdate,
    required this.onDelete,
    required this.dataExist,
  });

  @override
  State<DataDetail> createState() => _DataDetailState();
}

class _DataDetailState extends State<DataDetail> {
  late JadwalPiket _jadwal;
  final Color darkEcru = const Color(0xFF8B7E55);
  final Color primaryEcru = const Color(0xFFC2B280);
  final Color lightEcru = const Color(0xFFFDFDF5);

  @override
  void initState() {
    super.initState();
    _jadwal = widget.jadwal;
  }

  Color _getShiftColor() {
    switch (_jadwal.shift) {
      case 'Pagi': return const Color(0xFFC2B280);
      case 'Siang': return const Color(0xFFD27D2D);
      case 'Sore': return const Color(0xFF556B2F);
      default: return Colors.grey;
    }
  }

  Color _getStatusColor() {
    return _jadwal.statusPiket == 'Sudah Piket' ? Colors.green : Colors.orange;
  }

  Future<void> _pickBukti(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _jadwal.buktiPiketPath = image.path;
          _jadwal.statusPiket = 'Sudah Piket';
        });
        widget.onUpdate(_jadwal);
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => SuccessDialog(
              description: "Bukti piket berhasil diunggah. Status: Sudah Piket",
              okClick: () => Navigator.pop(context),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengambil gambar: $e"), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _showPickOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Pilih Sumber Foto", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionItem(Icons.camera_alt_rounded, "Kamera", () {
                  Navigator.pop(context);
                  _pickBukti(ImageSource.camera);
                }),
                _buildOptionItem(Icons.photo_library_rounded, "Galeri / File", () {
                  Navigator.pop(context);
                  _pickBukti(ImageSource.gallery);
                }),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: primaryEcru.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: darkEcru, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkEcru)),
        ],
      ),
    );
  }

  void _removeBukti() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Bukti Piket?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin menghapus foto bukti piket ini? Status akan dikembalikan ke Belum Piket.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _jadwal.buktiPiketPath = null;
                _jadwal.statusPiket = 'Belum Piket';
              });
              widget.onUpdate(_jadwal);
              Navigator.pop(context); // Tutup AlertDialog
              if (mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => SuccessDialog(
                    description: "Bukti piket berhasil dihapus. Status: Belum Piket",
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
    bool hasImage = _jadwal.imagePath != null && _jadwal.imagePath!.isNotEmpty;

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
            title: const Text(
              'DETAIL PETUGAS',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18, letterSpacing: 1.2),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [darkEcru, primaryEcru],
                      ),
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                    ),
                  ),
                  Positioned(right: -20, top: 20, child: Icon(Icons.assignment_ind_rounded, size: 180, color: Colors.white.withOpacity(0.05))),
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
                            child: const Text(
                              'Informasi Lengkap Jadwal',
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 26), onPressed: () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => DataForm(initialData: _jadwal, dataExist: widget.dataExist)));
                if (result != null && result is JadwalPiket) { setState(() => _jadwal = result); widget.onUpdate(result); }
              }),
              IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24), onPressed: () => _showDeleteDialog(context)),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1000),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildAvatarSection(hasImage),
                    const SizedBox(height: 40),
                    _buildBuktiPiketCard(),
                    const SizedBox(height: 24),
                    _buildDetailCard(
                      title: 'Jadwal Kerja',
                      icon: Icons.event_note_rounded,
                      items: [
                        _buildInfoRow(Icons.calendar_today_rounded, 'Hari Piket', _jadwal.hariPiket),
                        _buildInfoRow(Icons.access_time_rounded, 'Shift Kerja', '${_jadwal.shift} (${_jadwal.jamPiket})', color: _getShiftColor()),
                        _buildInfoRow(Icons.assignment_rounded, 'Tugas Utama', _jadwal.tugas),
                        _buildInfoRow(Icons.check_circle_outline_rounded, 'Status Piket', _jadwal.statusPiket, color: _getStatusColor()),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(bool hasImage) {
    return Column(
      children: [
        Hero(
          tag: 'avatar-${_jadwal.id}',
          child: Container(
            width: 130, height: 130,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
              image: hasImage
                  ? DecorationImage(
                      image: (kIsWeb || _jadwal.imagePath!.startsWith('http'))
                          ? NetworkImage(_jadwal.imagePath!)
                          : FileImage(File(_jadwal.imagePath!)) as ImageProvider,
                      fit: BoxFit.cover)
                  : null,
            ),
            child: !hasImage ? Center(child: Text(_jadwal.namaPetugas[0].toUpperCase(), style: TextStyle(fontSize: 55, fontWeight: FontWeight.bold, color: darkEcru))) : null,
          ),
        ),
        const SizedBox(height: 24),
        Text(_jadwal.namaPetugas, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text('ID Petugas: ${_jadwal.kodePetugas}', style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Hapus Data?'),
      content: Text('Hapus data petugas ${_jadwal.namaPetugas} secara permanen?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: TextStyle(color: Colors.grey.shade600))),
        ElevatedButton(
          onPressed: () { 
            Navigator.pop(context); 
            widget.onDelete(); 
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => SuccessDialog(
                description: "Data petugas berhasil dihapus",
                okClick: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            );
          }, 
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), 
          child: const Text('Ya, Hapus')
        ),
      ],
    ));
  }

  Widget _buildBuktiPiketCard() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [Icon(Icons.camera_enhance_rounded, size: 22, color: darkEcru), const SizedBox(width: 10), Text('Bukti Foto Piket', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkEcru))]),
              if (_jadwal.buktiPiketPath != null) Row(children: [IconButton(icon: Icon(Icons.camera_alt, color: darkEcru, size: 20), onPressed: _showPickOptions), IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20), onPressed: _removeBukti)]),
            ],
          ),
          const Divider(height: 30),
          if (_jadwal.buktiPiketPath == null) Center(child: ElevatedButton.icon(onPressed: _showPickOptions, icon: const Icon(Icons.add_a_photo, size: 18), label: const Text("Upload Bukti", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: darkEcru, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))))
          else ClipRRect(
            borderRadius: BorderRadius.circular(20), 
            child: (kIsWeb || _jadwal.buktiPiketPath!.startsWith('http'))
              ? Image.network(_jadwal.buktiPiketPath!, width: double.infinity, height: 250, fit: BoxFit.cover)
              : Image.file(File(_jadwal.buktiPiketPath!), width: double.infinity, height: 250, fit: BoxFit.cover)
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({required String title, required IconData icon, required List<Widget> items}) {
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, size: 22, color: darkEcru), const SizedBox(width: 10), Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkEcru))]), const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(height: 1)), ...items]));
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? color}) {
    return Padding(padding: const EdgeInsets.only(bottom: 16), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: (color ?? darkEcru).withAlpha(20), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: color ?? darkEcru)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600)), const SizedBox(height: 2), Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color ?? Colors.black87))]))]));
  }
}
