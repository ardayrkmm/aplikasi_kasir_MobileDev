import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobiledev/data/models/pengguna_model.dart';
import 'package:mobiledev/data/services/penyimpanan_service.dart';
import 'package:mobiledev/utils/notifikasi_helper.dart';

class AutentikasiController extends GetxController {
  final PenyimpananService _penyimpanan = Get.find<PenyimpananService>();

  final Rxn<PenggunaModel> sesiPengguna = Rxn<PenggunaModel>();
  final RxBool sedangMemuat = false.obs;

  void _pindahKeRute(String rute) {
    if (Get.key.currentState != null) {
      Get.offAllNamed(rute);
    }
  }

  Future<void> cekSesiLogin() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    final penggunaTersimpan = _penyimpanan.ambilSesiPengguna();
    sesiPengguna.value = penggunaTersimpan;

    if (penggunaTersimpan != null) {
      _pindahKeRute('/beranda');
    } else {
      _pindahKeRute('/login');
    }
  }

  Future<bool> daftarAkun({
    required String nama,
    required String namaPengguna,
    required String kataSandi,
  }) async {
    sedangMemuat.value = true;
    try {
      final daftarPengguna = _penyimpanan.ambilDaftarPengguna();
      final namaPenggunaBersih = namaPengguna.trim().toLowerCase();

      final sudahTerdaftar = daftarPengguna.any(
        (p) => p.namaPengguna.trim().toLowerCase() == namaPenggunaBersih,
      );

      if (sudahTerdaftar) {
        tampilkanNotifikasiGagal(
          'Pendaftaran Gagal',
          'Username "$namaPengguna" sudah terdaftar. Gunakan username lain.',
        );
        return false;
      }

      final penggunaBaru = PenggunaModel(
        id: PenyimpananService.buatIdUnik('usr'),
        nama: nama.trim(),
        namaPengguna: namaPengguna.trim(),
        kataSandi: kataSandi,
      );

      daftarPengguna.add(penggunaBaru);
      await _penyimpanan.simpanDaftarPengguna(daftarPengguna);

      return true;
    } finally {
      sedangMemuat.value = false;
    }
  }

  Future<bool> masukAkun({
    required String namaPengguna,
    required String kataSandi,
  }) async {
    sedangMemuat.value = true;
    try {
      final daftarPengguna = _penyimpanan.ambilDaftarPengguna();
      final namaPenggunaBersih = namaPengguna.trim().toLowerCase();

      final penggunaCocok = daftarPengguna.firstWhereOrNull(
        (p) =>
            p.namaPengguna.trim().toLowerCase() == namaPenggunaBersih &&
            p.kataSandi == kataSandi,
      );

      if (penggunaCocok == null) {
        tampilkanNotifikasiGagal(
          'Login Gagal',
          'Username atau password salah, atau akun belum terdaftar.',
        );
        return false;
      }

      await _penyimpanan.simpanSesiPengguna(penggunaCocok);
      sesiPengguna.value = penggunaCocok;
      _pindahKeRute('/beranda');
      return true;
    } finally {
      sedangMemuat.value = false;
    }
  }

  Future<void> keluarAkun() async {
    await _penyimpanan.simpanSesiPengguna(null);
    sesiPengguna.value = null;
    _pindahKeRute('/login');
  }
}

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    Get.find<AutentikasiController>().cekSesiLogin();
  }
}

class LoginController extends GetxController {
  final AutentikasiController autentikasi = Get.find<AutentikasiController>();
  final GlobalKey<FormState> formKunci = GlobalKey<FormState>();

  final TextEditingController pengontrolUsername = TextEditingController();
  final TextEditingController pengontrolPassword = TextEditingController();
  final RxBool sembunyikanPassword = true.obs;

  void ubahTampilanPassword() {
    sembunyikanPassword.toggle();
  }

  void tanganiMasuk() {
    if (formKunci.currentState?.validate() ?? false) {
      autentikasi.masukAkun(
        namaPengguna: pengontrolUsername.text,
        kataSandi: pengontrolPassword.text,
      );
    }
  }

  @override
  void onClose() {
    pengontrolUsername.dispose();
    pengontrolPassword.dispose();
    super.onClose();
  }
}

class RegisterController extends GetxController {
  final AutentikasiController autentikasi = Get.find<AutentikasiController>();
  final GlobalKey<FormState> formKunci = GlobalKey<FormState>();

  final TextEditingController pengontrolNama = TextEditingController();
  final TextEditingController pengontrolUsername = TextEditingController();
  final TextEditingController pengontrolPassword = TextEditingController();

  final RxBool sembunyikanPassword = true.obs;

  void ubahTampilanPassword() {
    sembunyikanPassword.toggle();
  }

  Future<void> tanganiDaftar() async {
    if (formKunci.currentState?.validate() ?? false) {
      final usernameBaru = pengontrolUsername.text.trim();
      final berhasil = await autentikasi.daftarAkun(
        nama: pengontrolNama.text,
        namaPengguna: usernameBaru,
        kataSandi: pengontrolPassword.text,
      );

      if (berhasil) {
        if (Get.isRegistered<LoginController>()) {
          Get.find<LoginController>().pengontrolUsername.text = usernameBaru;
        }
        tutupRuteAktif();
        tampilkanNotifikasiSukses(
          'Pendaftaran Berhasil',
          'Akun "$usernameBaru" berhasil dibuat. Silakan masuk.',
        );
      }
    }
  }

  @override
  void onClose() {
    pengontrolNama.dispose();
    pengontrolUsername.dispose();
    pengontrolPassword.dispose();
    super.onClose();
  }
}
