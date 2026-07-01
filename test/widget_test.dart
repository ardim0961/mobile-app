import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ardiapp/main.dart';
import 'package:ardiapp/ui/data_form.dart';
import 'package:ardiapp/ui/data_detail.dart';
import 'package:ardiapp/models/jadwal_piket.dart';

void main() {
  // Fungsi pembantu untuk navigasi ke tab Data Piket
  Future<void> navigasiKeDataPiket(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    
    final tabDataPiket = find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.text('Jadwal'),
    );
    
    await tester.tap(tabDataPiket);
    await tester.pumpAndSettle();
  }

  group('Testing Aplikasi Manajemen Piket', () {

    testWidgets('Test 1: Aplikasi menampilkan home page',
            (WidgetTester tester) async {
          await tester.pumpWidget(const MyApp());
          await tester.pumpAndSettle();
          expect(find.text('MANAJEMEN PIKET'), findsOneWidget);
        });

    testWidgets('Test 2: Navigasi ke Daftar Piket menampilkan grup hari',
            (WidgetTester tester) async {
          await navigasiKeDataPiket(tester);
          // Judul baru sesuai data_page.dart
          expect(find.text('JADWAL PETUGAS'), findsOneWidget);
          expect(find.text('Senin'), findsOneWidget);
        });

    testWidgets('Test 3: Search Nama/Kode Petugas menampilkan hasil spesifik',
            (WidgetTester tester) async {
          await navigasiKeDataPiket(tester);
          
          await tester.enterText(find.byType(TextField), 'Budi');
          await tester.pumpAndSettle();

          expect(find.text('Budi Santoso'), findsOneWidget);
        });

    testWidgets('Test 4: Floating Action Button membuka Form',
            (WidgetTester tester) async {
          await navigasiKeDataPiket(tester);
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();

          // Judul baru sesuai data_form.dart
          expect(find.text('TAMBAH JADWAL'), findsOneWidget);
        });

    testWidgets('Test 5: Validasi form nama wajib diisi',
            (WidgetTester tester) async {
          await tester.pumpWidget(const MaterialApp(home: DataForm(dataExist: [])));
          await tester.pumpAndSettle();

          // Teks tombol baru sesuai data_form.dart
          await tester.tap(find.widgetWithText(ElevatedButton, 'SIMPAN DATA JADWAL'));
          await tester.pump();

          expect(find.text('Wajib diisi'), findsAtLeastNWidgets(1));
        });

    testWidgets('Test 6: Menambah data baru',
            (WidgetTester tester) async {
          await navigasiKeDataPiket(tester);
          
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();

          // Menggunakan ancestor finder karena widgetWithLabel tidak ditemukan di versi Flutter ini
          await tester.enterText(find.ancestor(of: find.text('NAMA LENGKAP'), matching: find.byType(TextFormField)), 'Atha Test');
          await tester.enterText(find.ancestor(of: find.text('KODE PETUGAS'), matching: find.byType(TextFormField)), 'P999');
          
          await tester.tap(find.text('HARI'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Senin').last);
          await tester.pumpAndSettle();

          await tester.tap(find.text('SHIFT'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Pagi').last);
          await tester.pumpAndSettle();

          await tester.tap(find.text('TUGAS'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Sapu').last);
          await tester.pumpAndSettle();

          await tester.tap(find.widgetWithText(ElevatedButton, 'SIMPAN DATA JADWAL'));
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Verifikasi dialog sukses
          expect(find.text('DATA PETUGAS BERHASIL DITAMBAHKAN'), findsOneWidget);
        });

    testWidgets('Test 7: Detail menampilkan data yang benar',
            (WidgetTester tester) async {
          final testJadwal = JadwalPiket(
            id: 't1',
            kodePetugas: 'T001',
            namaPetugas: 'Tester Pel',
            hariPiket: 'Rabu',
            shift: 'Siang',
            tugas: 'Pel',
            jamPiket: '12:00',
            statusPiket: 'Belum Piket',
          );

          await tester.pumpWidget(MaterialApp(home: DataDetail(
            jadwal: testJadwal,
            onUpdate: (updatedJadwal) {},
            onDelete: () {},
            dataExist: const [],
          )));
          await tester.pumpAndSettle();

          expect(find.text('Tester Pel'), findsOneWidget);
          expect(find.text('Pel'), findsOneWidget);
          expect(find.text('Belum Piket'), findsOneWidget);
        });
  });
}
