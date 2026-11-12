import 'package:get/get.dart';

class BerandaController extends GetxController {
  final RxInt indeksTabAktif = 0.obs;

  void pilihTab(int indeks) {
    indeksTabAktif.value = indeks;
  }
}
