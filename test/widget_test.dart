import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobiledev/controllers/autentikasi_controller.dart';
import 'package:mobiledev/controllers/beranda_controller.dart';
import 'package:mobiledev/controllers/laporan_controller.dart';
import 'package:mobiledev/controllers/master_data_controller.dart';
import 'package:mobiledev/controllers/master_form_controller.dart';
import 'package:mobiledev/controllers/printer_controller.dart';
import 'package:mobiledev/controllers/transaksi_controller.dart';
import 'package:mobiledev/data/models/kategori_model.dart';
import 'package:mobiledev/data/models/pengguna_model.dart';
import 'package:mobiledev/data/models/pesanan_tersimpan_model.dart';
import 'package:mobiledev/data/models/produk_model.dart';
import 'package:mobiledev/data/models/topping_model.dart';
import 'package:mobiledev/data/models/transaksi_model.dart';
import 'package:mobiledev/data/services/penyimpanan_service.dart';
import 'package:mobiledev/utils/format_uang.dart';
import 'package:mobiledev/utils/penyimpanan_foto.dart';
import 'package:mobiledev/views/autentikasi/login_view.dart';
import 'package:mobiledev/views/autentikasi/register_view.dart';
import 'package:mobiledev/views/beranda/beranda_view.dart';
import 'package:mobiledev/views/kasir/panel_keranjang_widget.dart';
import 'package:mobiledev/views/splash/splash_view.dart';

class _PenyimpananMemoriUji extends GetxService implements PenyimpananService {
  _PenyimpananMemoriUji(this._direktori);

  final String _direktori;
  List<PenggunaModel> _pengguna = [];
  PenggunaModel? _sesi;
  List<KategoriModel> _kategori = [];
  List<ToppingModel> _topping = [];
  List<ProdukModel> _produk = [];
  List<TransaksiModel> _transaksi = [];
  List<PesananTersimpanModel> _pesananTersimpan = [];

  @override
  String get direktoriDokumen => _direktori;

  @override
  Future<PenyimpananService> inisialisasi() async => this;

  @override
  List<PenggunaModel> ambilDaftarPengguna() => List.from(_pengguna);

  @override
  Future<void> simpanDaftarPengguna(List<PenggunaModel> daftar) async {
    _pengguna = List.from(daftar);
  }

  @override
  PenggunaModel? ambilSesiPengguna() => _sesi;

  @override
  Future<void> simpanSesiPengguna(PenggunaModel? pengguna) async {
    _sesi = pengguna;
  }

  @override
  List<KategoriModel> ambilDaftarKategori() => List.from(_kategori);

  @override
  Future<void> simpanDaftarKategori(List<KategoriModel> daftar) async {
    _kategori = List.from(daftar);
  }

  @override
  List<ToppingModel> ambilDaftarTopping() => List.from(_topping);

  @override
  Future<void> simpanDaftarTopping(List<ToppingModel> daftar) async {
    _topping = List.from(daftar);
  }

  @override
  List<ProdukModel> ambilDaftarProduk() => List.from(_produk);

  @override
  Future<void> simpanDaftarProduk(List<ProdukModel> daftar) async {
    _produk = List.from(daftar);
  }

  @override
  List<TransaksiModel> ambilDaftarTransaksi() => List.from(_transaksi);

  @override
  Future<void> simpanDaftarTransaksi(List<TransaksiModel> daftar) async {
    _transaksi = List.from(daftar);
  }

  @override
  List<PesananTersimpanModel> ambilDaftarPesananTersimpan() =>
      List.from(_pesananTersimpan);

  @override
  Future<void> simpanDaftarPesananTersimpan(
    List<PesananTersimpanModel> daftar,
  ) async {
    _pesananTersimpan = List.from(daftar);
  }
}

