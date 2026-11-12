import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobiledev/controllers/transaksi_controller.dart';
import 'package:mobiledev/utils/format_uang.dart';
import 'package:mobiledev/utils/notifikasi_helper.dart';
import 'package:mobiledev/utils/tema_aplikasi.dart';

class DialogDaftarBillTersimpan extends GetView<TransaksiController> {
  const DialogDaftarBillTersimpan({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                color: TemaAplikasi.warnaUtama,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Daftar Bill Tersimpan (Hold)',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: TemaAplikasi.warnaTeksGelap,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: tutupRuteAktif,
              ),
            ],
          ),
          const Divider(),
          Obx(() {
            final daftar = controller.daftarPesananTersimpan;
            if (daftar.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'Belum ada pesanan yang disimpan sementara.',
                    style: TextStyle(color: TemaAplikasi.warnaTeksAbu),
                  ),
                ),
              );
            }

            return Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: daftar.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, indeks) {
                  final pesanan = daftar[indeks];
                  final totalQty = pesanan.daftarItem.fold(
                    0,
                    (total, item) => total + item.jumlah,
                  );

                  return Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  pesanan.namaTagihan,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Text(
                                formatRupiah(pesanan.subtotal),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: TemaAplikasi.warnaUtama,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${formatTanggalWaktu(pesanan.waktuSimpan)}  •  $totalQty item',
                            style: const TextStyle(
                              fontSize: 11,
                              color: TemaAplikasi.warnaTeksAbu,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            pesanan.daftarItem
                                .map((i) => '${i.namaProduk} x${i.jumlah}')
                                .join(', '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => controller
                                    .hapusPesananTersimpan(pesanan.id),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: TemaAplikasi.warnaBahaya,
                                ),
                                label: const Text(
                                  'Hapus',
                                  style: TextStyle(
                                    color: TemaAplikasi.warnaBahaya,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  if (controller.keranjang.isNotEmpty) {
                                    final lanjut = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Ganti Keranjang?'),
                                        content: const Text(
                                          'Keranjang saat ini memiliki pesanan aktif. Ganti dengan bill tersimpan ini?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('Batal'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text('Lanjutkan'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (lanjut != true) return;
                                  }

                                  await controller.lanjutkanPesananTersimpan(
                                    pesanan,
                                  );
                                  tutupRuteAktif();
                                },
                                icon: const Icon(
                                  Icons.play_arrow_rounded,
                                  size: 18,
                                ),
                                label: const Text('Lanjutkan'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
