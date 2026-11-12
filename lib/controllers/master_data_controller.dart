import 'package:get/get.dart';
import 'package:mobiledev/data/models/kategori_model.dart';
import 'package:mobiledev/data/models/produk_model.dart';
import 'package:mobiledev/data/models/topping_model.dart';
import 'package:mobiledev/data/models/transaksi_model.dart';
import 'package:mobiledev/data/services/penyimpanan_service.dart';
import 'package:mobiledev/utils/notifikasi_helper.dart';
import 'package:mobiledev/utils/penyimpanan_foto.dart';

class MasterDataController extends GetxController {
  static const int batasStokMenipis = 5;

  final PenyimpananService _penyimpanan = Get.find<PenyimpananService>();

  final RxList<KategoriModel> daftarKategori = <KategoriModel>[].obs;
  final RxList<ToppingModel> daftarTopping = <ToppingModel>[].obs;
  final RxList<ProdukModel> daftarProduk = <ProdukModel>[].obs;

  List<ProdukModel> get daftarProdukStokMenipis {
    return daftarProduk
        .where((p) => p.stok > 0 && p.stok <= batasStokMenipis)
        .toList();
  }

  List<ProdukModel> get daftarProdukStokHabis {
    return daftarProduk.where((p) => p.stok <= 0).toList();
  }

  List<ToppingModel> get daftarToppingStokMenipis {
    return daftarTopping
        .where((t) => t.stok > 0 && t.stok <= batasStokMenipis)
        .toList();
  }

  bool apakahStokMenipis(int stok) => stok > 0 && stok <= batasStokMenipis;

  @override
  void onInit() {
    super.onInit();
    muatSemuaData();
  }

  void muatSemuaData() {
    daftarKategori.assignAll(_penyimpanan.ambilDaftarKategori());
    daftarTopping.assignAll(_penyimpanan.ambilDaftarTopping());
    daftarProduk.assignAll(_penyimpanan.ambilDaftarProduk());
  }

  Future<void> tambahKategori({
    required String nama,
    String keterangan = '',
  }) async {
    final kategoriBaru = KategoriModel(
      id: PenyimpananService.buatIdUnik('kat'),
      nama: nama.trim(),
      keterangan: keterangan.trim(),
    );
    daftarKategori.add(kategoriBaru);
    await _penyimpanan.simpanDaftarKategori(daftarKategori);
  }

  Future<void> ubahKategori({
    required String id,
    required String nama,
    String keterangan = '',
  }) async {
    final indeks = daftarKategori.indexWhere((k) => k.id == id);
    if (indeks != -1) {
      daftarKategori[indeks] = daftarKategori[indeks].salinDengan(
        nama: nama.trim(),
        keterangan: keterangan.trim(),
      );
      await _penyimpanan.simpanDaftarKategori(daftarKategori);
    }
  }

  Future<bool> hapusKategori(String id) async {
    final dipakaiProduk = daftarProduk.any((p) => p.idKategori == id);
    if (dipakaiProduk) {
      tampilkanNotifikasiPeringatan(
        'Tidak Bisa Dihapus',
        'Kategori ini masih digunakan oleh produk yang aktif.',
      );
      return false;
    }
    daftarKategori.removeWhere((k) => k.id == id);
    await _penyimpanan.simpanDaftarKategori(daftarKategori);
    return true;
  }

  String ambilNamaKategori(String idKategori) {
    final kategori = daftarKategori.firstWhereOrNull((k) => k.id == idKategori);
    return kategori?.nama ?? 'Tanpa Kategori';
  }

  Future<void> tambahTopping({
    required String nama,
    required int hargaTambahan,
    required int stok,
  }) async {
    final toppingBaru = ToppingModel(
      id: PenyimpananService.buatIdUnik('top'),
      nama: nama.trim(),
      hargaTambahan: hargaTambahan,
      stok: stok,
    );
    daftarTopping.add(toppingBaru);
    await _penyimpanan.simpanDaftarTopping(daftarTopping);
  }

  Future<void> ubahTopping({
    required String id,
    required String nama,
    required int hargaTambahan,
    required int stok,
  }) async {
    final indeks = daftarTopping.indexWhere((t) => t.id == id);
    if (indeks != -1) {
      daftarTopping[indeks] = daftarTopping[indeks].salinDengan(
        nama: nama.trim(),
        hargaTambahan: hargaTambahan,
        stok: stok,
      );
      await _penyimpanan.simpanDaftarTopping(daftarTopping);
    }
  }

