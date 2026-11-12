import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobiledev/controllers/printer_controller.dart';
import 'package:mobiledev/data/models/transaksi_model.dart';
import 'package:mobiledev/utils/notifikasi_helper.dart';
import 'package:mobiledev/utils/tema_aplikasi.dart';

class DialogPrinterThermal extends GetView<PrinterController> {
  final TransaksiModel? transaksiUntukDicetak;

  const DialogPrinterThermal({super.key, this.transaksiUntukDicetak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Obx(() {
        final memindai = controller.sedangMemindai.value;
        final mencetak = controller.sedangMencetak.value;
        final macTerhubung = controller.macPrinterTerhubung.value;
        final namaTerhubung = controller.namaPrinterTerhubung.value;
        final daftar = controller.daftarPrinter;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.print_rounded, color: TemaAplikasi.warnaUtama),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Printer Thermal Bluetooth (ESC/POS)',
                    style: TextStyle(
                      fontSize: 16,
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
            if (macTerhubung != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.bluetooth_connected,
                      color: TemaAplikasi.warnaSukses,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Terhubung: $namaTerhubung',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            macTerhubung,
                            style: const TextStyle(
                              fontSize: 11,
                              color: TemaAplikasi.warnaTeksAbu,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: controller.putuskanPrinter,
                      child: const Text(
                        'Putus',
                        style: TextStyle(color: TemaAplikasi.warnaBahaya),
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ukuran Kertas:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: '58mm', label: Text('58 mm')),
                    ButtonSegment(value: '80mm', label: Text('80 mm')),
                  ],
                  selected: {controller.ukuranKertas.value},
                  onSelectionChanged: (setBaru) {
                    controller.aturUkuranKertas(setBaru.first);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: memindai ? null : controller.pindaiPrinterBluetooth,
              icon: memindai
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.bluetooth_searching_rounded),
              label: Text(
                memindai ? 'Memindai Perangkat...' : 'Pindai Printer Terpasang',
              ),
            ),
            const SizedBox(height: 10),
            if (daftar.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Tekan tombol pindai untuk menampilkan printer Bluetooth yang sudah dipasangkan (paired) di perangkat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: TemaAplikasi.warnaTeksAbu,
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: daftar.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, indeks) {
                    final perangkat = daftar[indeks];
                    final aktif = perangkat.macAdress == macTerhubung;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.print_outlined,
                        color: aktif
                            ? TemaAplikasi.warnaSukses
                            : TemaAplikasi.warnaUtama,
                      ),
                      title: Text(
                        perangkat.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        perangkat.macAdress,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: aktif
                          ? const Chip(
                              label: Text(
                                'Aktif',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                              backgroundColor: TemaAplikasi.warnaSukses,
                            )
                          : ElevatedButton(
                              onPressed: memindai
                                  ? null
                                  : () =>
                                        controller.hubungkanPrinter(perangkat),
                              child: const Text('Hubungkan'),
                            ),
                    );
                  },
                ),
              ),
            if (transaksiUntukDicetak != null) ...[
              const SizedBox(height: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TemaAplikasi.warnaSukses,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                onPressed: (macTerhubung == null || mencetak)
                    ? null
                    : () async {
                        final berhasil = await controller.cetakStruk(
                          transaksiUntukDicetak!,
                        );
                        if (berhasil) {
                          tutupRuteAktif();
                        }
                      },
                icon: mencetak
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.print_rounded),
                label: Text(
                  mencetak ? 'Mencetak...' : 'Cetak Struk Sekarang',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }
}
