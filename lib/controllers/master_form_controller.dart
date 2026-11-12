import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobiledev/controllers/master_data_controller.dart';
import 'package:mobiledev/data/models/kategori_model.dart';
import 'package:mobiledev/data/models/produk_model.dart';
import 'package:mobiledev/data/models/topping_model.dart';
import 'package:mobiledev/utils/notifikasi_helper.dart';
import 'package:mobiledev/utils/penyimpanan_foto.dart';

class MasterTabController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final TabController pengontrolTab;
  final RxInt indeksTabAktif = 0.obs;

  @override
  void onInit() {
    super.onInit();
    pengontrolTab = TabController(length: 3, vsync: this);
    pengontrolTab.addListener(() {
      indeksTabAktif.value = pengontrolTab.index;
    });
  }

  String get labelTombolTambah {
    switch (indeksTabAktif.value) {
      case 0:
        return 'Tambah Produk';
      case 1:
        return 'Tambah Kategori';
      default:
        return 'Tambah Add-on';
    }
  }

  @override
  void onClose() {
    pengontrolTab.dispose();
    super.onClose();
  }
}

class FormKategoriController extends GetxController {
  final KategoriModel? kategoriAwal;
  final MasterDataController _masterData = Get.find<MasterDataController>();
  final GlobalKey<FormState> formKunci = GlobalKey<FormState>();

  late final TextEditingController pengontrolNama;
  late final TextEditingController pengontrolKeterangan;

  FormKategoriController(this.kategoriAwal);

  bool get sedangUbah => kategoriAwal != null;

  @override
  void onInit() {
    super.onInit();
    pengontrolNama = TextEditingController(text: kategoriAwal?.nama ?? '');
    pengontrolKeterangan = TextEditingController(
      text: kategoriAwal?.keterangan ?? '',
    );
  }

  Future<void> simpan() async {
    if (!(formKunci.currentState?.validate() ?? false)) return;

    if (kategoriAwal == null) {
      await _masterData.tambahKategori(
        nama: pengontrolNama.text,
        keterangan: pengontrolKeterangan.text,
      );
    } else {
      await _masterData.ubahKategori(
        id: kategoriAwal!.id,
        nama: pengontrolNama.text,
        keterangan: pengontrolKeterangan.text,
      );
    }
    tutupRuteAktif();
    tampilkanNotifikasiSukses(
      'Berhasil',
      sedangUbah
          ? 'Kategori berhasil diperbarui.'
          : 'Kategori berhasil ditambahkan.',
    );
  }

  @override
  void onClose() {
    pengontrolNama.dispose();
    pengontrolKeterangan.dispose();
    super.onClose();
  }
}

class FormToppingController extends GetxController {
  final ToppingModel? toppingAwal;
  final MasterDataController _masterData = Get.find<MasterDataController>();
  final GlobalKey<FormState> formKunci = GlobalKey<FormState>();

  late final TextEditingController pengontrolNama;
  late final TextEditingController pengontrolHarga;
  late final TextEditingController pengontrolStok;

  FormToppingController(this.toppingAwal);

  bool get sedangUbah => toppingAwal != null;

  @override
  void onInit() {
    super.onInit();
    pengontrolNama = TextEditingController(text: toppingAwal?.nama ?? '');
    pengontrolHarga = TextEditingController(
      text: toppingAwal != null ? toppingAwal!.hargaTambahan.toString() : '',
    );
    pengontrolStok = TextEditingController(
      text: toppingAwal != null ? toppingAwal!.stok.toString() : '',
    );
  }

  Future<void> simpan() async {
    if (!(formKunci.currentState?.validate() ?? false)) return;

    final harga = int.tryParse(pengontrolHarga.text.trim()) ?? 0;
    final stok = int.tryParse(pengontrolStok.text.trim()) ?? 0;

    if (toppingAwal == null) {
      await _masterData.tambahTopping(
        nama: pengontrolNama.text,
        hargaTambahan: harga,
        stok: stok,
      );
    } else {
      await _masterData.ubahTopping(
        id: toppingAwal!.id,
        nama: pengontrolNama.text,
        hargaTambahan: harga,
        stok: stok,
      );
    }
    tutupRuteAktif();
    tampilkanNotifikasiSukses(
      'Berhasil',
      sedangUbah
          ? 'Add-on berhasil diperbarui.'
          : 'Add-on berhasil ditambahkan.',
    );
  }

  @override
  void onClose() {
    pengontrolNama.dispose();
    pengontrolHarga.dispose();
    pengontrolStok.dispose();
    super.onClose();
  }
}

class FormProdukController extends GetxController {
  final ProdukModel? produkAwal;
  final MasterDataController masterData = Get.find<MasterDataController>();
  final ImagePicker _pemilihGambar = ImagePicker();
  final GlobalKey<FormState> formKunci = GlobalKey<FormState>();

  late final TextEditingController pengontrolNama;
  late final TextEditingController pengontrolHarga;
  late final TextEditingController pengontrolStok;
  final TextEditingController pengontrolUrlFoto = TextEditingController();

  final RxnString idKategoriTerpilih = RxnString();
  final RxnString pathFoto = RxnString();
  final RxBool sedangMengunggahFoto = false.obs;
  final RxList<String> daftarIdToppingTerpilih = <String>[].obs;

  String? _pathFotoBaruBelumDisimpan;
  bool _sudahDisimpan = false;

  FormProdukController(this.produkAwal);

