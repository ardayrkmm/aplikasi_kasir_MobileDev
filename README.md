# Aplikasi Kasir

Aplikasi kasir (Mini POS) offline berbasis Flutter untuk mencatat transaksi penjualan, stok produk, dan laporan tanpa koneksi internet.

## Arsitektur Proyek

Kode dibagi berdasarkan struktur MVC agar tampilan dan logika terpisah:

- `lib/data/models/`: model data (`PenggunaModel`, `KategoriModel`, `ToppingModel`, `ProdukModel`, `TransaksiModel`, `PesananTersimpanModel`)
- `lib/data/services/`: penyimpanan lokal offline melalui `PenyimpananService`
- `lib/controllers/`: logika bisnis dan state untuk autentikasi, master data, transaksi, laporan, dan printer
- `lib/views/`: halaman UI (`splash`, `autentikasi`, `beranda`, `kasir`, `master`, `laporan`)
- `lib/utils/`: formatter rupiah/tanggal, penyimpanan foto permanen, tema, notifikasi, dan helper responsif

## State Management

State management menggunakan **GetX** (`Rx`, `Obx`, `GetBuilder`, dan `GetView`) tanpa `StatefulWidget` atau `setState`. Pengaturan rute dan dependency injection diletakkan di `lib/main.dart` memakai `GetMaterialApp`, `BindingsBuilder`, `Get.put`, `Get.lazyPut`, dan `Get.putAsync`.

## Struktur Penyimpanan Lokal

Data disimpan secara offline di perangkat memakai `GetStorage` pada box `kasir_lokal` dengan daftar kunci berikut:

| Kunci | Keterangan |
| --- | --- |
| `daftar_pengguna` | Akun kasir terdaftar (`id`, `nama`, `namaPengguna`, `kataSandi`) |
| `sesi_pengguna` | Sesi kasir yang sedang login |
| `daftar_kategori` | Data kategori produk |
| `daftar_topping` | Data add-on / topping beserta stoknya |
| `daftar_produk` | Data produk, harga, stok, path foto, dan relasi id topping |
| `daftar_transaksi` | Riwayat transaksi beserta snapshot item, topping, harga, dan total saat transaksi terjadi |
| `daftar_pesanan_tersimpan` | Daftar pesanan sementara (Hold / Save Bill) |

Foto produk dari kamera atau galeri disalin ke direktori dokumen aplikasi (`foto_produk/`) agar tetap aman saat cache sistem dibersihkan.

## Fitur Bonus yang Ditambahkan

- **Printer Thermal Bluetooth (ESC/POS)**: cetak struk langsung ukuran kertas 58mm atau 80mm.
- **Dashboard & Analitik Penjualan**: grafik batang harian, filter periode (Semua, Hari Ini, 7 Hari, 30 Hari, dan rentang tanggal kustom), produk terlaris, rata-rata transaksi, dan total diskon.
- **Fitur POS Tambahan**: Hold / Save Bill, tombol Quick Cash (Uang Pas & pecahan nominal), dan indikator stok menipis (`<= 5`) maupun stok habis.
- **Tampilan Responsif**: menyesuaikan layout untuk Mobile, Tablet Portrait, dan Tablet Landscape (split-screen katalog + keranjang serta `NavigationRail`).

## Cara Menjalankan

```bash
flutter pub get
flutter test
flutter run
```

File APK release tersedia di `release/aplikasi-kasir-release.apk` atau dapat dibuat ulang dengan perintah:

```bash
flutter build apk --release
```
