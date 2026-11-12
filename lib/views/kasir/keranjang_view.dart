import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobiledev/controllers/transaksi_controller.dart';
import 'package:mobiledev/views/kasir/panel_keranjang_widget.dart';

class KeranjangView extends GetView<TransaksiController> {
  const KeranjangView({super.key});

  @override
  Widget build(BuildContext context) {
    final lebar = MediaQuery.sizeOf(context).width;
    final duaKolom = lebar >= 720;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang & Pembayaran'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Kosongkan Keranjang',
            onPressed: () {
              if (controller.keranjang.isNotEmpty) {
                controller.kosongkanKeranjang();
              }
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: PanelKeranjangWidget(
            modeSplitTablet: false,
            modeDuaKolom: duaKolom,
          ),
        ),
      ),
    );
  }
}
