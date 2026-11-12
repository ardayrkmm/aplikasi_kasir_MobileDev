import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobiledev/controllers/autentikasi_controller.dart';
import 'package:mobiledev/controllers/laporan_controller.dart';
import 'package:mobiledev/controllers/master_data_controller.dart';
import 'package:mobiledev/data/models/pesanan_tersimpan_model.dart';
import 'package:mobiledev/data/models/produk_model.dart';
import 'package:mobiledev/data/models/topping_model.dart';
import 'package:mobiledev/data/models/transaksi_model.dart';
import 'package:mobiledev/data/services/penyimpanan_service.dart';
import 'package:mobiledev/utils/format_uang.dart';
import 'package:mobiledev/utils/notifikasi_helper.dart';

class TransaksiController extends GetxController {
  final MasterDataController _masterData = Get.find<MasterDataController>();
  final AutentikasiController _autentikasi = Get.find<AutentikasiController>();
  final LaporanController _laporan = Get.find<LaporanController>();
  final PenyimpananService _penyimpanan = Get.find<PenyimpananService>();

  final RxString kataKunciPencarian = ''.obs;
  final RxString idKategoriTerpilih = 'semua'.obs;
  final RxList<ItemKeranjang> keranjang = <ItemKeranjang>[].obs;
  final RxList<PesananTersimpanModel> daftarPesananTersimpan =
      <PesananTersimpanModel>[].obs;

  final RxString jenisDiskon = 'nominal'.obs;
  final RxDouble nilaiDiskonInput = 0.0.obs;
  final RxString pesanPeringatanDiskon = ''.obs;
  final RxInt uangDiterima = 0.obs;

