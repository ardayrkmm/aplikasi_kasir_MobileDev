import 'package:flutter/material.dart';

enum TipePerangkat { ponsel, tabletPotret, tabletLanskap }

class ResponsifHelper {
  static TipePerangkat tentukanTipe(BuildContext context) {
    final ukuran = MediaQuery.sizeOf(context);
    final orientasi = MediaQuery.orientationOf(context);

    if (ukuran.width >= 840 && orientasi == Orientation.landscape) {
      return TipePerangkat.tabletLanskap;
    }
    if (ukuran.width >= 600) {
      return TipePerangkat.tabletPotret;
    }
    return TipePerangkat.ponsel;
  }

  static bool apakahPonsel(BuildContext context) {
    return tentukanTipe(context) == TipePerangkat.ponsel;
  }

  static bool apakahTabletPotret(BuildContext context) {
    return tentukanTipe(context) == TipePerangkat.tabletPotret;
  }

  static bool apakahTabletLanskap(BuildContext context) {
    return tentukanTipe(context) == TipePerangkat.tabletLanskap;
  }

  static int jumlahKolomKasir(double lebarAreaProduk) {
    if (lebarAreaProduk >= 900) return 4;
    if (lebarAreaProduk >= 560) return 3;
    return 2;
  }

  static int jumlahKolomMaster(BuildContext context) {
    final tipe = tentukanTipe(context);
    if (tipe == TipePerangkat.tabletLanskap) return 3;
    if (tipe == TipePerangkat.tabletPotret) return 2;
    return 1;
  }
}

class PembungkusModalResponsif extends StatelessWidget {
  final Widget child;
  final double lebarMaksimal;

  const PembungkusModalResponsif({
    super.key,
    required this.child,
    this.lebarMaksimal = 540,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: lebarMaksimal,
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        child: child,
      ),
    );
  }
}
