import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobiledev/controllers/autentikasi_controller.dart';
import 'package:mobiledev/controllers/beranda_controller.dart';
import 'package:mobiledev/controllers/laporan_controller.dart';
import 'package:mobiledev/controllers/master_data_controller.dart';
import 'package:mobiledev/controllers/master_form_controller.dart';
import 'package:mobiledev/controllers/printer_controller.dart';
import 'package:mobiledev/controllers/transaksi_controller.dart';
import 'package:mobiledev/data/services/penyimpanan_service.dart';
import 'package:mobiledev/utils/tema_aplikasi.dart';
import 'package:mobiledev/views/autentikasi/login_view.dart';
import 'package:mobiledev/views/autentikasi/register_view.dart';
import 'package:mobiledev/views/beranda/beranda_view.dart';
import 'package:mobiledev/views/splash/splash_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Get.putAsync<PenyimpananService>(
    () => PenyimpananService().inisialisasi(),
  );

  Get.put<AutentikasiController>(AutentikasiController(), permanent: true);

  runApp(const AplikasiKasir());
}

class AplikasiKasir extends StatelessWidget {
  const AplikasiKasir({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Aplikasi Kasir',
      debugShowCheckedModeBanner: false,
      theme: TemaAplikasi.temaTerang,
      initialRoute: '/splash',
      getPages: [
        GetPage(
          name: '/splash',
          page: () => const SplashView(),
          binding: BindingsBuilder(() {
            Get.put<SplashController>(SplashController());
          }),
        ),
        GetPage(
          name: '/login',
          page: () => const LoginView(),
          binding: BindingsBuilder(() {
            Get.lazyPut<LoginController>(() => LoginController());
          }),
        ),
        GetPage(
          name: '/register',
          page: () => const RegisterView(),
          binding: BindingsBuilder(() {
            Get.lazyPut<RegisterController>(() => RegisterController());
          }),
        ),
        GetPage(
          name: '/beranda',
          page: () => const BerandaView(),
          binding: BindingsBuilder(() {
            Get.lazyPut<BerandaController>(
              () => BerandaController(),
              fenix: true,
            );
            Get.lazyPut<MasterDataController>(
              () => MasterDataController(),
              fenix: true,
            );
            Get.lazyPut<MasterTabController>(
              () => MasterTabController(),
              fenix: true,
            );
            Get.lazyPut<LaporanController>(
              () => LaporanController(),
              fenix: true,
            );
            Get.lazyPut<TransaksiController>(
              () => TransaksiController(),
              fenix: true,
            );
            Get.lazyPut<PrinterController>(
              () => PrinterController(),
              fenix: true,
            );
          }),
        ),
      ],
    );
  }
}