  Future<void> hapusTopping(String id) async {
    daftarTopping.removeWhere((t) => t.id == id);
    await _penyimpanan.simpanDaftarTopping(daftarTopping);

    var adaPerubahanProduk = false;
    for (var i = 0; i < daftarProduk.length; i++) {
      final produk = daftarProduk[i];
      if (produk.daftarIdTopping.contains(id)) {
        final daftarBaru = List<String>.from(produk.daftarIdTopping)
          ..remove(id);
        daftarProduk[i] = produk.salinDengan(daftarIdTopping: daftarBaru);
        adaPerubahanProduk = true;
      }
    }
    if (adaPerubahanProduk) {
      await _penyimpanan.simpanDaftarProduk(daftarProduk);
    }
  }

  List<ToppingModel> ambilToppingDariDaftarId(List<String> daftarId) {
    return daftarTopping.where((t) => daftarId.contains(t.id)).toList();
  }

  Future<void> tambahProduk({
    required String nama,
    required String idKategori,
    required int harga,
    required int stok,
    String? pathFoto,
    List<String> daftarIdTopping = const [],
  }) async {
    final produkBaru = ProdukModel(
      id: PenyimpananService.buatIdUnik('prd'),
      nama: nama.trim(),
      idKategori: idKategori,
      harga: harga,
      stok: stok,
      pathFoto: pathFoto,
      daftarIdTopping: daftarIdTopping,
    );
    daftarProduk.add(produkBaru);
    await _penyimpanan.simpanDaftarProduk(daftarProduk);
  }

  Future<void> ubahProduk({
    required String id,
    required String nama,
    required String idKategori,
    required int harga,
    required int stok,
    String? pathFoto,
    List<String> daftarIdTopping = const [],
  }) async {
    final indeks = daftarProduk.indexWhere((p) => p.id == id);
    if (indeks != -1) {
      final pathFotoLama = daftarProduk[indeks].pathFoto;
      daftarProduk[indeks] = ProdukModel(
        id: id,
        nama: nama.trim(),
        idKategori: idKategori,
        harga: harga,
        stok: stok,
        pathFoto: pathFoto,
        daftarIdTopping: daftarIdTopping,
      );
      await _penyimpanan.simpanDaftarProduk(daftarProduk);

      if (pathFotoLama != null && pathFotoLama != pathFoto) {
        await hapusFotoPermanen(pathFotoLama);
      }
    }
  }

  Future<void> hapusProduk(String id) async {
    final produk = daftarProduk.firstWhereOrNull((p) => p.id == id);
    daftarProduk.removeWhere((p) => p.id == id);
    await _penyimpanan.simpanDaftarProduk(daftarProduk);
    if (produk?.pathFoto != null) {
      await hapusFotoPermanen(produk!.pathFoto);
    }
  }

  Future<void> kurangiStokSetelahTransaksi(
    List<ItemKeranjang> daftarItem,
  ) async {
    for (final item in daftarItem) {
      final indeksProduk = daftarProduk.indexWhere(
        (p) => p.id == item.produk.id,
      );
      if (indeksProduk != -1) {
        final stokBaru = (daftarProduk[indeksProduk].stok - item.jumlah).clamp(
          0,
          999999,
        );
        daftarProduk[indeksProduk] = daftarProduk[indeksProduk].salinDengan(
          stok: stokBaru,
        );
      }

      for (final topping in item.daftarToppingTerpilih) {
        final indeksTopping = daftarTopping.indexWhere(
          (t) => t.id == topping.id,
        );
        if (indeksTopping != -1) {
          final stokToppingBaru =
              (daftarTopping[indeksTopping].stok - item.jumlah).clamp(
                0,
                999999,
              );
          daftarTopping[indeksTopping] = daftarTopping[indeksTopping]
              .salinDengan(stok: stokToppingBaru);
        }
      }
    }

    await _penyimpanan.simpanDaftarProduk(daftarProduk);
    await _penyimpanan.simpanDaftarTopping(daftarTopping);
  }
}
