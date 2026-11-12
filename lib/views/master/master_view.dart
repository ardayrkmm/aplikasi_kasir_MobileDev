import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobiledev/controllers/master_data_controller.dart';
import 'package:mobiledev/controllers/master_form_controller.dart';
import 'package:mobiledev/utils/format_uang.dart';
import 'package:mobiledev/utils/gambar_produk_widget.dart';
import 'package:mobiledev/utils/responsif_helper.dart';
import 'package:mobiledev/utils/tema_aplikasi.dart';
import 'package:mobiledev/views/master/form_kategori_dialog.dart';
import 'package:mobiledev/views/master/form_produk_view.dart';
import 'package:mobiledev/views/master/form_topping_dialog.dart';

class MasterView extends GetView<MasterTabController> {
  const MasterView({super.key});

  void _bukaFormTambah(BuildContext context) {
    final indeks = controller.indeksTabAktif.value;
    if (indeks == 0) {
      Get.to(() => const FormProdukView());
    } else if (indeks == 1) {
      showDialog(context: context, builder: (_) => const FormKategoriDialog());
    } else {
      showDialog(context: context, builder: (_) => const FormToppingDialog());
    }
  }

  @override
  Widget build(BuildContext context) {
    final masterData = Get.find<MasterDataController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Master Data'),
        bottom: TabBar(
          controller: controller.pengontrolTab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amberAccent,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Produk'),
            Tab(icon: Icon(Icons.category_outlined), text: 'Kategori'),
            Tab(icon: Icon(Icons.extension_outlined), text: 'Add-on / Topping'),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller.pengontrolTab,
        children: [
          _bangunTabProduk(context, masterData),
          _bangunTabKategori(context, masterData),
          _bangunTabTopping(context, masterData),
        ],
      ),
      floatingActionButton: Obx(() {
        return FloatingActionButton.extended(
          onPressed: () => _bukaFormTambah(context),
          backgroundColor: TemaAplikasi.warnaUtama,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: Text(controller.labelTombolTambah),
        );
      }),
    );
  }

  Widget _bangunTabProduk(
    BuildContext context,
    MasterDataController masterData,
  ) {
    final jumlahKolom = ResponsifHelper.jumlahKolomMaster(context);

    return Obx(() {
      final daftar = masterData.daftarProduk;
      if (daftar.isEmpty) {
        return const Center(
          child: Text('Belum ada produk. Tekan tombol + untuk menambahkan.'),
        );
      }

      if (jumlahKolom > 1) {
        return GridView.builder(
          padding: const EdgeInsets.only(
            left: 14,
            right: 14,
            top: 14,
            bottom: 80,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: jumlahKolom,
            mainAxisExtent: 122,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: daftar.length,
          itemBuilder: (context, indeks) {
            return _kartuItemProduk(context, masterData, daftar[indeks]);
          },
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.only(
          left: 14,
          right: 14,
          top: 14,
          bottom: 80,
        ),
        itemCount: daftar.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, indeks) {
          return _kartuItemProduk(context, masterData, daftar[indeks]);
        },
      );
    });
  }

  Widget _kartuItemProduk(
    BuildContext context,
    MasterDataController masterData,
    dynamic produk,
  ) {
    final namaKategori = masterData.ambilNamaKategori(produk.idKategori);
    final daftarTopping = masterData.ambilToppingDariDaftarId(
      produk.daftarIdTopping,
    );

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: tampilkanFotoProduk(pathFoto: produk.pathFoto, ukuran: 54),
        title: Text(
          produk.nama,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    namaKategori,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  'Stok: ${produk.stok}',
                  style: TextStyle(
                    fontSize: 12,
                    color: produk.stok <= 0
                        ? TemaAplikasi.warnaBahaya
                        : masterData.apakahStokMenipis(produk.stok)
                        ? TemaAplikasi.warnaPeringatan
                        : Colors.grey.shade700,
                    fontWeight:
                        (produk.stok <= 0 ||
                            masterData.apakahStokMenipis(produk.stok))
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                if (produk.stok <= 0)
                  _badgeStatusStok('Habis', TemaAplikasi.warnaBahaya)
                else if (masterData.apakahStokMenipis(produk.stok))
                  _badgeStatusStok('Menipis', TemaAplikasi.warnaPeringatan),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              formatRupiah(produk.harga),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: TemaAplikasi.warnaUtama,
              ),
            ),
            if (daftarTopping.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                'Add-on: ${daftarTopping.map((t) => t.nama).join(", ")}',
                style: const TextStyle(
                  fontSize: 11,
                  color: TemaAplikasi.warnaTeksAbu,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blue),
              onPressed: () {
                Get.to(() => FormProdukView(produkAwal: produk));
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: TemaAplikasi.warnaBahaya,
              ),
              onPressed: () => _konfirmasiHapus(
                context: context,
                judul: 'Hapus Produk',
                pesan: 'Yakin ingin menghapus produk "${produk.nama}"?',
                padaHapus: () => masterData.hapusProduk(produk.id),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bangunTabKategori(
    BuildContext context,
    MasterDataController masterData,
  ) {
    final jumlahKolom = ResponsifHelper.jumlahKolomMaster(context);

    return Obx(() {
      final daftar = masterData.daftarKategori;
      if (daftar.isEmpty) {
        return const Center(
          child: Text('Belum ada kategori. Tekan tombol + untuk menambahkan.'),
        );
      }

      if (jumlahKolom > 1) {
        return GridView.builder(
          padding: const EdgeInsets.only(
            left: 14,
            right: 14,
            top: 14,
            bottom: 80,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: jumlahKolom,
            mainAxisExtent: 88,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: daftar.length,
          itemBuilder: (context, indeks) {
            return _kartuItemKategori(context, masterData, daftar[indeks]);
          },
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.only(
          left: 14,
          right: 14,
          top: 14,
          bottom: 80,
        ),
        itemCount: daftar.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, indeks) {
          return _kartuItemKategori(context, masterData, daftar[indeks]);
        },
      );
    });
  }

  Widget _kartuItemKategori(
    BuildContext context,
    MasterDataController masterData,
    dynamic kategori,
  ) {
    final jumlahProduk = masterData.daftarProduk
        .where((p) => p.idKategori == kategori.id)
        .length;

    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: TemaAplikasi.warnaUtama,
          foregroundColor: Colors.white,
          child: Icon(Icons.category_rounded, size: 20),
        ),
        title: Text(
          kategori.nama,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          kategori.keterangan.isNotEmpty
              ? '${kategori.keterangan}  •  $jumlahProduk produk'
              : '$jumlahProduk produk terkait',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blue),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => FormKategoriDialog(kategoriAwal: kategori),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: TemaAplikasi.warnaBahaya,
              ),
              onPressed: () => _konfirmasiHapus(
                context: context,
                judul: 'Hapus Kategori',
                pesan: 'Yakin ingin menghapus kategori "${kategori.nama}"?',
                padaHapus: () => masterData.hapusKategori(kategori.id),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bangunTabTopping(
    BuildContext context,
    MasterDataController masterData,
  ) {
    final jumlahKolom = ResponsifHelper.jumlahKolomMaster(context);

    return Obx(() {
      final daftar = masterData.daftarTopping;
      if (daftar.isEmpty) {
        return const Center(
          child: Text(
            'Belum ada add-on / topping. Tekan tombol + untuk menambahkan.',
          ),
        );
      }

      if (jumlahKolom > 1) {
        return GridView.builder(
          padding: const EdgeInsets.only(
            left: 14,
            right: 14,
            top: 14,
            bottom: 80,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: jumlahKolom,
            mainAxisExtent: 88,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: daftar.length,
          itemBuilder: (context, indeks) {
            return _kartuItemTopping(context, masterData, daftar[indeks]);
          },
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.only(
          left: 14,
          right: 14,
          top: 14,
          bottom: 80,
        ),
        itemCount: daftar.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, indeks) {
          return _kartuItemTopping(context, masterData, daftar[indeks]);
        },
      );
    });
  }

  Widget _kartuItemTopping(
    BuildContext context,
    MasterDataController masterData,
    dynamic topping,
  ) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF6B46C1),
          foregroundColor: Colors.white,
          child: Icon(Icons.extension_rounded, size: 20),
        ),
        title: Text(
          topping.nama,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          children: [
            Text(
              '+ ${formatRupiah(topping.hargaTambahan)}  •  Stok: ${topping.stok}',
              style: const TextStyle(fontSize: 12),
            ),
            if (topping.stok <= 0)
              _badgeStatusStok('Habis', TemaAplikasi.warnaBahaya)
            else if (masterData.apakahStokMenipis(topping.stok))
              _badgeStatusStok('Menipis', TemaAplikasi.warnaPeringatan),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blue),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => FormToppingDialog(toppingAwal: topping),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: TemaAplikasi.warnaBahaya,
              ),
              onPressed: () => _konfirmasiHapus(
                context: context,
                judul: 'Hapus Add-on',
                pesan: 'Yakin ingin menghapus add-on "${topping.nama}"?',
                padaHapus: () => masterData.hapusTopping(topping.id),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badgeStatusStok(String teks, Color warna) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        teks,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: warna,
        ),
      ),
    );
  }

  void _konfirmasiHapus({
    required BuildContext context,
    required String judul,
    required String pesan,
    required Future<dynamic> Function() padaHapus,
  }) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(judul),
          content: Text(pesan),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: TemaAplikasi.warnaBahaya,
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                await padaHapus();
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
