import 'package:mobiledev/data/models/produk_model.dart';
import 'package:mobiledev/data/models/topping_model.dart';

class ItemKeranjang {
  final ProdukModel produk;
  final List<ToppingModel> daftarToppingTerpilih;
  int jumlah;

  ItemKeranjang({
    required this.produk,
    required this.daftarToppingTerpilih,
    this.jumlah = 1,
  });

  int get totalHargaToppingPerUnit {
    return daftarToppingTerpilih.fold(
      0,
      (total, topping) => total + topping.hargaTambahan,
    );
  }

  int get hargaSatuanPlusTopping {
    return produk.harga + totalHargaToppingPerUnit;
  }

  int get totalHargaItem {
    return hargaSatuanPlusTopping * jumlah;
  }

  String get kunciUnik {
    final daftarIdToppingUrut = daftarToppingTerpilih.map((t) => t.id).toList()
      ..sort();
    return '${produk.id}_${daftarIdToppingUrut.join("-")}';
  }
}

class ToppingTersimpanModel {
  final String idTopping;
  final String nama;
  final int hargaTambahan;

  ToppingTersimpanModel({
    required this.idTopping,
    required this.nama,
    required this.hargaTambahan,
  });

  factory ToppingTersimpanModel.dariMap(Map<String, dynamic> peta) {
    return ToppingTersimpanModel(
      idTopping: peta['idTopping'] ?? '',
      nama: peta['nama'] ?? '',
      hargaTambahan: (peta['hargaTambahan'] ?? 0) as int,
    );
  }

  Map<String, dynamic> keMap() {
    return {
      'idTopping': idTopping,
      'nama': nama,
      'hargaTambahan': hargaTambahan,
    };
  }
}

class ItemTransaksiModel {
  final String idProduk;
  final String namaProduk;
  final int hargaProduk;
  final int jumlah;
  final List<ToppingTersimpanModel> daftarTopping;
  final int totalHargaItem;

  ItemTransaksiModel({
    required this.idProduk,
    required this.namaProduk,
    required this.hargaProduk,
    required this.jumlah,
    required this.daftarTopping,
    required this.totalHargaItem,
  });

  factory ItemTransaksiModel.dariMap(Map<String, dynamic> peta) {
    return ItemTransaksiModel(
      idProduk: peta['idProduk'] ?? '',
      namaProduk: peta['namaProduk'] ?? '',
      hargaProduk: (peta['hargaProduk'] ?? 0) as int,
      jumlah: (peta['jumlah'] ?? 1) as int,
      daftarTopping: (peta['daftarTopping'] as List? ?? [])
          .map(
            (item) =>
                ToppingTersimpanModel.dariMap(Map<String, dynamic>.from(item)),
          )
          .toList(),
      totalHargaItem: (peta['totalHargaItem'] ?? 0) as int,
    );
  }

  Map<String, dynamic> keMap() {
    return {
      'idProduk': idProduk,
      'namaProduk': namaProduk,
      'hargaProduk': hargaProduk,
      'jumlah': jumlah,
      'daftarTopping': daftarTopping.map((t) => t.keMap()).toList(),
      'totalHargaItem': totalHargaItem,
    };
  }
}

class TransaksiModel {
  final String id;
  final String nomorStruk;
  final DateTime waktu;
  final String namaToko;
  final String namaKasir;
  final List<ItemTransaksiModel> daftarItem;
  final int subtotal;
  final String jenisDiskon;
  final double nilaiDiskonInput;
  final int potonganDiskon;
  final int totalAkhir;
  final int uangDiterima;
  final int uangKembalian;

  TransaksiModel({
    required this.id,
    required this.nomorStruk,
    required this.waktu,
    required this.namaToko,
    required this.namaKasir,
    required this.daftarItem,
    required this.subtotal,
    required this.jenisDiskon,
    required this.nilaiDiskonInput,
    required this.potonganDiskon,
    required this.totalAkhir,
    required this.uangDiterima,
    required this.uangKembalian,
  });

  factory TransaksiModel.dariMap(Map<String, dynamic> peta) {
    return TransaksiModel(
      id: peta['id'] ?? '',
      nomorStruk: peta['nomorStruk'] ?? '',
      waktu: DateTime.tryParse(peta['waktu'] ?? '') ?? DateTime.now(),
      namaToko: peta['namaToko'] ?? '',
      namaKasir: peta['namaKasir'] ?? '',
      daftarItem: (peta['daftarItem'] as List? ?? [])
          .map(
            (item) =>
                ItemTransaksiModel.dariMap(Map<String, dynamic>.from(item)),
          )
          .toList(),
      subtotal: (peta['subtotal'] ?? 0) as int,
      jenisDiskon: peta['jenisDiskon'] ?? 'nominal',
      nilaiDiskonInput: (peta['nilaiDiskonInput'] ?? 0.0).toDouble(),
      potonganDiskon: (peta['potonganDiskon'] ?? 0) as int,
      totalAkhir: (peta['totalAkhir'] ?? 0) as int,
      uangDiterima: (peta['uangDiterima'] ?? 0) as int,
      uangKembalian: (peta['uangKembalian'] ?? 0) as int,
    );
  }

  Map<String, dynamic> keMap() {
    return {
      'id': id,
      'nomorStruk': nomorStruk,
      'waktu': waktu.toIso8601String(),
      'namaToko': namaToko,
      'namaKasir': namaKasir,
      'daftarItem': daftarItem.map((item) => item.keMap()).toList(),
      'subtotal': subtotal,
      'jenisDiskon': jenisDiskon,
      'nilaiDiskonInput': nilaiDiskonInput,
      'potonganDiskon': potonganDiskon,
      'totalAkhir': totalAkhir,
      'uangDiterima': uangDiterima,
      'uangKembalian': uangKembalian,
    };
  }
}
