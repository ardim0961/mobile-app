import 'package:flutter/material.dart';
import 'dart:io';
import '../models/jadwal_piket.dart';
import 'data_form.dart';
import 'data_detail.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DataPage extends StatefulWidget {
  final List<JadwalPiket> dataPiket;
  final VoidCallback onRefresh;

  const DataPage({
    super.key,
    required this.dataPiket,
    required this.onRefresh,
  });

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedHariFilter = 'Semua';
  bool _isLoading = false;

  final Color darkEcru = const Color(0xFF8B7E55);
  final Color primaryEcru = const Color(0xFFC2B280);
  final Color lightEcru = const Color(0xFFFDFDF5);

  void _tambahData(JadwalPiket dataBaru) {
    setState(() => widget.dataPiket.add(dataBaru));
    widget.onRefresh();
  }

  void _updateData(JadwalPiket updatedData) {
    setState(() {
      final index = widget.dataPiket.indexWhere((item) => item.id == updatedData.id);
      if (index != -1) widget.dataPiket[index] = updatedData;
    });
    widget.onRefresh();
  }

  void _hapusData(String id) {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          widget.dataPiket.removeWhere((item) => item.id == id);
          _isLoading = false;
        });
        widget.onRefresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    final filteredData = widget.dataPiket.where((item) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch = item.namaPetugas.toLowerCase().contains(query) || item.kodePetugas.toLowerCase().contains(query);
      final matchesHari = _selectedHariFilter == 'Semua' || item.hariPiket == _selectedHariFilter;
      return matchesSearch && matchesHari;
    }).toList();

    return Scaffold(
      backgroundColor: lightEcru,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: isMobile ? 200 : 240,
            pinned: true,
            centerTitle: true,
            elevation: 0,
            backgroundColor: darkEcru,
            title: const Text(
              'JADWAL PETUGAS',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18, letterSpacing: 1.2),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft, 
                        end: Alignment.bottomRight, 
                        colors: [darkEcru, primaryEcru]
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40), 
                        bottomRight: Radius.circular(40)
                      ),
                    ),
                  ),
                  Positioned(
                    right: -20,
                    top: 20,
                    child: Icon(Icons.calendar_view_day_rounded, size: 180, color: Colors.white.withOpacity(0.05)),
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
                                const Icon(Icons.list_alt_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 8),
                                Text(
                                  'Total ${filteredData.length} Petugas Terdaftar',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
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
        ],
        body: Column(
          children: [
            const SizedBox(height: 24),
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1000),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white, 
                        borderRadius: BorderRadius.circular(20), 
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)]
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'Cari nama atau ID petugas...', 
                          hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                          prefixIcon: Icon(Icons.search_rounded, color: darkEcru), 
                          border: InputBorder.none, 
                          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16)
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: ['Semua', ...JadwalPiket.daftarHari].map((hari) {
                          final isSelected = _selectedHariFilter == hari;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ChoiceChip(
                              label: Text(hari),
                              selected: isSelected,
                              onSelected: (val) => setState(() => _selectedHariFilter = hari),
                              selectedColor: darkEcru,
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                fontSize: 13,
                                color: isSelected ? Colors.white : Colors.grey.shade700, 
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? darkEcru : Colors.grey.shade200)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading 
                ? Center(child: CircularProgressIndicator(color: darkEcru))
                : Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: filteredData.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text('Data tidak ditemukan', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                              itemCount: filteredData.length,
                              itemBuilder: (context, index) => ItemPiketTile(
                                jadwal: filteredData[index], 
                                onDelete: (id) => _hapusData(id), 
                                onUpdate: _updateData, 
                                dataExist: widget.dataPiket
                              ),
                            ),
                    ),
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await Navigator.push(context, MaterialPageRoute(builder: (c) => DataForm(dataExist: widget.dataPiket)));
          if (res != null) _tambahData(res);
        },
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Jadwal', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        elevation: 6,
      ),
    );
  }
}

class ItemPiketTile extends StatelessWidget {
  final JadwalPiket jadwal;
  final Function(String) onDelete;
  final Function(JadwalPiket) onUpdate;
  final List<JadwalPiket> dataExist;

  const ItemPiketTile({super.key, required this.jadwal, required this.onDelete, required this.onUpdate, required this.dataExist});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => DataDetail(jadwal: jadwal, onUpdate: onUpdate, onDelete: () => onDelete(jadwal.id), dataExist: dataExist))),
        leading: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade100, width: 2),
          ),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF8B7E55).withOpacity(0.05),
            backgroundImage: (jadwal.imagePath != null && !jadwal.imagePath!.startsWith('http')) 
                ? (kIsWeb ? NetworkImage(jadwal.imagePath!) : FileImage(File(jadwal.imagePath!)) as ImageProvider)
                : null,
            child: jadwal.imagePath == null ? Text(jadwal.namaPetugas[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF8B7E55))) : null,
          ),
        ),
        title: Text(jadwal.namaPetugas, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kode: ${jadwal.kodePetugas}',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(jadwal.hariPiket, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  const SizedBox(width: 12),
                  Icon(Icons.access_time_rounded, size: 12, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(jadwal.shift, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300),
      ),
    );
  }
}
