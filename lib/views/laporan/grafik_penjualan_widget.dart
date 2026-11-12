import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobiledev/controllers/laporan_controller.dart';
import 'package:mobiledev/utils/format_uang.dart';
import 'package:mobiledev/utils/tema_aplikasi.dart';

class GrafikPenjualanWidget extends GetView<LaporanController> {
  const GrafikPenjualanWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final daftarData = controller.dataGrafikPenjualan;
      final indeksDipilih = controller.indeksBatangTerpilih.value;

      if (daftarData.isEmpty) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                'Belum ada data grafik untuk periode ini.',
                style: TextStyle(color: TemaAplikasi.warnaTeksAbu),
              ),
            ),
          ),
        );
      }

      final nilaiMaks = daftarData
          .map((d) => d.totalPendapatan)
          .fold<int>(0, math.max);

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Grafik Pendapatan Harian',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: TemaAplikasi.warnaTeksGelap,
                    ),
                  ),
                  Text(
                    'Maks: ${formatRupiah(nilaiMaks)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: TemaAplikasi.warnaTeksAbu,
                    ),
                  ),
                ],
              ),
              if (indeksDipilih >= 0 && indeksDipilih < daftarData.length) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: TemaAplikasi.warnaUtama.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${formatTanggalSingkat(daftarData[indeksDipilih].tanggal)}: '
                    '${formatRupiah(daftarData[indeksDipilih].totalPendapatan)} '
                    '(${daftarData[indeksDipilih].jumlahTransaksi} transaksi)',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: TemaAplikasi.warnaUtama,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                height: 155,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(daftarData.length, (indeks) {
                    final item = daftarData[indeks];
                    final rasio = nilaiMaks <= 0
                        ? 0.0
                        : (item.totalPendapatan / nilaiMaks).clamp(0.05, 1.0);
                    final terpilih = indeks == indeksDipilih;

                    return Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () => controller.pilihBatangGrafik(indeks),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                _singkatNominal(item.totalPendapatan),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: terpilih
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: terpilih
                                      ? TemaAplikasi.warnaUtama
                                      : TemaAplikasi.warnaTeksAbu,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Flexible(
                                child: FractionallySizedBox(
                                  heightFactor: rasio,
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    width: double.infinity,
                                    constraints: const BoxConstraints(
                                      minHeight: 8,
                                      maxWidth: 28,
                                    ),
                                    decoration: BoxDecoration(
                                      color: terpilih
                                          ? TemaAplikasi.warnaSukses
                                          : TemaAplikasi.warnaUtama,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(6),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.labelTanggal,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: terpilih
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: terpilih
                                      ? TemaAplikasi.warnaTeksGelap
                                      : TemaAplikasi.warnaTeksAbu,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  String _singkatNominal(int nilai) {
    if (nilai >= 1000000) {
      return '${(nilai / 1000000).toStringAsFixed(1)}jt';
    }
    if (nilai >= 1000) {
      return '${(nilai / 1000).round()}rb';
    }
    return '$nilai';
  }
}
