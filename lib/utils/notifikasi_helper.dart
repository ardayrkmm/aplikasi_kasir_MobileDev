import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobiledev/utils/tema_aplikasi.dart';

void tutupRuteAktif() {
  final navigator = Get.key.currentState;
  if (navigator != null && navigator.canPop()) {
    navigator.pop();
  }
}

void tampilkanNotifikasiSukses(String judul, String pesan) {
  _tampilkanSnackBarMaterial(
    judul: judul,
    pesan: pesan,
    warnaLatar: TemaAplikasi.warnaSukses,
    ikon: Icons.check_circle_outline,
  );
}

void tampilkanNotifikasiGagal(String judul, String pesan) {
  _tampilkanSnackBarMaterial(
    judul: judul,
    pesan: pesan,
    warnaLatar: TemaAplikasi.warnaBahaya,
    ikon: Icons.error_outline,
  );
}

void tampilkanNotifikasiPeringatan(String judul, String pesan) {
  _tampilkanSnackBarMaterial(
    judul: judul,
    pesan: pesan,
    warnaLatar: TemaAplikasi.warnaPeringatan,
    ikon: Icons.warning_amber_rounded,
  );
}

void _tampilkanSnackBarMaterial({
  required String judul,
  required String pesan,
  required Color warnaLatar,
  required IconData ikon,
}) {
  final messenger = Get.rootController.scaffoldMessengerKey.currentState;
  if (messenger == null) return;

  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: warnaLatar,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(ikon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    judul,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    pesan,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
}
