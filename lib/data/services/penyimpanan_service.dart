import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobiledev/data/models/kategori_model.dart';
import 'package:mobiledev/data/models/pengguna_model.dart';
import 'package:mobiledev/data/models/pesanan_tersimpan_model.dart';
import 'package:mobiledev/data/models/produk_model.dart';
import 'package:mobiledev/data/models/topping_model.dart';
import 'package:mobiledev/data/models/transaksi_model.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PenyimpananService extends GetxService {
  static const String _namaKotak = 'kasir_lokal';
  static int _penghitungId = 0;

  static const String _kunciPengguna = 'daftar_pengguna';
  static const String _kunciSesi = 'sesi_pengguna';
  static const String _kunciKategori = 'daftar_kategori';
  static const String _kunciTopping = 'daftar_topping';
  static const String _kunciProduk = 'daftar_produk';
  static const String _kunciTransaksi = 'daftar_transaksi';
  static const String _kunciPesananTersimpan = 'daftar_pesanan_tersimpan';
  static const String _kunciSudahInisialisasi = 'sudah_inisialisasi_awal';

  static String buatIdUnik(String awalan) {
    _penghitungId += 1;
    return '${awalan}_${DateTime.now().microsecondsSinceEpoch}_$_penghitungId';
  }

  late final GetStorage _kotak;
  String _direktoriDokumen = '';

  String get direktoriDokumen => _direktoriDokumen;

  Future<PenyimpananService> inisialisasi() async {
    await GetStorage.init(_namaKotak);
    _kotak = GetStorage(_namaKotak);

    if (!kIsWeb) {
      final direktori = await getApplicationDocumentsDirectory();
      _direktoriDokumen = direktori.path;
      final folderFoto = Directory(p.join(_direktoriDokumen, 'foto_produk'));
      if (!await folderFoto.exists()) {
        await folderFoto.create(recursive: true);
      }
    }

    await _isiDataAwalJikaKosong();
    return this;
  }

  Future<void> _isiDataAwalJikaKosong() async {
    final sudahAda = _kotak.read<bool>(_kunciSudahInisialisasi) ?? false;
    if (sudahAda) return;

    final kategoriAwal = [
      KategoriModel(
        id: 'kat_1',
        nama: 'Minuman',
        keterangan: 'Kopi, teh, dan minuman segar',
      ),
      KategoriModel(
        id: 'kat_2',
        nama: 'Makanan',
        keterangan: 'Roti, kue, dan camilan',
      ),
    ];

    final toppingAwal = [
      ToppingModel(
        id: 'top_1',
        nama: 'Boba Mutiara',
        hargaTambahan: 4000,
        stok: 25,
      ),
      ToppingModel(
        id: 'top_2',
        nama: 'Keju Parut',
        hargaTambahan: 5000,
        stok: 20,
      ),
      ToppingModel(
        id: 'top_3',
        nama: 'Ekstra Espresso',
        hargaTambahan: 6000,
        stok: 30,
      ),
    ];

    final produkAwal = [
      ProdukModel(
        id: 'prd_1',
        nama: 'Es Kopi Susu Gula Aren',
        idKategori: 'kat_1',
        harga: 18000,
        stok: 20,
        daftarIdTopping: ['top_1', 'top_3'],
      ),
      ProdukModel(
        id: 'prd_2',
        nama: 'Matcha Latte Dingin',
        idKategori: 'kat_1',
        harga: 22000,
        stok: 15,
        daftarIdTopping: ['top_1', 'top_2'],
      ),
      ProdukModel(
        id: 'prd_3',
        nama: 'Roti Bakar Cokelat',
        idKategori: 'kat_2',
        harga: 15000,
        stok: 12,
        daftarIdTopping: ['top_2'],
      ),
    ];

    await simpanDaftarKategori(kategoriAwal);
    await simpanDaftarTopping(toppingAwal);
    await simpanDaftarProduk(produkAwal);
    await _kotak.write(_kunciSudahInisialisasi, true);
  }

  List<PenggunaModel> ambilDaftarPengguna() {
    final mentah = _kotak.read<List>(_kunciPengguna) ?? [];
    return mentah
        .map((e) => PenggunaModel.dariMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> simpanDaftarPengguna(List<PenggunaModel> daftar) async {
    await _kotak.write(_kunciPengguna, daftar.map((e) => e.keMap()).toList());
  }

  PenggunaModel? ambilSesiPengguna() {
    final mentah = _kotak.read<Map>(_kunciSesi);
    if (mentah == null) return null;
    return PenggunaModel.dariMap(Map<String, dynamic>.from(mentah));
  }

  Future<void> simpanSesiPengguna(PenggunaModel? pengguna) async {
    if (pengguna == null) {
      await _kotak.remove(_kunciSesi);
    } else {
      await _kotak.write(_kunciSesi, pengguna.keMap());
    }
  }

  List<KategoriModel> ambilDaftarKategori() {
    final mentah = _kotak.read<List>(_kunciKategori) ?? [];
    return mentah
        .map((e) => KategoriModel.dariMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> simpanDaftarKategori(List<KategoriModel> daftar) async {
    await _kotak.write(_kunciKategori, daftar.map((e) => e.keMap()).toList());
  }

  List<ToppingModel> ambilDaftarTopping() {
    final mentah = _kotak.read<List>(_kunciTopping) ?? [];
    return mentah
        .map((e) => ToppingModel.dariMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> simpanDaftarTopping(List<ToppingModel> daftar) async {
    await _kotak.write(_kunciTopping, daftar.map((e) => e.keMap()).toList());
  }

  List<ProdukModel> ambilDaftarProduk() {
    final mentah = _kotak.read<List>(_kunciProduk) ?? [];
    return mentah
        .map((e) => ProdukModel.dariMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> simpanDaftarProduk(List<ProdukModel> daftar) async {
    await _kotak.write(_kunciProduk, daftar.map((e) => e.keMap()).toList());
  }

  List<TransaksiModel> ambilDaftarTransaksi() {
    final mentah = _kotak.read<List>(_kunciTransaksi) ?? [];
    return mentah
        .map((e) => TransaksiModel.dariMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> simpanDaftarTransaksi(List<TransaksiModel> daftar) async {
    await _kotak.write(_kunciTransaksi, daftar.map((e) => e.keMap()).toList());
  }

  List<PesananTersimpanModel> ambilDaftarPesananTersimpan() {
    final mentah = _kotak.read<List>(_kunciPesananTersimpan) ?? [];
    return mentah
        .map((e) => PesananTersimpanModel.dariMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> simpanDaftarPesananTersimpan(
    List<PesananTersimpanModel> daftar,
  ) async {
    await _kotak.write(
      _kunciPesananTersimpan,
      daftar.map((e) => e.keMap()).toList(),
    );
  }
}
