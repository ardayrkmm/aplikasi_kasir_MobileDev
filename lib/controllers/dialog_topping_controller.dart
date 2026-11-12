import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:mobiledev/controllers/master_data_controller.dart';
import 'package:mobiledev/controllers/transaksi_controller.dart';
import 'package:mobiledev/data/models/produk_model.dart';
import 'package:mobiledev/data/models/topping_model.dart';
import 'package:mobiledev/utils/notifikasi_helper.dart';

class DialogToppingController extends GetxController {
  final ProdukModel produk;
  final MasterDataController masterData = Get.find<MasterDataController>();
  final TransaksiController transaksi = Get.find<TransaksiController>();

  final RxList<ToppingModel> toppingTerpilih = <ToppingModel>[].obs;
  final RxInt jumlahBeli = 1.obs;

  DialogToppingController(this.produk);

  int get sisaProduk => transaksi.sisaStokProdukTersedia(produk);

  int get maksimalBeliDiizinkan {
    var batas = sisaProduk;
    for (final topping in toppingTerpilih) {
      final sisaTopping = transaksi.sisaStokToppingTersedia(topping);
      batas = math.min(batas, sisaTopping);
    }
    return batas;
  }

  int get totalKeseluruhan {
    final hargaTambahan = toppingTerpilih.fold(
      0,
      (total, t) => total + t.hargaTambahan,
    );
    return (produk.harga + hargaTambahan) * jumlahBeli.value;
  }

  void ubahPilihanTopping(ToppingModel topping, bool? centang) {
    if (centang == true) {
      if (!toppingTerpilih.any((t) => t.id == topping.id)) {
        toppingTerpilih.add(topping);
      }
      final batasBaru = maksimalBeliDiizinkan;
      if (jumlahBeli.value > batasBaru && batasBaru > 0) {
        jumlahBeli.value = batasBaru;
      }
    } else {
      toppingTerpilih.removeWhere((t) => t.id == topping.id);
    }
  }

  void kurangiJumlah() {
    if (jumlahBeli.value > 1) {
      jumlahBeli.value--;
    }
  }

  void tambahJumlah() {
    if (jumlahBeli.value < maksimalBeliDiizinkan) {
      jumlahBeli.value++;
    }
  }

  void kirimKeKeranjang() {
    final sukses = transaksi.tambahKeKeranjang(
      produk: produk,
      daftarTopping: toppingTerpilih.toList(),
      jumlah: jumlahBeli.value,
    );
    if (sukses) {
      tutupRuteAktif();
    }
  }
}