void main() {
  late Directory folderDokumenUji;
  late MasterDataController masterData;
  late TransaksiController transaksi;
  late LaporanController laporan;

  setUp(() async {
    Get.reset();
    folderDokumenUji = Directory.systemTemp.createTempSync('kasir_uji_');
    final penyimpanan = _PenyimpananMemoriUji(folderDokumenUji.path);
    await penyimpanan.simpanSesiPengguna(
      PenggunaModel(
        id: 'usr_1',
        nama: 'Budi Kasir',
        namaPengguna: 'budi',
        kataSandi: '1234',
      ),
    );
    Get.put<PenyimpananService>(penyimpanan);

    final auth = Get.put(AutentikasiController());
    auth.sesiPengguna.value = penyimpanan.ambilSesiPengguna();

    masterData = Get.put(MasterDataController());
    laporan = Get.put(LaporanController());
    transaksi = Get.put(TransaksiController());
  });

  tearDown(() {
    Get.reset();
    if (folderDokumenUji.existsSync()) {
      folderDokumenUji.deleteSync(recursive: true);
    }
  });

  test('Format rupiah dan tanggal berjalan dengan benar', () {
    expect(formatRupiah(15000), 'Rp 15.000');
    expect(formatRupiah(0), 'Rp 0');
    expect(formatRupiah(1250500), 'Rp 1.250.500');

    final waktuUji = DateTime(2026, 11, 10, 12, 30);
    expect(formatTanggalSingkat(waktuUji), '10 Nov 2026');
    expect(formatTanggalWaktu(waktuUji), '10 Nov 2026, 12:30');
  });

  test(
    'Stok bersama produk dan add-on menghitung total terpakai dan menolak item melebihi stok',
    () async {
      await masterData.tambahKategori(nama: 'Minuman');
      final idKat = masterData.daftarKategori.first.id;

      await masterData.tambahTopping(
        nama: 'Extra Shot',
        hargaTambahan: 5000,
        stok: 1,
      );
      final extraShot = masterData.daftarTopping.first;

      await masterData.tambahProduk(
        nama: 'Kopi Susu',
        idKategori: idKat,
        harga: 18000,
        stok: 2,
        daftarIdTopping: [extraShot.id],
      );
      await masterData.tambahProduk(
        nama: 'Matcha Latte',
        idKategori: idKat,
        harga: 22000,
        stok: 5,
        daftarIdTopping: [extraShot.id],
      );

      final kopiSusu = masterData.daftarProduk[0];
      final matchaLatte = masterData.daftarProduk[1];

      expect(
        transaksi.tambahKeKeranjang(produk: kopiSusu, daftarTopping: []),
        isTrue,
      );

      expect(
        transaksi.tambahKeKeranjang(
          produk: kopiSusu,
          daftarTopping: [extraShot],
        ),
        isTrue,
      );
      expect(transaksi.hitungPemakaianProdukDiKeranjang(kopiSusu.id), 2);
      expect(transaksi.hitungPemakaianToppingDiKeranjang(extraShot.id), 1);

      expect(
        transaksi.tambahKeKeranjang(produk: kopiSusu, daftarTopping: []),
        isFalse,
      );
      expect(transaksi.hitungPemakaianProdukDiKeranjang(kopiSusu.id), 2);

      expect(
        transaksi.tambahKeKeranjang(
          produk: matchaLatte,
          daftarTopping: [extraShot],
        ),
        isFalse,
      );
    },
  );

  test(
    'Riwayat transaksi dan struk menyimpan snapshot dan tidak berubah walau produk diubah/dihapus',
    () async {
      await masterData.tambahKategori(nama: 'Makanan');
      final idKat = masterData.daftarKategori.first.id;

      await masterData.tambahProduk(
        nama: 'Roti Bakar',
        idKategori: idKat,
        harga: 15000,
        stok: 10,
      );
      final rotiBakar = masterData.daftarProduk.first;

      expect(
        transaksi.tambahKeKeranjang(produk: rotiBakar, daftarTopping: []),
        isTrue,
      );
      transaksi.aturUangDiterima(20000);
      final struk = await transaksi.prosesPembayaran();
      expect(struk, isNotNull);
      expect(struk!.totalAkhir, 15000);

      await masterData.ubahProduk(
        id: rotiBakar.id,
        nama: 'Roti Bakar Spesial',
        idKategori: idKat,
        harga: 20000,
        stok: 9,
      );

      await masterData.hapusProduk(rotiBakar.id);
      expect(masterData.daftarProduk, isEmpty);

      expect(laporan.jumlahTransaksiSukses, 1);
      expect(laporan.totalPendapatan, 15000);
      final riwayat = laporan.daftarTransaksi.first;
      expect(riwayat.daftarItem.first.namaProduk, 'Roti Bakar');
      expect(riwayat.daftarItem.first.hargaProduk, 15000);
      expect(riwayat.totalAkhir, 15000);
    },
  );

  test(
    'Foto disalin ke penyimpanan permanen dan tetap ada setelah file cache sementara dihapus',
    () async {
      final folderCacheSementara = Directory.systemTemp.createTempSync(
        'cache_picker_',
      );
      final fileCache = File('${folderCacheSementara.path}/temp_camera.jpg');
      await fileCache.writeAsBytes([10, 20, 30, 40, 50]);

      final pathPermanen = await salinFotoKePenyimpananPermanen(
        XFile(fileCache.path),
      );

      folderCacheSementara.deleteSync(recursive: true);
      expect(fileCache.existsSync(), isFalse);

      final pathValid = selesaikanPathFotoPermanen(pathPermanen);
      expect(pathValid, isNotNull);
      final filePermanen = File(pathValid!);
      expect(filePermanen.existsSync(), isTrue);
      expect(filePermanen.readAsBytesSync(), [10, 20, 30, 40, 50]);
    },
  );

  test(
    'Proteksi diskon: persen maksimal 100%, nominal maksimal subtotal, total tidak pernah negatif',
    () async {
      await masterData.tambahKategori(nama: 'Makanan');
      final idKat = masterData.daftarKategori.first.id;
      await masterData.tambahProduk(
        nama: 'Roti Bakar',
        idKategori: idKat,
        harga: 20000,
        stok: 10,
      );

      final produk = masterData.daftarProduk.first;
      transaksi.tambahKeKeranjang(produk: produk, daftarTopping: [], jumlah: 1);
      expect(transaksi.subtotalKeranjang, 20000);

      transaksi.aturDiskon('persen', 150);
      expect(transaksi.nilaiDiskonInput.value, 100.0);
      expect(transaksi.potonganDiskon, 20000);
      expect(transaksi.totalTagihan, 0);

      transaksi.aturDiskon('nominal', 50000);
      expect(transaksi.nilaiDiskonInput.value, 20000.0);
      expect(transaksi.potonganDiskon, 20000);
      expect(transaksi.totalTagihan, 0);

      transaksi.aturDiskon('nominal', -5000);
      expect(transaksi.potonganDiskon, 0);
      expect(transaksi.totalTagihan, 20000);
    },
  );

  test(
    'Register dan login lokal hanya dengan nama, username, dan password bekerja dengan benar',
    () async {
      final auth = Get.find<AutentikasiController>();
      await auth.keluarAkun();
      expect(auth.sesiPengguna.value, isNull);

      final daftarSukses = await auth.daftarAkun(
        nama: 'Siti Kasir',
        namaPengguna: 'siti',
        kataSandi: '1234',
      );
      expect(daftarSukses, isTrue);

      final daftarDuplikat = await auth.daftarAkun(
        nama: 'Siti Lain',
        namaPengguna: 'SITI',
        kataSandi: '9999',
      );
      expect(daftarDuplikat, isFalse);

      final loginGagal = await auth.masukAkun(
        namaPengguna: 'siti',
        kataSandi: 'salah',
      );
      expect(loginGagal, isFalse);

      final loginSukses = await auth.masukAkun(
        namaPengguna: 'siti',
        kataSandi: '1234',
      );
      expect(loginSukses, isTrue);
      expect(auth.sesiPengguna.value?.nama, 'Siti Kasir');
      expect(auth.sesiPengguna.value?.namaPengguna, 'siti');
    },
  );

  test(
    'Upload gambar produk mendukung URL gambar valid dan menolak URL tidak valid',
    () {
      final formCtrl = FormProdukController(null);
      formCtrl.onInit();

      expect(formCtrl.gunakanUrlGambar('bukan-url'), isFalse);
      expect(formCtrl.pathFoto.value, isNull);

      expect(formCtrl.gunakanUrlGambar('https://contoh.com/kopi.jpg'), isTrue);
      expect(formCtrl.pathFoto.value, 'https://contoh.com/kopi.jpg');
      expect(
        selesaikanPathFotoPermanen(formCtrl.pathFoto.value),
        'https://contoh.com/kopi.jpg',
      );

      formCtrl.hapusFotoPilihan();
      expect(formCtrl.pathFoto.value, isNull);
      formCtrl.onClose();
    },
  );

  testWidgets(
    'UI Register menampilkan notifikasi berhasil dan kembali ke LoginView',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/login',
          getPages: [
            GetPage(
              name: '/login',
              page: () => const LoginView(),
              binding: BindingsBuilder(() {
                Get.lazyPut<LoginController>(() => LoginController());
              }),
            ),
            GetPage(
              name: '/register',
              page: () => const RegisterView(),
              binding: BindingsBuilder(() {
                Get.lazyPut<RegisterController>(() => RegisterController());
              }),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Daftar Baru'));
      await tester.pumpAndSettle();
      expect(find.text('Registrasi Akun Lokal'), findsOneWidget);

      final daftarInput = find.byType(TextFormField);
      await tester.enterText(daftarInput.at(0), 'Andi Kasir');
      await tester.enterText(daftarInput.at(1), 'andi99');
      await tester.enterText(daftarInput.at(2), '1234');

      await tester.tap(find.text('Daftar Sekarang'));
      await tester.pumpAndSettle();

      expect(find.text('Registrasi Akun Lokal'), findsNothing);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Pendaftaran Berhasil'), findsOneWidget);
      expect(find.text('andi99'), findsOneWidget);

      await tester.tap(find.text('Daftar Baru'));
      await tester.pumpAndSettle();
      final daftarInputKedua = find.byType(TextFormField);
      await tester.enterText(daftarInputKedua.at(0), 'Andi Lain');
      await tester.enterText(daftarInputKedua.at(1), 'andi99');
      await tester.enterText(daftarInputKedua.at(2), '5678');
      await tester.tap(find.text('Daftar Sekarang'));
      await tester.pumpAndSettle();

      expect(find.text('Registrasi Akun Lokal'), findsOneWidget);
      expect(find.text('Pendaftaran Gagal'), findsOneWidget);
    },
  );

  test(
    'Hold / Save Bill menyimpan pesanan sementara dan dapat dilanjutkan kembali',
    () async {
      await masterData.tambahKategori(nama: 'Minuman');
      final idKat = masterData.daftarKategori.first.id;
      await masterData.tambahProduk(
        nama: 'Es Kopi',
        idKategori: idKat,
        harga: 15000,
        stok: 10,
      );
      final produk = masterData.daftarProduk.first;

      transaksi.tambahKeKeranjang(produk: produk, daftarTopping: [], jumlah: 2);
      transaksi.aturDiskon('persen', 10);

      final disimpan = await transaksi.simpanPesananSementara('Meja 3');
      expect(disimpan, isTrue);
      expect(transaksi.keranjang, isEmpty);
      expect(transaksi.daftarPesananTersimpan.length, 1);
      expect(transaksi.daftarPesananTersimpan.first.namaTagihan, 'Meja 3');

      final dilanjutkan = await transaksi.lanjutkanPesananTersimpan(
        transaksi.daftarPesananTersimpan.first,
      );
      expect(dilanjutkan, isTrue);
      expect(transaksi.daftarPesananTersimpan, isEmpty);
      expect(transaksi.totalJumlahItemKeranjang, 2);
      expect(transaksi.jenisDiskon.value, 'persen');
      expect(transaksi.nilaiDiskonInput.value, 10.0);
      expect(transaksi.totalTagihan, 27000);
    },
  );

  test(
    'Indikator stok menipis mendeteksi produk dengan stok <= 5 dan habis',
    () async {
      await masterData.tambahKategori(nama: 'Makanan');
      final idKat = masterData.daftarKategori.first.id;
      await masterData.tambahProduk(
        nama: 'Stok Aman',
        idKategori: idKat,
        harga: 10000,
        stok: 10,
      );
      await masterData.tambahProduk(
        nama: 'Stok Menipis',
        idKategori: idKat,
        harga: 10000,
        stok: 3,
      );
      await masterData.tambahProduk(
        nama: 'Stok Habis',
        idKategori: idKat,
        harga: 10000,
        stok: 0,
      );

      expect(masterData.apakahStokMenipis(3), isTrue);
      expect(masterData.apakahStokMenipis(10), isFalse);
      expect(masterData.daftarProdukStokMenipis.length, 1);
      expect(masterData.daftarProdukStokMenipis.first.nama, 'Stok Menipis');
      expect(masterData.daftarProdukStokHabis.length, 1);
      expect(masterData.daftarProdukStokHabis.first.nama, 'Stok Habis');
    },
  );

  test(
    'Dashboard penjualan menghitung filter tanggal, grafik harian, dan produk terlaris',
    () async {
      final sekarang = DateTime.now();
      final kemarin = sekarang.subtract(const Duration(days: 3));

      await laporan.tambahTransaksi(
        TransaksiModel(
          id: 'trx_1',
          nomorStruk: 'TRX-001',
          waktu: sekarang,
          namaToko: 'Aplikasi Kasir',
          namaKasir: 'Budi',
          daftarItem: [
            ItemTransaksiModel(
              idProduk: 'p1',
              namaProduk: 'Kopi Susu',
              hargaProduk: 18000,
              jumlah: 2,
              daftarTopping: [],
              totalHargaItem: 36000,
            ),
          ],
          subtotal: 36000,
          jenisDiskon: 'nominal',
          nilaiDiskonInput: 6000,
          potonganDiskon: 6000,
          totalAkhir: 30000,
          uangDiterima: 50000,
          uangKembalian: 20000,
        ),
      );

      await laporan.tambahTransaksi(
        TransaksiModel(
          id: 'trx_2',
          nomorStruk: 'TRX-002',
          waktu: kemarin,
          namaToko: 'Aplikasi Kasir',
          namaKasir: 'Budi',
          daftarItem: [
            ItemTransaksiModel(
              idProduk: 'p2',
              namaProduk: 'Roti Bakar',
              hargaProduk: 15000,
              jumlah: 1,
              daftarTopping: [],
              totalHargaItem: 15000,
            ),
          ],
          subtotal: 15000,
          jenisDiskon: 'nominal',
          nilaiDiskonInput: 0,
          potonganDiskon: 0,
          totalAkhir: 15000,
          uangDiterima: 20000,
          uangKembalian: 5000,
        ),
      );

      expect(laporan.totalPendapatan, 45000);
      expect(laporan.totalDiskonDiberikan, 6000);
      expect(laporan.rataRataTransaksi, 22500);
      expect(laporan.dataGrafikPenjualan.length, 2);
      expect(laporan.daftarProdukTerlaris.first.namaProduk, 'Kopi Susu');
      expect(laporan.daftarProdukTerlaris.first.jumlahTerjual, 2);

      laporan.aturFilterPeriode('hari_ini');
      expect(laporan.jumlahTransaksiSukses, 1);
      expect(laporan.totalPendapatan, 30000);
    },
  );

  test(
    'PrinterController menghasilkan byte ESC/POS struk transaksi secara valid',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final printer = PrinterController();
      final trx = TransaksiModel(
        id: 'trx_esc',
        nomorStruk: 'TRX-ESC-001',
        waktu: DateTime(2026, 11, 12, 9, 30),
        namaToko: 'Aplikasi Kasir',
        namaKasir: 'Budi',
        daftarItem: [
          ItemTransaksiModel(
            idProduk: 'p1',
            namaProduk: 'Kopi Susu',
            hargaProduk: 18000,
            jumlah: 1,
            daftarTopping: [
              ToppingTersimpanModel(
                idTopping: 't1',
                nama: 'Boba',
                hargaTambahan: 4000,
              ),
            ],
            totalHargaItem: 22000,
          ),
        ],
        subtotal: 22000,
        jenisDiskon: 'nominal',
        nilaiDiskonInput: 2000,
        potonganDiskon: 2000,
        totalAkhir: 20000,
        uangDiterima: 50000,
        uangKembalian: 30000,
      );

      final bytes = await printer.buatByteStrukEscPos(trx);
      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(50));
    },
  );

  testWidgets(
    'Responsivitas Mobile menampilkan NavigationBar dan tanpa split keranjang',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      Get.put(BerandaController());
      Get.put(MasterTabController());
      Get.put(PrinterController());
      await masterData.tambahKategori(nama: 'Minuman');
      await masterData.tambahProduk(
        nama: 'Es Kopi',
        idKategori: masterData.daftarKategori.first.id,
        harga: 18000,
        stok: 4,
      );

      await tester.pumpWidget(const GetMaterialApp(home: BerandaView()));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(PanelKeranjangWidget), findsNothing);
      expect(find.text('Menipis'), findsOneWidget);
    },
  );

  testWidgets(
    'Responsivitas Tablet Portrait menampilkan NavigationBar dan grid produk',
    (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      Get.put(BerandaController());
      Get.put(MasterTabController());
      Get.put(PrinterController());
      await masterData.tambahKategori(nama: 'Minuman');
      await masterData.tambahProduk(
        nama: 'Matcha',
        idKategori: masterData.daftarKategori.first.id,
        harga: 22000,
        stok: 10,
      );

      await tester.pumpWidget(const GetMaterialApp(home: BerandaView()));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(PanelKeranjangWidget), findsNothing);
      expect(find.text('Matcha'), findsOneWidget);
    },
  );

  testWidgets(
    'Responsivitas Tablet Landscape menampilkan NavigationRail dan split-screen kasir',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      Get.put(BerandaController());
      Get.put(MasterTabController());
      Get.put(PrinterController());
      await masterData.tambahKategori(nama: 'Minuman');
      await masterData.tambahProduk(
        nama: 'Es Kopi',
        idKategori: masterData.daftarKategori.first.id,
        harga: 18000,
        stok: 10,
      );

      await tester.pumpWidget(const GetMaterialApp(home: BerandaView()));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(PanelKeranjangWidget), findsOneWidget);
      expect(find.text('Keranjang masih kosong'), findsOneWidget);

      await tester.tap(find.text('Es Kopi'));
      await tester.pumpAndSettle();
      expect(find.text('Daftar Pesanan'), findsOneWidget);
      expect(find.text('Bayar & Simpan'), findsOneWidget);
    },
  );

  Widget buatAplikasiRuteUji(String ruteAwal) {
    return GetMaterialApp(
      initialRoute: ruteAwal,
      getPages: [
        GetPage(
          name: '/splash',
          page: () => const SplashView(),
          binding: BindingsBuilder(() {
            Get.put<SplashController>(SplashController());
          }),
        ),
        GetPage(
          name: '/login',
          page: () => const LoginView(),
          binding: BindingsBuilder(() {
            Get.lazyPut<LoginController>(() => LoginController());
          }),
        ),
        GetPage(
          name: '/register',
          page: () => const RegisterView(),
          binding: BindingsBuilder(() {
            Get.lazyPut<RegisterController>(() => RegisterController());
          }),
        ),
        GetPage(
          name: '/beranda',
          page: () => const BerandaView(),
          binding: BindingsBuilder(() {
            Get.lazyPut<BerandaController>(
              () => BerandaController(),
              fenix: true,
            );
            Get.lazyPut<MasterTabController>(
              () => MasterTabController(),
              fenix: true,
            );
            Get.lazyPut<PrinterController>(
              () => PrinterController(),
              fenix: true,
            );
          }),
        ),
      ],
    );
  }

  testWidgets(
    'Splash Screen otomatis mengarahkan ke LoginView jika belum ada sesi lokal',
    (tester) async {
      final penyimpanan = Get.find<PenyimpananService>();
      final auth = Get.find<AutentikasiController>();
      await penyimpanan.simpanSesiPengguna(null);
      auth.sesiPengguna.value = null;

      await tester.pumpWidget(buatAplikasiRuteUji('/splash'));
      await tester.pump();

      expect(find.text('APLIKASI KASIR'), findsOneWidget);
      expect(find.text('Memeriksa sesi pengguna...'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();

      expect(find.byType(LoginView), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    },
  );

  testWidgets(
    'Splash Screen otomatis masuk ke BerandaView jika sesi lokal tersimpan',
    (tester) async {
      await tester.pumpWidget(buatAplikasiRuteUji('/splash'));
      await tester.pump();

      expect(find.text('APLIKASI KASIR'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();

      expect(find.byType(BerandaView), findsOneWidget);
      expect(find.text('Kasir: Budi Kasir'), findsOneWidget);
    },
  );

  testWidgets(
    'UI Login offline memvalidasi input, menolak kredensial salah, masuk ke BerandaView, dan logout',
    (tester) async {
      final penyimpanan = Get.find<PenyimpananService>();
      final auth = Get.find<AutentikasiController>();
      await penyimpanan.simpanSesiPengguna(null);
      auth.sesiPengguna.value = null;

      await auth.daftarAkun(
        nama: 'Rina Kasir',
        namaPengguna: 'rina',
        kataSandi: '4321',
      );

      await tester.pumpWidget(buatAplikasiRuteUji('/login'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();
      expect(find.text('Username tidak boleh kosong'), findsOneWidget);
      expect(find.text('Password tidak boleh kosong'), findsOneWidget);

      final daftarInput = find.byType(TextFormField);
      await tester.enterText(daftarInput.at(0), 'rina');
      await tester.enterText(daftarInput.at(1), 'salah');
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginView), findsOneWidget);
      expect(find.text('Login Gagal'), findsOneWidget);
      expect(penyimpanan.ambilSesiPengguna(), isNull);

      await tester.enterText(daftarInput.at(0), 'RINA');
      await tester.enterText(daftarInput.at(1), '4321');
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      expect(find.byType(BerandaView), findsOneWidget);
      expect(find.text('Kasir: Rina Kasir'), findsOneWidget);
      expect(penyimpanan.ambilSesiPengguna()?.namaPengguna, 'rina');

      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Keluar Sesi'), findsOneWidget);

      await tester.tap(find.text('Keluar'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginView), findsOneWidget);
      expect(penyimpanan.ambilSesiPengguna(), isNull);
      expect(auth.sesiPengguna.value, isNull);
    },
  );
}
