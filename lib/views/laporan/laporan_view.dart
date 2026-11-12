import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobiledev/controllers/laporan_controller.dart';
import 'package:mobiledev/controllers/master_data_controller.dart';
import 'package:mobiledev/data/models/transaksi_model.dart';
import 'package:mobiledev/utils/format_uang.dart';
import 'package:mobiledev/utils/responsif_helper.dart';
import 'package:mobiledev/utils/tema_aplikasi.dart';
import 'package:mobiledev/views/kasir/struk_view.dart';
import 'package:mobiledev/views/laporan/grafik_penjualan_widget.dart';

class LaporanView extends StatelessWidget {
  const LaporanView({super.key});

  Future<void> _pilihRentangTanggal(
    BuildContext context,
    LaporanController laporan,
  ) async {
    final sekarang = DateTime.now();
    final rentangAwal =
        laporan.rentangTanggalKustom.value ??
        DateTimeRange(
          start: sekarang.subtract(const Duration(days: 6)),
          end: sekarang,
        );

    final hasil = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(sekarang.year + 1),
      initialDateRange: rentangAwal,
      helpText: 'Pilih Rentang Tanggal Laporan',
      saveText: 'Terapkan',
      cancelText: 'Batal',
    );

    if (hasil != null) {
      laporan.aturRentangKustom(hasil);
    }
  }

  @override
  Widget build(BuildContext context) {
    final LaporanController laporan = Get.find<LaporanController>();
    final MasterDataController masterData = Get.find<MasterDataController>();
    final tipe = ResponsifHelper.tentukanTipe(context);
    final lebar = MediaQuery.sizeOf(context).width;
    final apakahLebar = lebar >= 720;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard & Laporan Penjualan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan Laporan',
            onPressed: () => laporan.muatRiwayatTransaksi(),
          ),
        ],
      ),
      body: Obx(() {
        final totalPendapatan = laporan.totalPendapatan;
        final jumlahTransaksi = laporan.jumlahTransaksiSukses;
        final totalProdukTerjual = laporan.totalProdukTerjual;
        final rataRata = laporan.rataRataTransaksi;
        final totalDiskon = laporan.totalDiskonDiberikan;
        final daftarTransaksi = laporan.daftarTransaksiTersaring;
        final produkTerlaris = laporan.daftarProdukTerlaris;
        final periodeAktif = laporan.filterPeriode.value;
        final rentang = laporan.rentangTanggalKustom.value;

        final stokMenipis = masterData.daftarProdukStokMenipis;
        final stokHabis = masterData.daftarProdukStokHabis;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _chipPeriode(
                    label: 'Semua',
                    nilai: 'semua',
                    periodeAktif: periodeAktif,
                    padaPilih: laporan.aturFilterPeriode,
                  ),
                  _chipPeriode(
                    label: 'Hari Ini',
                    nilai: 'hari_ini',
                    periodeAktif: periodeAktif,
                    padaPilih: laporan.aturFilterPeriode,
                  ),
                  _chipPeriode(
                    label: '7 Hari',
                    nilai: '7_hari',
                    periodeAktif: periodeAktif,
                    padaPilih: laporan.aturFilterPeriode,
                  ),
                  _chipPeriode(
                    label: '30 Hari',
                    nilai: '30_hari',
                    periodeAktif: periodeAktif,
                    padaPilih: laporan.aturFilterPeriode,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      avatar: Icon(
                        Icons.date_range_outlined,
                        size: 16,
                        color: periodeAktif == 'kustom'
                            ? Colors.white
                            : TemaAplikasi.warnaUtama,
                      ),
                      backgroundColor: periodeAktif == 'kustom'
                          ? TemaAplikasi.warnaUtama
                          : Colors.white,
                      labelStyle: TextStyle(
                        color: periodeAktif == 'kustom'
                            ? Colors.white
                            : TemaAplikasi.warnaTeksGelap,
                        fontWeight: FontWeight.w500,
                      ),
                      label: Text(
                        periodeAktif == 'kustom' && rentang != null
                            ? '${formatTanggalSingkat(rentang.start)} - ${formatTanggalSingkat(rentang.end)}'
                            : 'Pilih Tanggal',
                      ),
                      onPressed: () => _pilihRentangTanggal(context, laporan),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            if (tipe == TipePerangkat.tabletLanskap)
              Row(
                children: [
                  Expanded(
                    child: _kartuMetrik(
                      judul: 'Pendapatan',
                      nilai: formatRupiah(totalPendapatan),
                      ikon: Icons.monetization_on_outlined,
                      warnaIkon: TemaAplikasi.warnaSukses,
                      warnaLatarIkon: Colors.green.shade50,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _kartuMetrik(
                      judul: 'Transaksi',
                      nilai: '$jumlahTransaksi',
                      ikon: Icons.receipt_long_outlined,
                      warnaIkon: TemaAplikasi.warnaUtama,
                      warnaLatarIkon: Colors.blue.shade50,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _kartuMetrik(
                      judul: 'Terjual',
                      nilai: '$totalProdukTerjual pcs',
                      ikon: Icons.shopping_bag_outlined,
                      warnaIkon: Colors.purple,
                      warnaLatarIkon: Colors.purple.shade50,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _kartuMetrik(
                      judul: 'Rata-rata',
                      nilai: formatRupiah(rataRata),
                      ikon: Icons.analytics_outlined,
                      warnaIkon: Colors.teal,
                      warnaLatarIkon: Colors.teal.shade50,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _kartuMetrik(
                      judul: 'Total Diskon',
                      nilai: formatRupiah(totalDiskon),
                      ikon: Icons.discount_outlined,
                      warnaIkon: TemaAplikasi.warnaPeringatan,
                      warnaLatarIkon: Colors.orange.shade50,
                    ),
                  ),
                ],
              )
            else ...[
              _kartuMetrik(
                judul: 'Total Pendapatan Bersih',
                nilai: formatRupiah(totalPendapatan),
                ikon: Icons.monetization_on_outlined,
                warnaIkon: TemaAplikasi.warnaSukses,
                warnaLatarIkon: Colors.green.shade50,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _kartuMetrik(
                      judul: 'Transaksi Sukses',
                      nilai: '$jumlahTransaksi',
                      ikon: Icons.receipt_long_outlined,
                      warnaIkon: TemaAplikasi.warnaUtama,
                      warnaLatarIkon: Colors.blue.shade50,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _kartuMetrik(
                      judul: 'Produk Terjual',
                      nilai: '$totalProdukTerjual pcs',
                      ikon: Icons.shopping_bag_outlined,
                      warnaIkon: Colors.purple,
                      warnaLatarIkon: Colors.purple.shade50,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _kartuMetrik(
                      judul: 'Rata-rata / Nota',
                      nilai: formatRupiah(rataRata),
                      ikon: Icons.analytics_outlined,
                      warnaIkon: Colors.teal,
                      warnaLatarIkon: Colors.teal.shade50,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _kartuMetrik(
                      judul: 'Total Diskon',
                      nilai: formatRupiah(totalDiskon),
                      ikon: Icons.discount_outlined,
                      warnaIkon: TemaAplikasi.warnaPeringatan,
                      warnaLatarIkon: Colors.orange.shade50,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),

            if (apakahLebar)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(flex: 6, child: GrafikPenjualanWidget()),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        if (produkTerlaris.isNotEmpty)
                          _kartuProdukTerlaris(produkTerlaris)
                        else
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                child: Text(
                                  'Belum ada produk terlaris.',
                                  style: TextStyle(
                                    color: TemaAplikasi.warnaTeksAbu,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              )
            else ...[
              const GrafikPenjualanWidget(),
              if (produkTerlaris.isNotEmpty) ...[
                const SizedBox(height: 16),
                _kartuProdukTerlaris(produkTerlaris),
              ],
            ],

            if (stokMenipis.isNotEmpty || stokHabis.isNotEmpty) ...[
              const SizedBox(height: 16),
              _kartuStokMenipis(stokMenipis, stokHabis),
            ],

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Riwayat Transaksi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TemaAplikasi.warnaTeksGelap,
                  ),
                ),
                Text(
                  '$jumlahTransaksi transaksi',
                  style: const TextStyle(
                    fontSize: 12,
                    color: TemaAplikasi.warnaTeksAbu,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (daftarTransaksi.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(28),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_outlined,
                          size: 48,
                          color: Colors.black26,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Belum ada transaksi pada rentang waktu ini.',
                          style: TextStyle(color: TemaAplikasi.warnaTeksAbu),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (apakahLebar)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 104,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: daftarTransaksi.length,
                itemBuilder: (context, indeks) {
                  return _kartuRiwayat(daftarTransaksi[indeks]);
                },
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: daftarTransaksi.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, indeks) {
                  return _kartuRiwayat(daftarTransaksi[indeks]);
                },
              ),
          ],
        );
      }),
    );
  }

  Widget _kartuProdukTerlaris(List<DataProdukTerlaris> produkTerlaris) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Produk Terlaris',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: TemaAplikasi.warnaTeksGelap,
              ),
            ),
            const SizedBox(height: 12),
            ...produkTerlaris.map((produk) {
              final maksQty = produkTerlaris.first.jumlahTerjual;
              final rasio = maksQty <= 0 ? 0.0 : produk.jumlahTerjual / maksQty;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            produk.namaProduk,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${produk.jumlahTerjual} terjual  •  ${formatRupiah(produk.totalOmzet)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: TemaAplikasi.warnaTeksAbu,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: rasio,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(4),
                      backgroundColor: Colors.grey.shade200,
                      color: TemaAplikasi.warnaUtama,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _kartuStokMenipis(List<dynamic> stokMenipis, List<dynamic> stokHabis) {
    return Card(
      color: const Color(0xFFFFFBF0),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: TemaAplikasi.warnaPeringatan,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Indikator Stok Menipis & Habis',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF92400E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...stokHabis.map(
                  (p) => Chip(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: Colors.red.shade50,
                    label: Text(
                      '${p.nama} (Habis)',
                      style: const TextStyle(
                        fontSize: 11,
                        color: TemaAplikasi.warnaBahaya,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                ...stokMenipis.map(
                  (p) => Chip(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: Colors.orange.shade50,
                    label: Text(
                      '${p.nama} (Sisa ${p.stok})',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFB45309),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _kartuRiwayat(TransaksiModel trx) {
    final totalQty = trx.daftarItem.fold(0, (total, i) => total + i.jumlah);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          foregroundColor: TemaAplikasi.warnaUtama,
          child: const Icon(Icons.receipt_rounded),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                trx.nomorStruk,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatRupiah(trx.totalAkhir),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: TemaAplikasi.warnaUtama,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Text(
              '${formatTanggalWaktu(trx.waktu)}  •  Kasir: ${trx.namaKasir}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: TemaAplikasi.warnaTeksAbu,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$totalQty item dibeli  •  Bayar: ${formatRupiah(trx.uangDiterima)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: () {
          Get.to(() => StrukView(transaksi: trx, dariRiwayat: true));
        },
      ),
    );
  }

  Widget _chipPeriode({
    required String label,
    required String nilai,
    required String periodeAktif,
    required void Function(String) padaPilih,
  }) {
    final dipilih = periodeAktif == nilai;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: dipilih,
        selectedColor: TemaAplikasi.warnaUtama,
        labelStyle: TextStyle(
          color: dipilih ? Colors.white : TemaAplikasi.warnaTeksGelap,
          fontWeight: FontWeight.w500,
        ),
        onSelected: (_) => padaPilih(nilai),
      ),
    );
  }

  Widget _kartuMetrik({
    required String judul,
    required String nilai,
    required IconData ikon,
    required Color warnaIkon,
    required Color warnaLatarIkon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: warnaLatarIkon,
              foregroundColor: warnaIkon,
              child: Icon(ikon, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    judul,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: TemaAplikasi.warnaTeksAbu,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nilai,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: TemaAplikasi.warnaTeksGelap,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