  final TextEditingController pengontrolDiskon = TextEditingController();
  final TextEditingController pengontrolUang = TextEditingController();
  final TextEditingController pengontrolCatatanBill = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    muatPesananTersimpan();
  }

  void muatPesananTersimpan() {
    final daftar = _penyimpanan.ambilDaftarPesananTersimpan()
      ..sort((a, b) => b.waktuSimpan.compareTo(a.waktuSimpan));
    daftarPesananTersimpan.assignAll(daftar);
  }

  void _tampilkanPeringatan(String judul, String pesan) {
    tampilkanNotifikasiPeringatan(judul, pesan);
  }

  List<ProdukModel> get daftarProdukTersaring {
    final kataKunci = kataKunciPencarian.value.trim().toLowerCase();
    final idKategori = idKategoriTerpilih.value;

    return _masterData.daftarProduk.where((produk) {
      final cocokKategori =
          idKategori == 'semua' || produk.idKategori == idKategori;
      final cocokNama =
          kataKunci.isEmpty || produk.nama.toLowerCase().contains(kataKunci);
      return cocokKategori && cocokNama;
    }).toList();
  }

  int get totalJumlahItemKeranjang {
    return keranjang.fold(0, (total, item) => total + item.jumlah);
  }

  int get subtotalKeranjang {
    return keranjang.fold(0, (total, item) => total + item.totalHargaItem);
  }

  int get potonganDiskon {
    final subtotal = subtotalKeranjang;
    if (subtotal <= 0 || nilaiDiskonInput.value <= 0) return 0;

    if (jenisDiskon.value == 'persen') {
      final persenValid = nilaiDiskonInput.value.clamp(0.0, 100.0);
      return (subtotal * (persenValid / 100.0)).round().clamp(0, subtotal);
    } else {
      return nilaiDiskonInput.value.round().clamp(0, subtotal);
    }
  }

  int get totalTagihan {
    return (subtotalKeranjang - potonganDiskon).clamp(0, subtotalKeranjang);
  }

  int get uangKembalian {
    return uangDiterima.value - totalTagihan;
  }

  int hitungPemakaianProdukDiKeranjang(String idProduk) {
    return keranjang
        .where((item) => item.produk.id == idProduk)
        .fold(0, (total, item) => total + item.jumlah);
  }

  int hitungPemakaianToppingDiKeranjang(String idTopping) {
    var total = 0;
    for (final item in keranjang) {
      final memakaiTopping = item.daftarToppingTerpilih.any(
        (t) => t.id == idTopping,
      );
      if (memakaiTopping) {
        total += item.jumlah;
      }
    }
    return total;
  }

  int sisaStokProdukTersedia(ProdukModel produk) {
    final produkTerbaru =
        _masterData.daftarProduk.firstWhereOrNull((p) => p.id == produk.id) ??
        produk;
    final terpakai = hitungPemakaianProdukDiKeranjang(produkTerbaru.id);
    return (produkTerbaru.stok - terpakai).clamp(0, produkTerbaru.stok);
  }

  int sisaStokToppingTersedia(ToppingModel topping) {
    final toppingTerbaru =
        _masterData.daftarTopping.firstWhereOrNull((t) => t.id == topping.id) ??
        topping;
    final terpakai = hitungPemakaianToppingDiKeranjang(toppingTerbaru.id);
    return (toppingTerbaru.stok - terpakai).clamp(0, toppingTerbaru.stok);
  }

  bool _validasiPenambahanStok({
    required ProdukModel produk,
    required List<ToppingModel> daftarTopping,
    required int jumlahTambahan,
  }) {
    if (jumlahTambahan <= 0) return false;

    final produkTerbaru =
        _masterData.daftarProduk.firstWhereOrNull((p) => p.id == produk.id) ??
        produk;

    final pemakaianProdukSaatIni = hitungPemakaianProdukDiKeranjang(
      produkTerbaru.id,
    );
    if (pemakaianProdukSaatIni + jumlahTambahan > produkTerbaru.stok) {
      final sisa = (produkTerbaru.stok - pemakaianProdukSaatIni).clamp(
        0,
        produkTerbaru.stok,
      );
      _tampilkanPeringatan(
        'Stok Produk Tidak Cukup',
        'Stok "${produkTerbaru.nama}" total ${produkTerbaru.stok} (sudah terpakai $pemakaianProdukSaatIni di keranjang, sisa $sisa).',
      );
      return false;
    }

    for (final topping in daftarTopping) {
      final toppingTerbaru =
          _masterData.daftarTopping.firstWhereOrNull(
            (t) => t.id == topping.id,
          ) ??
          topping;
      final pemakaianTopping = hitungPemakaianToppingDiKeranjang(
        toppingTerbaru.id,
      );
      if (pemakaianTopping + jumlahTambahan > toppingTerbaru.stok) {
        final sisaTopping = (toppingTerbaru.stok - pemakaianTopping).clamp(
          0,
          toppingTerbaru.stok,
        );
        _tampilkanPeringatan(
          'Stok Add-on Tidak Cukup',
          'Stok add-on "${toppingTerbaru.nama}" total ${toppingTerbaru.stok} (sudah terpakai $pemakaianTopping di keranjang, sisa $sisaTopping).',
        );
        return false;
      }
    }

    return true;
  }

  bool tambahKeKeranjang({
    required ProdukModel produk,
    required List<ToppingModel> daftarTopping,
    int jumlah = 1,
  }) {
    final produkTerbaru =
        _masterData.daftarProduk.firstWhereOrNull((p) => p.id == produk.id) ??
        produk;

    final valid = _validasiPenambahanStok(
      produk: produkTerbaru,
      daftarTopping: daftarTopping,
      jumlahTambahan: jumlah,
    );
    if (!valid) return false;

    final itemBaru = ItemKeranjang(
      produk: produkTerbaru,
      daftarToppingTerpilih: daftarTopping,
      jumlah: jumlah,
    );

    final indeksSama = keranjang.indexWhere(
      (item) => item.kunciUnik == itemBaru.kunciUnik,
    );

    if (indeksSama != -1) {
      keranjang[indeksSama].jumlah += jumlah;
      keranjang.refresh();
    } else {
      keranjang.add(itemBaru);
    }

    _sesuaikanDiskonDenganSubtotal();
    return true;
  }

  bool ubahJumlahItem(int indeks, int perubahan) {
    if (indeks < 0 || indeks >= keranjang.length) return false;
    final item = keranjang[indeks];
    final jumlahBaru = item.jumlah + perubahan;

    if (jumlahBaru <= 0) {
      hapusItemKeranjang(indeks);
      return true;
    }

    if (perubahan > 0) {
      final valid = _validasiPenambahanStok(
        produk: item.produk,
        daftarTopping: item.daftarToppingTerpilih,
        jumlahTambahan: perubahan,
      );
      if (!valid) return false;
    }

    item.jumlah = jumlahBaru;
    keranjang.refresh();
    _sesuaikanDiskonDenganSubtotal();
    return true;
  }

  void hapusItemKeranjang(int indeks) {
    if (indeks >= 0 && indeks < keranjang.length) {
      keranjang.removeAt(indeks);
      _sesuaikanDiskonDenganSubtotal();
    }
  }

  void kosongkanKeranjang() {
    keranjang.clear();
    jenisDiskon.value = 'nominal';
    nilaiDiskonInput.value = 0.0;
    pesanPeringatanDiskon.value = '';
    uangDiterima.value = 0;
    pengontrolDiskon.clear();
    pengontrolUang.clear();
  }

  void aturDiskon(String jenis, double nilai) {
    jenisDiskon.value = jenis;
    if (nilai <= 0) {
      nilaiDiskonInput.value = 0.0;
      pesanPeringatanDiskon.value = '';
      return;
    }

    if (jenis == 'persen') {
      if (nilai > 100) {
        nilaiDiskonInput.value = 100.0;
        pesanPeringatanDiskon.value =
            'Diskon persen maksimal 100%. Otomatis dibatasi ke 100%.';
      } else {
        nilaiDiskonInput.value = nilai;
        pesanPeringatanDiskon.value = '';
      }
    } else {
      final subtotal = subtotalKeranjang;
      if (nilai > subtotal) {
        nilaiDiskonInput.value = subtotal.toDouble();
        pesanPeringatanDiskon.value =
            'Diskon nominal tidak boleh melebihi subtotal (${formatRupiah(subtotal)}).';
      } else {
        nilaiDiskonInput.value = nilai;
        pesanPeringatanDiskon.value = '';
      }
    }
  }

  void ubahJenisDiskon(String jenisBaru) {
    pengontrolDiskon.clear();
    aturDiskon(jenisBaru, 0);
  }

  void ubahNilaiDiskonDariTeks(String teks) {
    final nilai = double.tryParse(teks) ?? 0;
    aturDiskon(jenisDiskon.value, nilai);
    if (nilai > nilaiDiskonInput.value) {
      sinkronkanTeksDiskon();
    }
  }

  void sinkronkanTeksDiskon() {
    final nilaiTersimpan = nilaiDiskonInput.value.round();
    final teksSaatIni = pengontrolDiskon.text.trim();
    if (nilaiTersimpan <= 0 && teksSaatIni.isNotEmpty) {
      pengontrolDiskon.clear();
    } else if (nilaiTersimpan > 0 && teksSaatIni != nilaiTersimpan.toString()) {
      final teksBaru = nilaiTersimpan.toString();
      pengontrolDiskon.value = TextEditingValue(
        text: teksBaru,
        selection: TextSelection.collapsed(offset: teksBaru.length),
      );
    }
  }

  void _sesuaikanDiskonDenganSubtotal() {
    if (jenisDiskon.value == 'nominal') {
      final subtotal = subtotalKeranjang;
      if (nilaiDiskonInput.value > subtotal) {
        nilaiDiskonInput.value = subtotal.toDouble();
        pesanPeringatanDiskon.value = subtotal > 0
            ? 'Diskon disesuaikan ke subtotal (${formatRupiah(subtotal)}).'
            : '';
      }
    }
    sinkronkanTeksDiskon();
  }

  void aturUangDiterima(int nominal) {
    uangDiterima.value = nominal < 0 ? 0 : nominal;
  }

  void aturNominalCepat(int nominal) {
    final nilaiValid = nominal < 0 ? 0 : nominal;
    uangDiterima.value = nilaiValid;
    final teksBaru = nilaiValid.toString();
    pengontrolUang.value = TextEditingValue(
      text: teksBaru,
      selection: TextSelection.collapsed(offset: teksBaru.length),
    );
  }

  bool _validasiUlangStokSebelumBayar() {
    final pemakaianProduk = <String, int>{};
    final pemakaianTopping = <String, int>{};

    for (final item in keranjang) {
      pemakaianProduk[item.produk.id] =
          (pemakaianProduk[item.produk.id] ?? 0) + item.jumlah;
      for (final topping in item.daftarToppingTerpilih) {
        pemakaianTopping[topping.id] =
            (pemakaianTopping[topping.id] ?? 0) + item.jumlah;
      }
    }

    for (final entri in pemakaianProduk.entries) {
      final produkMaster = _masterData.daftarProduk.firstWhereOrNull(
        (p) => p.id == entri.key,
      );
      if (produkMaster == null || entri.value > produkMaster.stok) {
        _tampilkanPeringatan(
          'Stok Tidak Mencukupi',
          'Total pemakaian produk "${produkMaster?.nama ?? 'Produk'}" (${entri.value}) melebihi stok tersisa (${produkMaster?.stok ?? 0}).',
        );
        return false;
      }
    }

    for (final entri in pemakaianTopping.entries) {
      final toppingMaster = _masterData.daftarTopping.firstWhereOrNull(
        (t) => t.id == entri.key,
      );
      if (toppingMaster == null || entri.value > toppingMaster.stok) {
        _tampilkanPeringatan(
          'Stok Add-on Tidak Mencukupi',
          'Total pemakaian add-on "${toppingMaster?.nama ?? 'Add-on'}" (${entri.value}) melebihi stok tersisa (${toppingMaster?.stok ?? 0}).',
        );
        return false;
      }
    }

    return true;
  }

  Future<TransaksiModel?> prosesPembayaran() async {
    if (keranjang.isEmpty) {
      _tampilkanPeringatan(
        'Keranjang Kosong',
        'Tambahkan produk terlebih dahulu sebelum membayar.',
      );
      return null;
    }

    if (!_validasiUlangStokSebelumBayar()) {
      return null;
    }

    _sesuaikanDiskonDenganSubtotal();
    final totalValid = totalTagihan;

    if (uangDiterima.value < totalValid) {
      _tampilkanPeringatan(
        'Pembayaran Kurang',
        'Uang diterima masih kurang dari total tagihan.',
      );
      return null;
    }

    final sekarang = DateTime.now();
    final penggunaAktif = _autentikasi.sesiPengguna.value;
    final nomorUrut = (_laporan.daftarTransaksi.length + 1).toString().padLeft(
      3,
      '0',
    );
    final nomorStruk =
        'TRX-${sekarang.year}${sekarang.month.toString().padLeft(2, '0')}${sekarang.day.toString().padLeft(2, '0')}-$nomorUrut';

    final daftarItemTersimpan = keranjang.map((item) {
      final produkTerbaru =
          _masterData.daftarProduk.firstWhereOrNull(
            (p) => p.id == item.produk.id,
          ) ??
          item.produk;

      final daftarToppingSnapshot = item.daftarToppingTerpilih.map((t) {
        final toppingTerbaru =
            _masterData.daftarTopping.firstWhereOrNull((m) => m.id == t.id) ??
            t;
        return ToppingTersimpanModel(
          idTopping: toppingTerbaru.id,
          nama: toppingTerbaru.nama,
          hargaTambahan: toppingTerbaru.hargaTambahan,
        );
      }).toList();

      final totalTopping = daftarToppingSnapshot.fold(
        0,
        (total, t) => total + t.hargaTambahan,
      );
      final totalHargaSnapshot =
          (produkTerbaru.harga + totalTopping) * item.jumlah;

      return ItemTransaksiModel(
        idProduk: produkTerbaru.id,
        namaProduk: produkTerbaru.nama,
        hargaProduk: produkTerbaru.harga,
        jumlah: item.jumlah,
        daftarTopping: daftarToppingSnapshot,
        totalHargaItem: totalHargaSnapshot,
      );
    }).toList();

    final subtotalSnapshot = daftarItemTersimpan.fold(
      0,
      (total, item) => total + item.totalHargaItem,
    );

    final potonganValid = jenisDiskon.value == 'persen'
        ? (subtotalSnapshot *
                  (nilaiDiskonInput.value.clamp(0.0, 100.0) / 100.0))
              .round()
              .clamp(0, subtotalSnapshot)
        : nilaiDiskonInput.value.round().clamp(0, subtotalSnapshot);

    final totalAkhirValid = (subtotalSnapshot - potonganValid).clamp(
      0,
      subtotalSnapshot,
    );

    if (uangDiterima.value < totalAkhirValid) {
      _tampilkanPeringatan(
        'Pembayaran Kurang',
        'Uang diterima masih kurang dari total tagihan terbaru (${formatRupiah(totalAkhirValid)}).',
      );
      return null;
    }

    final transaksiBaru = TransaksiModel(
      id: PenyimpananService.buatIdUnik('trx'),
      nomorStruk: nomorStruk,
      waktu: sekarang,
      namaToko: 'Aplikasi Kasir',
      namaKasir: penggunaAktif?.nama ?? 'Kasir',
      daftarItem: daftarItemTersimpan,
      subtotal: subtotalSnapshot,
      jenisDiskon: jenisDiskon.value,
      nilaiDiskonInput: jenisDiskon.value == 'persen'
          ? nilaiDiskonInput.value.clamp(0.0, 100.0)
          : nilaiDiskonInput.value.clamp(0.0, subtotalSnapshot.toDouble()),
      potonganDiskon: potonganValid,
      totalAkhir: totalAkhirValid,
      uangDiterima: uangDiterima.value,
      uangKembalian: uangDiterima.value - totalAkhirValid,
    );

    await _masterData.kurangiStokSetelahTransaksi(keranjang.toList());
    await _laporan.tambahTransaksi(transaksiBaru);
    kosongkanKeranjang();

    return transaksiBaru;
  }

  Future<bool> simpanPesananSementara(String catatan) async {
    if (keranjang.isEmpty) {
      _tampilkanPeringatan(
        'Keranjang Kosong',
        'Tambahkan produk terlebih dahulu sebelum menyimpan pesanan.',
      );
      return false;
    }

    final sekarang = DateTime.now();
    final namaTagihan = catatan.trim().isEmpty
        ? 'Bill #${daftarPesananTersimpan.length + 1}'
        : catatan.trim();

    final daftarItem = keranjang.map((item) {
      return ItemPesananTersimpanModel(
        idProduk: item.produk.id,
        namaProduk: item.produk.nama,
        hargaProduk: item.produk.harga,
        jumlah: item.jumlah,
        daftarTopping: item.daftarToppingTerpilih
            .map(
              (t) => ToppingTersimpanModel(
                idTopping: t.id,
                nama: t.nama,
                hargaTambahan: t.hargaTambahan,
              ),
            )
            .toList(),
        totalHargaItem: item.totalHargaItem,
      );
    }).toList();

    final pesananBaru = PesananTersimpanModel(
      id: PenyimpananService.buatIdUnik('bill'),
      namaTagihan: namaTagihan,
      waktuSimpan: sekarang,
      daftarItem: daftarItem,
      jenisDiskon: jenisDiskon.value,
      nilaiDiskonInput: nilaiDiskonInput.value,
      subtotal: subtotalKeranjang,
    );

    daftarPesananTersimpan.insert(0, pesananBaru);
    await _penyimpanan.simpanDaftarPesananTersimpan(daftarPesananTersimpan);
    kosongkanKeranjang();
    pengontrolCatatanBill.clear();

    tampilkanNotifikasiSukses(
      'Bill Disimpan',
      'Pesanan "$namaTagihan" berhasil disimpan sementara.',
    );
    return true;
  }

  Future<bool> lanjutkanPesananTersimpan(PesananTersimpanModel pesanan) async {
    kosongkanKeranjang();
    var adaItemGagal = false;

    for (final item in pesanan.daftarItem) {
      final produkMaster = _masterData.daftarProduk.firstWhereOrNull(
        (p) => p.id == item.idProduk,
      );
      if (produkMaster == null || produkMaster.stok <= 0) {
        adaItemGagal = true;
        continue;
      }

      final daftarToppingValid = <ToppingModel>[];
      var toppingTersedia = true;
      for (final topTersimpan in item.daftarTopping) {
        final topMaster = _masterData.daftarTopping.firstWhereOrNull(
          (t) => t.id == topTersimpan.idTopping,
        );
        if (topMaster == null || topMaster.stok <= 0) {
          toppingTersedia = false;
          break;
        }
        daftarToppingValid.add(topMaster);
      }

      if (!toppingTersedia) {
        adaItemGagal = true;
        continue;
      }

      final sukses = tambahKeKeranjang(
        produk: produkMaster,
        daftarTopping: daftarToppingValid,
        jumlah: item.jumlah,
      );
      if (!sukses) {
        adaItemGagal = true;
      }
    }

    if (pesanan.nilaiDiskonInput > 0) {
      aturDiskon(pesanan.jenisDiskon, pesanan.nilaiDiskonInput);
      sinkronkanTeksDiskon();
    }

    daftarPesananTersimpan.removeWhere((p) => p.id == pesanan.id);
    await _penyimpanan.simpanDaftarPesananTersimpan(daftarPesananTersimpan);

    if (adaItemGagal) {
      tampilkanNotifikasiPeringatan(
        'Sebagian Item Menyesuaikan Stok',
        'Beberapa item pada bill "${pesanan.namaTagihan}" tidak dapat dimuat karena stok berubah atau produk dihapus.',
      );
    } else {
      tampilkanNotifikasiSukses(
        'Bill Dilanjutkan',
        'Pesanan "${pesanan.namaTagihan}" berhasil dimuat kembali ke keranjang.',
      );
    }

    return keranjang.isNotEmpty;
  }

  Future<void> hapusPesananTersimpan(String id) async {
    daftarPesananTersimpan.removeWhere((p) => p.id == id);
    await _penyimpanan.simpanDaftarPesananTersimpan(daftarPesananTersimpan);
  }

  @override
  void onClose() {
    pengontrolDiskon.dispose();
    pengontrolUang.dispose();
    pengontrolCatatanBill.dispose();
    super.onClose();
  }
}
