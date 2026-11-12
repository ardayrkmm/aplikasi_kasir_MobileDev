import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobiledev/controllers/transaksi_controller.dart';
import 'package:mobiledev/utils/format_uang.dart';
import 'package:mobiledev/utils/notifikasi_helper.dart';
import 'package:mobiledev/utils/tema_aplikasi.dart';
import 'package:mobiledev/views/kasir/struk_view.dart';

class PanelKeranjangWidget extends GetView<TransaksiController> {
  final bool modeSplitTablet;
  final bool modeDuaKolom;

  const PanelKeranjangWidget({
    super.key,
    this.modeSplitTablet = false,
    this.modeDuaKolom = false,
  });

  Future<void> _bayar() async {
    final transaksiBaru = await controller.prosesPembayaran();
    if (transaksiBaru != null) {
      if (modeSplitTablet) {
        Get.to(() => StrukView(transaksi: transaksiBaru));
      } else {
        Get.off(() => StrukView(transaksi: transaksiBaru));
      }
    }
  }

  void _bukaDialogSimpanBill(BuildContext context) {
    controller.pengontrolCatatanBill.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Simpan Bill Sementara'),
        content: TextField(
          controller: controller.pengontrolCatatanBill,
          decoration: const InputDecoration(
            labelText: 'Nama Pelanggan / Nomor Meja',
            hintText: 'Contoh: Meja 2 atau Pak Budi',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final berhasil = await controller.simpanPesananSementara(
                controller.pengontrolCatatanBill.text,
              );
              if (berhasil && !modeSplitTablet) {
                tutupRuteAktif();
              }
            },
            child: const Text('Simpan Bill'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.keranjang.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  size: 64,
                  color: Colors.black26,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Keranjang masih kosong',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: TemaAplikasi.warnaTeksAbu,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Pilih produk untuk mulai transaksi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: TemaAplikasi.warnaTeksAbu,
                  ),
                ),
                if (!modeSplitTablet) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: tutupRuteAktif,
                    child: const Text('Kembali ke Kasir'),
                  ),
                ],
              ],
            ),
          ),
        );
      }

      if (modeDuaKolom) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: ListView(
                  children: [
                    _judulDaftarPesanan(),
                    const SizedBox(height: 8),
                    _kartuDaftarItem(),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 5,
                child: ListView(
                  children: [
                    _kartuDiskon(),
                    const SizedBox(height: 16),
                    _kartuPembayaran(context),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      return ListView(
        padding: EdgeInsets.all(modeSplitTablet ? 12 : 16),
        children: [
          _judulDaftarPesanan(),
          const SizedBox(height: 8),
          _kartuDaftarItem(),
          const SizedBox(height: 14),
          _kartuDiskon(),
          const SizedBox(height: 14),
          _kartuPembayaran(context),
        ],
      );
    });
  }

  Widget _judulDaftarPesanan() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Daftar Pesanan',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        if (modeSplitTablet)
          TextButton.icon(
            onPressed: controller.kosongkanKeranjang,
            icon: const Icon(
              Icons.delete_sweep_outlined,
              size: 18,
              color: TemaAplikasi.warnaBahaya,
            ),
            label: const Text(
              'Bersihkan',
              style: TextStyle(color: TemaAplikasi.warnaBahaya, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _kartuDaftarItem() {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.keranjang.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, indeks) {
          final item = controller.keranjang[indeks];
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.produk.nama,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: TemaAplikasi.warnaBahaya,
                        size: 19,
                      ),
                      onPressed: () => controller.hapusItemKeranjang(indeks),
                    ),
                  ],
                ),
                if (item.daftarToppingTerpilih.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: item.daftarToppingTerpilih.map((t) {
                        return Chip(
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          padding: EdgeInsets.zero,
                          label: Text(
                            '+${t.nama}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '@ ${formatRupiah(item.hargaSatuanPlusTopping)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: TemaAplikasi.warnaUtama,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.remove_circle_outline, size: 19),
                      onPressed: () => controller.ubahJumlahItem(indeks, -1),
                    ),
                    Text(
                      '${item.jumlah}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.add_circle_outline, size: 19),
                      onPressed: () => controller.ubahJumlahItem(indeks, 1),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formatRupiah(item.totalHargaItem),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _kartuDiskon() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Diskon / Potongan Harga',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'nominal',
                        label: Text('Nominal (Rp)'),
                      ),
                      ButtonSegment(value: 'persen', label: Text('Persen (%)')),
                    ],
                    selected: {controller.jenisDiskon.value},
                    onSelectionChanged: (setBaru) {
                      controller.ubahJenisDiskon(setBaru.first);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller.pengontrolDiskon,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: controller.jenisDiskon.value == 'persen'
                    ? 'Nilai Diskon (Maksimal 100%)'
                    : 'Nominal Diskon (Maksimal ${formatRupiah(controller.subtotalKeranjang)})',
                prefixText: controller.jenisDiskon.value == 'nominal'
                    ? 'Rp '
                    : null,
                suffixText: controller.jenisDiskon.value == 'persen'
                    ? '%'
                    : null,
              ),
              onChanged: controller.ubahNilaiDiskonDariTeks,
            ),
            if (controller.pesanPeringatanDiskon.value.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                controller.pesanPeringatanDiskon.value,
                style: const TextStyle(
                  color: TemaAplikasi.warnaBahaya,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (controller.potonganDiskon > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Hemat: ${formatRupiah(controller.potonganDiskon)}',
                style: const TextStyle(
                  color: TemaAplikasi.warnaSukses,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _kartuPembayaran(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(child: Text('Subtotal:')),
                Text(formatRupiah(controller.subtotalKeranjang)),
              ],
            ),
            if (controller.potonganDiskon > 0) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Expanded(child: Text('Potongan Diskon:')),
                  Text(
                    '- ${formatRupiah(controller.potonganDiskon)}',
                    style: const TextStyle(color: TemaAplikasi.warnaBahaya),
                  ),
                ],
              ),
            ],
            const Divider(height: 18),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'TOTAL TAGIHAN:',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatRupiah(controller.totalTagihan),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TemaAplikasi.warnaUtama,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: controller.pengontrolUang,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Uang Diterima (Tunai)',
                prefixText: 'Rp ',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              onChanged: (teks) {
                final nominal = int.tryParse(teks) ?? 0;
                controller.aturUangDiterima(nominal);
              },
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ActionChip(
                  label: const Text('Uang Pas'),
                  onPressed: () =>
                      controller.aturNominalCepat(controller.totalTagihan),
                ),
                ActionChip(
                  label: const Text('Rp 10.000'),
                  onPressed: () => controller.aturNominalCepat(10000),
                ),
                ActionChip(
                  label: const Text('Rp 20.000'),
                  onPressed: () => controller.aturNominalCepat(20000),
                ),
                ActionChip(
                  label: const Text('Rp 50.000'),
                  onPressed: () => controller.aturNominalCepat(50000),
                ),
                ActionChip(
                  label: const Text('Rp 100.000'),
                  onPressed: () => controller.aturNominalCepat(100000),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: controller.uangKembalian >= 0
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: controller.uangKembalian >= 0
                      ? Colors.green.shade200
                      : Colors.red.shade200,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.uangKembalian >= 0
                          ? 'Kembalian:'
                          : 'Uang Kurang:',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: controller.uangKembalian >= 0
                            ? TemaAplikasi.warnaSukses
                            : TemaAplikasi.warnaBahaya,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatRupiah(controller.uangKembalian.abs()),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: controller.uangKembalian >= 0
                          ? TemaAplikasi.warnaSukses
                          : TemaAplikasi.warnaBahaya,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 13,
                        horizontal: 8,
                      ),
                    ),
                    onPressed: () => _bukaDialogSimpanBill(context),
                    child: const Text(
                      'Simpan Bill',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 13,
                        horizontal: 8,
                      ),
                    ),
                    onPressed: controller.uangKembalian >= 0 ? _bayar : null,
                    child: const Text(
                      'Bayar & Simpan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
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
}
