import 'package:flutter/material.dart';

class SuccessDialog extends StatelessWidget {
  final String description;
  final VoidCallback okClick;

  const SuccessDialog({super.key, required this.description, required this.okClick});

  @override
  Widget build(BuildContext context) {
    // Warna Ecru Gelap untuk tombol
    const Color darkEcru = Color(0xFF8B7E55);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 70),
            const SizedBox(height: 16),
            const Text(
              "Berhasil",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              description, 
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: okClick,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkEcru,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
