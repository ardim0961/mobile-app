import 'package:flutter/material.dart';
import 'home_page.dart';
import 'data_page.dart';
import 'profile_page.dart';
import '../models/jadwal_piket.dart';
import '../helpers/piket_storage.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<JadwalPiket> dataPiket = [];
  bool _isLoading = true;

  // Warna Konsisten dengan Tema
  final Color primaryEcru = const Color(0xFFC2B280);
  final Color darkEcru = const Color(0xFF8B7E55);
  final Color lightEcru = const Color(0xFFFDFDF5);
  final Color deepSlate = const Color(0xFF2C3E50);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedData = await PiketStorage.loadPiketList();
    setState(() {
      if (loadedData.isEmpty) {
        dataPiket = [
          JadwalPiket(id: '1', kodePetugas: 'P001', namaPetugas: 'Budi Santoso', hariPiket: 'Senin', shift: 'Pagi', tugas: 'Sapu', jamPiket: '07:00'),
          JadwalPiket(id: '2', kodePetugas: 'P002', namaPetugas: 'Ani Wijaya', hariPiket: 'Selasa', shift: 'Siang', tugas: 'Pel', jamPiket: '12:00'),
        ];
        PiketStorage.savePiketList(dataPiket);
      } else {
        dataPiket = loadedData;
      }
      _isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _updateData() {
    setState(() {});
    PiketStorage.savePiketList(dataPiket);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: lightEcru,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(darkEcru),
            strokeWidth: 3,
          ),
        ),
      );
    }

    final List<Widget> pages = [
      HomePage(
        dataPiket: dataPiket,
        onRefresh: _updateData,
        onNavigateToTab: _onItemTapped,
      ),
      DataPage(dataPiket: dataPiket, onRefresh: _updateData),
      const ProfilePage(),
    ];

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWideScreen = screenWidth > 900;

    return Scaffold(
      backgroundColor: lightEcru,
      body: Row(
        children: [
          if (isWideScreen)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelType: NavigationRailLabelType.all,
              backgroundColor: Colors.white,
              selectedIconTheme: IconThemeData(color: darkEcru),
              unselectedIconTheme: const IconThemeData(color: Colors.grey),
              selectedLabelTextStyle: TextStyle(color: darkEcru, fontWeight: FontWeight.bold, fontSize: 12),
              unselectedLabelTextStyle: const TextStyle(color: Colors.grey, fontSize: 12),
              leading: Column(
                children: [
                  const SizedBox(height: 20),
                  Icon(Icons.assignment_ind_rounded, size: 40, color: darkEcru),
                  const SizedBox(height: 20),
                ],
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: Text('Beranda'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.list_alt_outlined),
                  selectedIcon: Icon(Icons.list_alt_rounded),
                  label: Text('Jadwal'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: Text('Profil'),
                ),
              ],
            ),
          if (isWideScreen) const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isWideScreen
          ? Container(
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                selectedItemColor: darkEcru,
                unselectedItemColor: Colors.grey.shade400,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                unselectedLabelStyle: const TextStyle(fontSize: 12),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_rounded),
                    label: 'Beranda',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.list_alt_rounded),
                    label: 'Jadwal',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_rounded),
                    label: 'Profil',
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
