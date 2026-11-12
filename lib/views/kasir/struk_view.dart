import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobiledev/controllers/printer_controller.dart';
import 'package:mobiledev/data/models/transaksi_model.dart';
import 'package:mobiledev/utils/format_uang.dart';
import 'package:mobiledev/utils/notifikasi_helper.dart';
import 'package:mobiledev/utils/responsif_helper.dart';
import 'package:mobiledev/utils/tema_aplikasi.dart';
import 'package:mobiledev/views/kasir/dialog_printer_view.dart';

class StrukView extends StatelessWidget {
  final TransaksiModel transaksi;
  final bool dariRiwayat;

  const StrukView({
    super.key,
    required this.transaksi,
    this.dariRiwayat = false,
  });

  @override
  Widget build(BuildContext context) {
    final tabletLanskap = ResponsifHelper.apakahTabletLanskap(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Struk Pembayaran Digital'),
        automaticallyImplyLeading: dariRiwayat,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tabletLanskap ? 860 : 440),
            child: tabletLanskap
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: _kartuStruk()),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'Aksi Struk & Printer',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    ..._tombolAksi(context),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _kartuStruk(),
                      const SizedBox(height: 24),
                      ..._tombolAksi(context),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _kartuStruk() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            transaksi.namaToko,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: TemaAplikasi.warnaTeksGelap,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Bukti Pembayaran Transaksi Kasir',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: TemaAplikasi.warnaTeksAbu),
          ),
          const SizedBox(height: 16),
          _garisPutusPutus(),
          const SizedBox(height: 12),
          _barisInfo('No. Struk', transaksi.nomorStruk),
          const SizedBox(height: 4),
          _barisInfo('Waktu', formatTanggalWaktu(transaksi.waktu)),
          const SizedBox(height: 4),
          _barisInfo('Kasir', transaksi.namaKasir),
          const SizedBox(height: 12),
          _garisPutusPutus(),
          const SizedBox(height: 12),
          const Text(
            'Rincian Pesanan:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: TemaAplikasi.warnaTeksGelap,
            ),
          ),
          const SizedBox(height: 8),
          ...transaksi.daftarItem.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.namaProduk}  x${item.jumlah}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '@ ${formatRupiah(item.hargaProduk)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: TemaAplikasi.warnaTeksAbu,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        formatRupiah(item.totalHargaItem),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (item.daftarTopping.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 2),
                      child: Text(
                        '+ ${item.daftarTopping.map((t) => "${t.nama} (${formatRupiah(t.hargaTambahan)})").join(", ")}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: TemaAplikasi.warnaTeksAbu,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: 6),
          _garisPutusPutus(),
          const SizedBox(height: 12),
          _barisRingkasan('Subtotal', formatRupiah(transaksi.subtotal)),
          if (transaksi.potonganDiskon > 0) ...[
            const SizedBox(height: 4),
            _barisRingkasan(
              transaksi.jenisDiskon == 'persen'
                  ? 'Diskon (${transaksi.nilaiDiskonInput.toInt()}%)'
                  : 'Diskon Potongan',
              '- ${formatRupiah(transaksi.potonganDiskon)}',
              warnaTeks: TemaAplikasi.warnaBahaya,
            ),
          ],
          const SizedBox(height: 6),
          const Divider(),
          const SizedBox(height: 6),
          _barisRingkasan(
            'TOTAL AKHIR',
            formatRupiah(transaksi.totalAkhir),
            tebal: true,
            ukuran: 16,
            warnaTeks: TemaAplikasi.warnaUtama,
          ),
          const SizedBox(height: 8),
          _barisRingkasan(
            'Uang Diterima (Bayar)',
            formatRupiah(transaksi.uangDiterima),
          ),
          const SizedBox(height: 4),
          _barisRingkasan(
            'Kembalian',
            formatRupiah(transaksi.uangKembalian),
            tebal: true,
            warnaTeks: TemaAplikasi.warnaSukses,
          ),
          const SizedBox(height: 16),
          _garisPutusPutus(),
          const SizedBox(height: 16),
          const Text(
            'Terima kasih atas kunjungan Anda!\nBarang yang sudah dibeli tidak dapat ditukar.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: TemaAplikasi.warnaTeksAbu),
          ),
        ],
      ),
    );
  }

  List<Widget> _tombolAksi(BuildContext context) {
    return [
      if (Get.isRegistered<PrinterController>()) ...[
        Obx(() {
          final printer = Get.find<PrinterController>();
          final mencetak = printer.sedangMencetak.value;
          final terhubung = printer.macPrinterTerhubung.value != null;

          return OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: mencetak
                ? null
                : () {
                    if (terhubung) {
                      printer.cetakStruk(transaksi);
                    } else {
                      printer.pindaiPrinterBluetooth();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => PembungkusModalResponsif(
                          child: DialogPrinterThermal(
                            transaksiUntukDicetak: transaksi,
                          ),
                        ),
                      );
                    }
                  },
            icon: mencetak
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.print_rounded),
            label: Text(
              terhubung
                  ? 'Cetak Struk (${printer.namaPrinterTerhubung.value})'
                  : 'Cetak Struk Bluetooth (ESC/POS)',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          );
        }),
        const SizedBox(height: 12),
      ],
      if (!dariRiwayat)
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: () {
            Get.offAllNamed('/beranda');
          },
          icon: const Icon(Icons.point_of_sale_rounded),
          label: const Text(
            'Selesai & Transaksi Baru',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        )
      else
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: tutupRuteAktif,
          child: const Text('Kembali'),
        ),
    ];
  }

  Widget _barisInfo(String label, String nilai) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: TemaAplikasi.warnaTeksAbu,
          ),
        ),
        Text(
          nilai,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _barisRingkasan(
    String label,
    String nilai, {
    bool tebal = false,
    double ukuran = 13,
    Color? warnaTeks,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ukuran,
            fontWeight: tebal ? FontWeight.bold : FontWeight.normal,
            color: warnaTeks ?? TemaAplikasi.warnaTeksGelap,
          ),
        ),
        Text(
          nilai,
          style: TextStyle(
            fontSize: ukuran,
            fontWeight: tebal ? FontWeight.bold : FontWeight.w600,
            color: warnaTeks ?? TemaAplikasi.warnaTeksGelap,
          ),
        ),
      ],
    );
  }

  Widget _garisPutusPutus() {
    return LayoutBuilder(
      builder: (context, batasan) {
        final lebar = batasan.maxWidth;
        const lebarTitik = 5.0;
        const jarakTitik = 3.0;
        final jumlah = (lebar / (lebarTitik + jarakTitik)).floor();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(jumlah, (_) {
            return const SizedBox(
              width: lebarTitik,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.black26),
              ),
            );
          }),
        );
      },
    );
  }
}
