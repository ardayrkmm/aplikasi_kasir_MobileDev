import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobiledev/controllers/beranda_controller.dart';
import 'package:mobiledev/utils/responsif_helper.dart';
import 'package:mobiledev/utils/tema_aplikasi.dart';
import 'package:mobiledev/views/kasir/kasir_view.dart';
import 'package:mobiledev/views/laporan/laporan_view.dart';
import 'package:mobiledev/views/master/master_view.dart';

class BerandaView extends GetView<BerandaController> {
  const BerandaView({super.key});

  final List<Widget> _daftarHalaman = const [
    KasirView(),
    MasterView(),
    LaporanView(),
  ];

  @override
  Widget build(BuildContext context) {
    final tabletLanskap = ResponsifHelper.apakahTabletLanskap(context);
    final lebar = MediaQuery.sizeOf(context).width;

    return Obx(() {
      final indeksAktif = controller.indeksTabAktif.value;

      if (tabletLanskap) {
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: indeksAktif,
                extended: lebar >= 1140,
                backgroundColor: Colors.white,
                indicatorColor: TemaAplikasi.warnaUtama.withValues(alpha: 0.15),
                selectedIconTheme: const IconThemeData(
                  color: TemaAplikasi.warnaUtama,
                ),
                selectedLabelTextStyle: const TextStyle(
                  color: TemaAplikasi.warnaUtama,
                  fontWeight: FontWeight.bold,
                ),
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: TemaAplikasi.warnaUtama,
                    child: const Icon(
                      Icons.point_of_sale_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                onDestinationSelected: controller.pilihTab,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.point_of_sale_outlined),
                    selectedIcon: Icon(Icons.point_of_sale),
                    label: Text('Kasir'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.inventory_2_outlined),
                    selectedIcon: Icon(Icons.inventory_2),
                    label: Text('Master Data'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.analytics_outlined),
                    selectedIcon: Icon(Icons.analytics),
                    label: Text('Laporan'),
                  ),
                ],
              ),
              const VerticalDivider(width: 1, thickness: 1),
              Expanded(
                child: IndexedStack(
                  index: indeksAktif,
                  children: _daftarHalaman,
                ),
              ),
            ],
          ),
        );
      }

      return Scaffold(
        body: IndexedStack(index: indeksAktif, children: _daftarHalaman),
        bottomNavigationBar: NavigationBar(
          selectedIndex: indeksAktif,
          backgroundColor: Colors.white,
          indicatorColor: TemaAplikasi.warnaUtama.withValues(alpha: 0.15),
          onDestinationSelected: controller.pilihTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.point_of_sale_outlined),
              selectedIcon: Icon(
                Icons.point_of_sale,
                color: TemaAplikasi.warnaUtama,
              ),
              label: 'Kasir',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(
                Icons.inventory_2,
                color: TemaAplikasi.warnaUtama,
              ),
              label: 'Master Data',
            ),
            NavigationDestination(
              icon: Icon(Icons.analytics_outlined),
              selectedIcon: Icon(
                Icons.analytics,
                color: TemaAplikasi.warnaUtama,
              ),
              label: 'Laporan',
            ),
          ],
        ),
      );
    });
  }
}
