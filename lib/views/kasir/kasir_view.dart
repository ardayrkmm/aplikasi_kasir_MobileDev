import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobiledev/controllers/autentikasi_controller.dart';
import 'package:mobiledev/controllers/master_data_controller.dart';
import 'package:mobiledev/controllers/printer_controller.dart';
import 'package:mobiledev/controllers/transaksi_controller.dart';
import 'package:mobiledev/data/models/produk_model.dart';
import 'package:mobiledev/utils/format_uang.dart';
import 'package:mobiledev/utils/gambar_produk_widget.dart';
import 'package:mobiledev/utils/notifikasi_helper.dart';
import 'package:mobiledev/utils/responsif_helper.dart';
import 'package:mobiledev/utils/tema_aplikasi.dart';
import 'package:mobiledev/views/kasir/dialog_daftar_bill_view.dart';
import 'package:mobiledev/views/kasir/dialog_printer_view.dart';
import 'package:mobiledev/views/kasir/dialog_topping_view.dart';
import 'package:mobiledev/views/kasir/keranjang_view.dart';
import 'package:mobiledev/views/kasir/panel_keranjang_widget.dart';

class KasirView extends StatelessWidget {
  const KasirView({super.key});

  @override
  Widget build(BuildContext context) {
    final TransaksiController transaksi = Get.find<TransaksiController>();
    final MasterDataController masterData = Get.find<MasterDataController>();
    final AutentikasiController autentikasi = Get.find<AutentikasiController>();
    final tabletLanskap = ResponsifHelper.apakahTabletLanskap(context);

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final pengguna = autentikasi.sesiPengguna.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Aplikasi Kasir',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              Text(
                'Kasir: ${pengguna?.nama ?? "-"}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          );
        }),
        actions: [
          Obx(() {
            final jumlahBill = transaksi.daftarPesananTersimpan.length;
            return IconButton(
              tooltip: 'Bill Tersimpan',
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const PembungkusModalResponsif(
                    child: DialogDaftarBillTersimpan(),
                  ),
                );
              },
              icon: Badge(
                isLabelVisible: jumlahBill > 0,
                label: Text('$jumlahBill'),
                backgroundColor: TemaAplikasi.warnaPeringatan,
                child: const Icon(Icons.receipt_long_outlined),
              ),
            );
          }),
          if (Get.isRegistered<PrinterController>())
            Obx(() {
              final printer = Get.find<PrinterController>();
              final terhubung = printer.macPrinterTerhubung.value != null;
              return IconButton(
                tooltip: 'Printer Bluetooth',
                onPressed: () {
                  printer.pindaiPrinterBluetooth();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const PembungkusModalResponsif(
                      child: DialogPrinterThermal(),
                    ),
                  );
                },
                icon: Badge(
                  isLabelVisible: terhubung,
                  smallSize: 8,
                  backgroundColor: TemaAplikasi.warnaSukses,
                  child: const Icon(Icons.print_outlined),
                ),
              );
            }),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar Akun',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Keluar Sesi'),
                  content: const Text(
                    'Yakin ingin keluar dari akun kasir ini?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TemaAplikasi.warnaBahaya,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        autentikasi.keluarAkun();
                      },
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: tabletLanskap
          ? Row(
              children: [
                Expanded(
                  flex: 6,
                  child: _areaKatalogProduk(
                    context: context,
                    transaksi: transaksi,
                    masterData: masterData,
                    paddingBawah: 16,
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Container(
                  width: 410,
                  color: TemaAplikasi.warnaLatar,
                  child: const PanelKeranjangWidget(modeSplitTablet: true),
                ),
              ],
            )
          : _areaKatalogProduk(
              context: context,
              transaksi: transaksi,
              masterData: masterData,
              paddingBawah: 90,
            ),
      bottomSheet: tabletLanskap
          ? null
          : Obx(() {
              if (transaksi.keranjang.isEmpty) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: TemaAplikasi.warnaUtama,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.shopping_cart_checkout,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${transaksi.totalJumlahItemKeranjang} Item di Keranjang',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              formatRupiah(transaksi.subtotalKeranjang),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: TemaAplikasi.warnaUtama,
                        ),
                        onPressed: () {
                          Get.to(() => const KeranjangView());
                        },
                        child: const Text(
                          'Lihat Keranjang',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
    );
  }

  Widget _areaKatalogProduk({
    required BuildContext context,
    required TransaksiController transaksi,
    required MasterDataController masterData,
    required double paddingBawah,
  }) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Cari nama produk...',
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: TemaAplikasi.warnaLatar,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (teks) {
                  transaksi.kataKunciPencarian.value = teks;
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 38,
                child: Obx(() {
                  final daftarKategori = masterData.daftarKategori;
                  final terpilih = transaksi.idKategoriTerpilih.value;

                  return ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: const Text('Semua'),
                          selected: terpilih == 'semua',
                          selectedColor: TemaAplikasi.warnaUtama,
                          labelStyle: TextStyle(
                            color: terpilih == 'semua'
                                ? Colors.white
                                : TemaAplikasi.warnaTeksGelap,
                            fontWeight: FontWeight.w500,
                          ),
                          onSelected: (_) {
                            transaksi.idKategoriTerpilih.value = 'semua';
                          },
                        ),
                      ),
                      ...daftarKategori.map((kat) {
                        final sedangDipilih = terpilih == kat.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(kat.nama),
                            selected: sedangDipilih,
                            selectedColor: TemaAplikasi.warnaUtama,
                            labelStyle: TextStyle(
                              color: sedangDipilih
                                  ? Colors.white
                                  : TemaAplikasi.warnaTeksGelap,
                              fontWeight: FontWeight.w500,
                            ),
                            onSelected: (_) {
                              transaksi.idKategoriTerpilih.value = kat.id;
                            },
                          ),
                        );
                      }),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
        Obx(() {
          final jumlahMenipis = masterData.daftarProdukStokMenipis.length;
          final jumlahHabis = masterData.daftarProdukStokHabis.length;
          if (jumlahMenipis == 0 && jumlahHabis == 0) {
            return const SizedBox.shrink();
          }

          return Container(
            width: double.infinity,
            color: const Color(0xFFFFF8E1),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: TemaAplikasi.warnaPeringatan,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Perhatian stok: $jumlahMenipis produk menipis, $jumlahHabis produk habis.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF92400E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        Expanded(
          child: Obx(() {
            final daftarProduk = transaksi.daftarProdukTersaring;
            final _ = transaksi.totalJumlahItemKeranjang;

            if (daftarProduk.isEmpty) {
              return const Center(
                child: Text(
                  'Tidak ada produk yang cocok.',
                  style: TextStyle(color: TemaAplikasi.warnaTeksAbu),
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, batasan) {
                final jumlahKolom = ResponsifHelper.jumlahKolomKasir(
                  batasan.maxWidth,
                );

                return GridView.builder(
                  padding: EdgeInsets.fromLTRB(14, 14, 14, paddingBawah),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: jumlahKolom,
                    mainAxisExtent: 222,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: daftarProduk.length,
                  itemBuilder: (context, indeks) {
                    final produk = daftarProduk[indeks];
                    return _kartuProduk(
                      context: context,
                      produk: produk,
                      masterData: masterData,
                      transaksi: transaksi,
                    );
                  },
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _kartuProduk({
    required BuildContext context,
    required ProdukModel produk,
    required MasterDataController masterData,
    required TransaksiController transaksi,
  }) {
    final jumlahDiKeranjang = transaksi.hitungPemakaianProdukDiKeranjang(
      produk.id,
    );
    final sisaStok = transaksi.sisaStokProdukTersedia(produk);
    final stokHabis = sisaStok <= 0;
    final stokMenipis = !stokHabis && masterData.apakahStokMenipis(sisaStok);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: stokHabis
            ? () {
                final pesan = produk.stok <= 0
                    ? 'Produk "${produk.nama}" sedang habis.'
                    : 'Stok "${produk.nama}" (${produk.stok}) sudah terpakai semua di keranjang.';
                tampilkanNotifikasiPeringatan('Stok Tidak Cukup', pesan);
              }
            : () {
                if (produk.daftarIdTopping.isNotEmpty) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => PembungkusModalResponsif(
                      child: DialogToppingProduk(produk: produk),
                    ),
                  );
                } else {
                  transaksi.tambahKeKeranjang(
                    produk: produk,
                    daftarTopping: [],
                  );
                }
              },
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.grey.shade100,
                    alignment: Alignment.center,
                    child: tampilkanFotoProduk(
                      pathFoto: produk.pathFoto,
                      ukuran: double.infinity,
                      radius: 0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produk.nama,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatRupiah(produk.harga),
                        style: const TextStyle(
                          color: TemaAplikasi.warnaUtama,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            produk.stok <= 0
                                ? 'Stok Habis'
                                : (jumlahDiKeranjang > 0
                                      ? 'Sisa: $sisaStok/${produk.stok}'
                                      : 'Stok: ${produk.stok}'),
                            style: TextStyle(
                              fontSize: 11,
                              color: stokHabis
                                  ? TemaAplikasi.warnaBahaya
                                  : stokMenipis
                                  ? TemaAplikasi.warnaPeringatan
                                  : TemaAplikasi.warnaTeksAbu,
                              fontWeight: (stokHabis || stokMenipis)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          if (produk.daftarIdTopping.isNotEmpty)
                            const Icon(
                              Icons.extension_outlined,
                              size: 14,
                              color: Colors.deepPurple,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (stokMenipis)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: TemaAplikasi.warnaPeringatan,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 11,
                        color: Colors.white,
                      ),
                      SizedBox(width: 3),
                      Text(
                        'Menipis',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (jumlahDiKeranjang > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: TemaAplikasi.warnaSukses,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$jumlahDiKeranjang di keranjang',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (stokHabis)
              Positioned.fill(
                child: Container(color: Colors.white.withValues(alpha: 0.45)),
              ),
          ],
        ),
      ),
    );
  }
}
