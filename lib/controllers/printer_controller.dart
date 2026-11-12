import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mobiledev/data/models/transaksi_model.dart';
import 'package:mobiledev/utils/format_uang.dart';
import 'package:mobiledev/utils/notifikasi_helper.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class PrinterController extends GetxController {
  final RxBool bluetoothAktif = false.obs;
  final RxBool izinDiberikan = false.obs;
  final RxBool sedangMemindai = false.obs;
  final RxBool sedangMencetak = false.obs;
  final RxnString macPrinterTerhubung = RxnString();
  final RxString namaPrinterTerhubung = ''.obs;
  final RxList<BluetoothInfo> daftarPrinter = <BluetoothInfo>[].obs;
  final RxString ukuranKertas = '58mm'.obs;

  bool get apakahMendukungBluetooth {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows;
  }

  void aturUkuranKertas(String ukuran) {
    ukuranKertas.value = ukuran;
  }

  Future<void> pindaiPrinterBluetooth() async {
    if (!apakahMendukungBluetooth) {
      tampilkanNotifikasiPeringatan(
        'Tidak Didukung',
        'Printer Bluetooth thermal tidak didukung di browser Web.',
      );
      return;
    }

    sedangMemindai.value = true;
    try {
      final izin = await PrintBluetoothThermal.isPermissionBluetoothGranted;
      izinDiberikan.value = izin;
      if (!izin) {
        tampilkanNotifikasiPeringatan(
          'Izin Bluetooth Diperlukan',
          'Aktifkan izin Bluetooth untuk Aplikasi Kasir di pengaturan perangkat.',
        );
        return;
      }

      final aktif = await PrintBluetoothThermal.bluetoothEnabled;
      bluetoothAktif.value = aktif;
      if (!aktif) {
        tampilkanNotifikasiPeringatan(
          'Bluetooth Mati',
          'Nyalakan Bluetooth perangkat terlebih dahulu untuk mencari printer.',
        );
        return;
      }

      final perangkat = await PrintBluetoothThermal.pairedBluetooths;
      daftarPrinter.assignAll(perangkat);

      final terhubung = await PrintBluetoothThermal.connectionStatus;
      if (!terhubung) {
        macPrinterTerhubung.value = null;
        namaPrinterTerhubung.value = '';
      }
    } catch (_) {
      tampilkanNotifikasiGagal(
        'Gagal Memindai Printer',
        'Tidak dapat mengakses perangkat Bluetooth saat ini.',
      );
    } finally {
      sedangMemindai.value = false;
    }
  }

  Future<bool> hubungkanPrinter(BluetoothInfo perangkat) async {
    if (!apakahMendukungBluetooth) return false;

    sedangMemindai.value = true;
    try {
      final hasil = await PrintBluetoothThermal.connect(
        macPrinterAddress: perangkat.macAdress,
      );
      if (hasil) {
        macPrinterTerhubung.value = perangkat.macAdress;
        namaPrinterTerhubung.value = perangkat.name;
        tampilkanNotifikasiSukses(
          'Printer Terhubung',
          'Berhasil terhubung ke "${perangkat.name}".',
        );
      } else {
        tampilkanNotifikasiGagal(
          'Koneksi Gagal',
          'Gagal terhubung ke "${perangkat.name}". Pastikan printer menyala.',
        );
      }
      return hasil;
    } catch (_) {
      tampilkanNotifikasiGagal(
        'Koneksi Gagal',
        'Terjadi kesalahan saat menghubungkan printer.',
      );
      return false;
    } finally {
      sedangMemindai.value = false;
    }
  }

  Future<void> putuskanPrinter() async {
    if (!apakahMendukungBluetooth) return;
    await PrintBluetoothThermal.disconnect;
    macPrinterTerhubung.value = null;
    namaPrinterTerhubung.value = '';
    tampilkanNotifikasiPeringatan(
      'Koneksi Diputus',
      'Printer Bluetooth telah diputuskan.',
    );
  }

  Future<List<int>> buatByteStrukEscPos(TransaksiModel transaksi) async {
    final profil = await CapabilityProfile.load();
    final kertas = ukuranKertas.value == '80mm'
        ? PaperSize.mm80
        : PaperSize.mm58;
    final pembuat = Generator(kertas, profil);

    final bytes = <int>[];

    bytes.addAll(
      pembuat.text(
        transaksi.namaToko,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size1,
        ),
      ),
    );
    bytes.addAll(
      pembuat.text(
        'Struk Pembayaran Sah',
        styles: const PosStyles(align: PosAlign.center),
      ),
    );
    bytes.addAll(pembuat.hr());

    bytes.addAll(pembuat.text('No     : ${transaksi.nomorStruk}'));
    bytes.addAll(
      pembuat.text('Waktu  : ${formatTanggalWaktu(transaksi.waktu)}'),
    );
    bytes.addAll(pembuat.text('Kasir  : ${transaksi.namaKasir}'));
    bytes.addAll(pembuat.hr());

    for (final item in transaksi.daftarItem) {
      bytes.addAll(
        pembuat.row([
          PosColumn(
            text: '${item.namaProduk} x${item.jumlah}',
            width: 7,
            styles: const PosStyles(bold: true),
          ),
          PosColumn(
            text: formatRupiah(item.totalHargaItem),
            width: 5,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]),
      );
      bytes.addAll(pembuat.text('  @ ${formatRupiah(item.hargaProduk)}'));
      if (item.daftarTopping.isNotEmpty) {
        final teksTopping = item.daftarTopping
            .map((t) => '${t.nama} (+${formatRupiah(t.hargaTambahan)})')
            .join(', ');
        bytes.addAll(pembuat.text('  + $teksTopping'));
      }
    }

    bytes.addAll(pembuat.hr());
    bytes.addAll(
      pembuat.row([
        PosColumn(text: 'Subtotal', width: 6),
        PosColumn(
          text: formatRupiah(transaksi.subtotal),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]),
    );

    if (transaksi.potonganDiskon > 0) {
      final labelDiskon = transaksi.jenisDiskon == 'persen'
          ? 'Diskon (${transaksi.nilaiDiskonInput.toInt()}%)'
          : 'Diskon';
      bytes.addAll(
        pembuat.row([
          PosColumn(text: labelDiskon, width: 6),
          PosColumn(
            text: '-${formatRupiah(transaksi.potonganDiskon)}',
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]),
      );
    }

    bytes.addAll(
      pembuat.row([
        PosColumn(text: 'TOTAL', width: 6, styles: const PosStyles(bold: true)),
        PosColumn(
          text: formatRupiah(transaksi.totalAkhir),
          width: 6,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]),
    );
    bytes.addAll(
      pembuat.row([
        PosColumn(text: 'Bayar', width: 6),
        PosColumn(
          text: formatRupiah(transaksi.uangDiterima),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]),
    );
    bytes.addAll(
      pembuat.row([
        PosColumn(text: 'Kembalian', width: 6),
        PosColumn(
          text: formatRupiah(transaksi.uangKembalian),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]),
    );

    bytes.addAll(pembuat.hr());
    bytes.addAll(
      pembuat.text(
        'Terima kasih atas kunjungan Anda!',
        styles: const PosStyles(align: PosAlign.center),
      ),
    );
    bytes.addAll(pembuat.feed(2));
    bytes.addAll(pembuat.cut());

    return bytes;
  }

  Future<bool> cetakStruk(TransaksiModel transaksi) async {
    if (!apakahMendukungBluetooth) {
      tampilkanNotifikasiPeringatan(
        'Bluetooth Tidak Tersedia',
        'Cetak langsung ke printer Bluetooth hanya tersedia di aplikasi native.',
      );
      return false;
    }

    sedangMencetak.value = true;
    try {
      final terhubung = await PrintBluetoothThermal.connectionStatus;
      if (!terhubung) {
        macPrinterTerhubung.value = null;
        namaPrinterTerhubung.value = '';
        tampilkanNotifikasiPeringatan(
          'Printer Belum Terhubung',
          'Pilih dan hubungkan printer Bluetooth thermal terlebih dahulu.',
        );
        return false;
      }

      final bytes = await buatByteStrukEscPos(transaksi);
      final sukses = await PrintBluetoothThermal.writeBytes(bytes);

      if (sukses) {
        tampilkanNotifikasiSukses(
          'Struk Dicetak',
          'Struk ${transaksi.nomorStruk} berhasil dikirim ke printer.',
        );
      } else {
        tampilkanNotifikasiGagal(
          'Gagal Mencetak',
          'Printer tidak merespons. Periksa kertas dan koneksi Bluetooth.',
        );
      }
      return sukses;
    } catch (_) {
      tampilkanNotifikasiGagal(
        'Gagal Mencetak',
        'Terjadi kesalahan saat mencetak struk.',
      );
      return false;
    } finally {
      sedangMencetak.value = false;
    }
  }
}
