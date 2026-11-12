import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobiledev/controllers/dialog_topping_controller.dart';
import 'package:mobiledev/data/models/produk_model.dart';
import 'package:mobiledev/utils/format_uang.dart';
import 'package:mobiledev/utils/notifikasi_helper.dart';
import 'package:mobiledev/utils/tema_aplikasi.dart';

class DialogToppingProduk extends StatelessWidget {
  final ProdukModel produk;

  const DialogToppingProduk({super.key, required this.produk});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DialogToppingController>(
      init: DialogToppingController(produk),
      tag: 'dialog_topping_${produk.id}',
      builder: (c) {
        final daftarTopping = c.masterData.ambilToppingDariDaftarId(
          produk.daftarIdTopping,
        );

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          produk.nama,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: TemaAplikasi.warnaTeksGelap,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${formatRupiah(produk.harga)}  •  Sisa stok tersedia: ${c.sisaProduk}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: TemaAplikasi.warnaUtama,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: tutupRuteAktif,
                  ),
                ],
              ),
              const Divider(height: 24),
              const Text(
                'Pilih Add-on / Topping Tambahan:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: TemaAplikasi.warnaTeksGelap,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: daftarTopping.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, indeks) {
                    final topping = daftarTopping[indeks];
                    return Obx(() {
                      final apakahDipilih = c.toppingTerpilih.any(
                        (t) => t.id == topping.id,
                      );
                      final sisaTopping = c.transaksi.sisaStokToppingTersedia(
                        topping,
                      );
                      final stokHabis = sisaTopping <= 0;

                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: apakahDipilih,
                        title: Text(
                          topping.nama,
                          style: TextStyle(
                            fontWeight: apakahDipilih
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          stokHabis
                              ? '+ ${formatRupiah(topping.hargaTambahan)}  •  Stok habis/terpakai penuh di keranjang'
                              : '+ ${formatRupiah(topping.hargaTambahan)}  •  Sisa stok: $sisaTopping/${topping.stok}',
                          style: TextStyle(
                            fontSize: 12,
                            color: stokHabis
                                ? TemaAplikasi.warnaBahaya
                                : Colors.black54,
                          ),
                        ),
                        onChanged: stokHabis
                            ? null
                            : (centang) =>
                                  c.ubahPilihanTopping(topping, centang),
                      );
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              Obx(() {
                final jumlah = c.jumlahBeli.value;
                final maksimalBeli = c.maksimalBeliDiizinkan;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Jumlah Porsi:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: jumlah > 1 ? c.kurangiJumlah : null,
                            ),
                            Text(
                              '$jumlah',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: jumlah < maksimalBeli
                                  ? c.tambahJumlah
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: maksimalBeli <= 0 ? null : c.kirimKeKeranjang,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tambah ke Keranjang'),
                          Text(
                            formatRupiah(c.totalKeseluruhan),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