  bool get sedangUbah => produkAwal != null;

  bool get apakahMendukungKamera =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void onInit() {
    super.onInit();
    pengontrolNama = TextEditingController(text: produkAwal?.nama ?? '');
    pengontrolHarga = TextEditingController(
      text: produkAwal != null ? produkAwal!.harga.toString() : '',
    );
    pengontrolStok = TextEditingController(
      text: produkAwal != null ? produkAwal!.stok.toString() : '',
    );

    pathFoto.value = produkAwal?.pathFoto;
    daftarIdToppingTerpilih.assignAll(
      List<String>.from(produkAwal?.daftarIdTopping ?? []),
    );

    if (produkAwal != null) {
      idKategoriTerpilih.value = produkAwal!.idKategori;
    } else if (masterData.daftarKategori.isNotEmpty) {
      idKategoriTerpilih.value = masterData.daftarKategori.first.id;
    }
  }

  Future<void> ambilFoto(ImageSource sumber) async {
    if (sumber == ImageSource.camera && !apakahMendukungKamera) {
      tampilkanNotifikasiPeringatan(
        'Kamera Tidak Tersedia',
        'Gunakan menu "Pilih File / Galeri" untuk mengunggah gambar dari perangkat ini.',
      );
      return;
    }

    sedangMengunggahFoto.value = true;
    try {
      final hasilFoto = await _pemilihGambar.pickImage(
        source: sumber,
        imageQuality: 80,
        maxWidth: 800,
      );
      if (hasilFoto != null) {
        final pathPermanen = await salinFotoKePenyimpananPermanen(hasilFoto);
        if (_pathFotoBaruBelumDisimpan != null) {
          await hapusFotoPermanen(_pathFotoBaruBelumDisimpan);
        }
        pathFoto.value = pathPermanen;
        _pathFotoBaruBelumDisimpan = pathPermanen;

        tampilkanNotifikasiSukses(
          'Upload Berhasil',
          'Gambar produk berhasil diunggah dan siap disimpan.',
        );
      }
    } catch (_) {
      tampilkanNotifikasiGagal(
        'Gagal Mengunggah Gambar',
        'Tidak dapat mengakses sumber gambar di perangkat ini.',
      );
    } finally {
      sedangMengunggahFoto.value = false;
    }
  }

  bool gunakanUrlGambar(String url) {
    final urlBersih = url.trim();
    if (!urlBersih.startsWith('http://') && !urlBersih.startsWith('https://')) {
      tampilkanNotifikasiGagal(
        'URL Tidak Valid',
        'Masukkan tautan gambar yang diawali http:// atau https://',
      );
      return false;
    }

    if (_pathFotoBaruBelumDisimpan != null) {
      hapusFotoPermanen(_pathFotoBaruBelumDisimpan);
      _pathFotoBaruBelumDisimpan = null;
    }
    pathFoto.value = urlBersih;
    return true;
  }

  void hapusFotoPilihan() {
    if (_pathFotoBaruBelumDisimpan != null) {
      hapusFotoPermanen(_pathFotoBaruBelumDisimpan);
      _pathFotoBaruBelumDisimpan = null;
    }
    pathFoto.value = null;
  }

  void ubahKategori(String? nilaiBaru) {
    idKategoriTerpilih.value = nilaiBaru;
  }

  void ubahPilihanTopping(String idTopping, bool? centang) {
    if (centang == true) {
      if (!daftarIdToppingTerpilih.contains(idTopping)) {
        daftarIdToppingTerpilih.add(idTopping);
      }
    } else {
      daftarIdToppingTerpilih.remove(idTopping);
    }
  }

  Future<void> simpanProduk() async {
    if (!(formKunci.currentState?.validate() ?? false)) return;
    if (idKategoriTerpilih.value == null || idKategoriTerpilih.value!.isEmpty) {
      tampilkanNotifikasiPeringatan(
        'Kategori Belum Dipilih',
        'Buat kategori terlebih dahulu atau pilih kategori produk.',
      );
      return;
    }

    final harga = int.tryParse(pengontrolHarga.text.trim()) ?? 0;
    final stok = int.tryParse(pengontrolStok.text.trim()) ?? 0;

    if (produkAwal == null) {
      await masterData.tambahProduk(
        nama: pengontrolNama.text,
        idKategori: idKategoriTerpilih.value!,
        harga: harga,
        stok: stok,
        pathFoto: pathFoto.value,
        daftarIdTopping: daftarIdToppingTerpilih.toList(),
      );
    } else {
      await masterData.ubahProduk(
        id: produkAwal!.id,
        nama: pengontrolNama.text,
        idKategori: idKategoriTerpilih.value!,
        harga: harga,
        stok: stok,
        pathFoto: pathFoto.value,
        daftarIdTopping: daftarIdToppingTerpilih.toList(),
      );
    }

    _sudahDisimpan = true;
    tutupRuteAktif();
    tampilkanNotifikasiSukses(
      'Berhasil',
      sedangUbah
          ? 'Produk berhasil diperbarui.'
          : 'Produk berhasil ditambahkan.',
    );
  }

  @override
  void onClose() {
    if (!_sudahDisimpan && _pathFotoBaruBelumDisimpan != null) {
      hapusFotoPermanen(_pathFotoBaruBelumDisimpan);
    }
    pengontrolNama.dispose();
    pengontrolHarga.dispose();
    pengontrolStok.dispose();
    pengontrolUrlFoto.dispose();
    super.onClose();
  }
}
