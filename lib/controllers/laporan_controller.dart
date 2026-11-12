import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobiledev/data/models/transaksi_model.dart';
import 'package:mobiledev/data/services/penyimpanan_service.dart';

class DataGrafikHarian {
  final String labelTanggal;
  final DateTime tanggal;
  final int totalPendapatan;
  final int jumlahTransaksi;

  DataGrafikHarian({
    required this.labelTanggal,
    required this.tanggal,
    required this.totalPendapatan,
    required this.jumlahTransaksi,
  });
}

class DataProdukTerlaris {
  final String namaProduk;
  final int jumlahTerjual;
  final int totalOmzet;

  DataProdukTerlaris({
    required this.namaProduk,
    required this.jumlahTerjual,
    required this.totalOmzet,
  });
}

class LaporanController extends GetxController {
  final PenyimpananService _penyimpanan = Get.find<PenyimpananService>();

  final RxList<TransaksiModel> daftarTransaksi = <TransaksiModel>[].obs;
  final RxString filterPeriode = 'semua'.obs;
  final Rxn<DateTimeRange> rentangTanggalKustom = Rxn<DateTimeRange>();
  final RxInt indeksBatangTerpilih = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    muatRiwayatTransaksi();
  }

  void muatRiwayatTransaksi() {
    final data = _penyimpanan.ambilDaftarTransaksi();
    data.sort((a, b) => b.waktu.compareTo(a.waktu));
    daftarTransaksi.assignAll(data);
  }

  void aturFilterPeriode(String periode) {
    filterPeriode.value = periode;
    indeksBatangTerpilih.value = -1;
  }

  void aturRentangKustom(DateTimeRange rentang) {
    rentangTanggalKustom.value = rentang;
    filterPeriode.value = 'kustom';
    indeksBatangTerpilih.value = -1;
  }

  void pilihBatangGrafik(int indeks) {
    if (indeksBatangTerpilih.value == indeks) {
      indeksBatangTerpilih.value = -1;
    } else {
      indeksBatangTerpilih.value = indeks;
    }
  }

  List<TransaksiModel> get daftarTransaksiTersaring {
    final periode = filterPeriode.value;
    if (periode == 'semua') {
      return daftarTransaksi.toList();
    }

    final sekarang = DateTime.now();
    final awalHariIni = DateTime(sekarang.year, sekarang.month, sekarang.day);

    return daftarTransaksi.where((trx) {
      final tanggalTrx = DateTime(
        trx.waktu.year,
        trx.waktu.month,
        trx.waktu.day,
      );

      if (periode == 'hari_ini') {
        return tanggalTrx.isAtSameMomentAs(awalHariIni);
      } else if (periode == '7_hari') {
        final batas = awalHariIni.subtract(const Duration(days: 6));
        return !tanggalTrx.isBefore(batas) && !tanggalTrx.isAfter(awalHariIni);
      } else if (periode == '30_hari') {
        final batas = awalHariIni.subtract(const Duration(days: 29));
        return !tanggalTrx.isBefore(batas) && !tanggalTrx.isAfter(awalHariIni);
      } else if (periode == 'kustom' && rentangTanggalKustom.value != null) {
        final mulai = DateTime(
          rentangTanggalKustom.value!.start.year,
          rentangTanggalKustom.value!.start.month,
          rentangTanggalKustom.value!.start.day,
        );
        final selesai = DateTime(
          rentangTanggalKustom.value!.end.year,
          rentangTanggalKustom.value!.end.month,
          rentangTanggalKustom.value!.end.day,
        );
        return !tanggalTrx.isBefore(mulai) && !tanggalTrx.isAfter(selesai);
      }

      return true;
    }).toList();
  }

  int get totalPendapatan {
    return daftarTransaksiTersaring.fold(
      0,
      (total, trx) => total + trx.totalAkhir,
    );
  }

  int get totalPendapatanKotor {
    return daftarTransaksiTersaring.fold(
      0,
      (total, trx) => total + trx.subtotal,
    );
  }

  int get totalDiskonDiberikan {
    return daftarTransaksiTersaring.fold(
      0,
      (total, trx) => total + trx.potonganDiskon,
    );
  }

  int get jumlahTransaksiSukses => daftarTransaksiTersaring.length;

  int get rataRataTransaksi {
    if (jumlahTransaksiSukses == 0) return 0;
    return (totalPendapatan / jumlahTransaksiSukses).round();
  }

  int get totalProdukTerjual {
    var total = 0;
    for (final trx in daftarTransaksiTersaring) {
      for (final item in trx.daftarItem) {
        total += item.jumlah;
      }
    }
    return total;
  }

  List<DataGrafikHarian> get dataGrafikPenjualan {
    final petaHarian = <String, DataGrafikHarian>{};

    for (final trx in daftarTransaksiTersaring) {
      final tgl = DateTime(trx.waktu.year, trx.waktu.month, trx.waktu.day);
      final kunci =
          '${tgl.year}-${tgl.month.toString().padLeft(2, '0')}-${tgl.day.toString().padLeft(2, '0')}';
      final label =
          '${tgl.day.toString().padLeft(2, '0')}/${tgl.month.toString().padLeft(2, '0')}';

      final lama = petaHarian[kunci];
      if (lama == null) {
        petaHarian[kunci] = DataGrafikHarian(
          labelTanggal: label,
          tanggal: tgl,
          totalPendapatan: trx.totalAkhir,
          jumlahTransaksi: 1,
        );
      } else {
        petaHarian[kunci] = DataGrafikHarian(
          labelTanggal: label,
          tanggal: tgl,
          totalPendapatan: lama.totalPendapatan + trx.totalAkhir,
          jumlahTransaksi: lama.jumlahTransaksi + 1,
        );
      }
    }

    final hasil = petaHarian.values.toList()
      ..sort((a, b) => a.tanggal.compareTo(b.tanggal));

    if (hasil.length > 10) {
      return hasil.sublist(hasil.length - 10);
    }
    return hasil;
  }

  List<DataProdukTerlaris> get daftarProdukTerlaris {
    final petaProduk = <String, DataProdukTerlaris>{};

    for (final trx in daftarTransaksiTersaring) {
      for (final item in trx.daftarItem) {
        final lama = petaProduk[item.namaProduk];
        if (lama == null) {
          petaProduk[item.namaProduk] = DataProdukTerlaris(
            namaProduk: item.namaProduk,
            jumlahTerjual: item.jumlah,
            totalOmzet: item.totalHargaItem,
          );
        } else {
          petaProduk[item.namaProduk] = DataProdukTerlaris(
            namaProduk: item.namaProduk,
            jumlahTerjual: lama.jumlahTerjual + item.jumlah,
            totalOmzet: lama.totalOmzet + item.totalHargaItem,
          );
        }
      }
    }

    final hasil = petaProduk.values.toList()
      ..sort((a, b) => b.jumlahTerjual.compareTo(a.jumlahTerjual));

    if (hasil.length > 5) {
      return hasil.sublist(0, 5);
    }
    return hasil;
  }

  Future<void> tambahTransaksi(TransaksiModel transaksi) async {
    daftarTransaksi.insert(0, transaksi);
    await _penyimpanan.simpanDaftarTransaksi(daftarTransaksi);
  }
}
