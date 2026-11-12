import 'package:mobiledev/data/models/transaksi_model.dart';

class ItemPesananTersimpanModel {
  final String idProduk;
  final String namaProduk;
  final int hargaProduk;
  final int jumlah;
  final List<ToppingTersimpanModel> daftarTopping;
  final int totalHargaItem;

  ItemPesananTersimpanModel({
    required this.idProduk,
    required this.namaProduk,
    required this.hargaProduk,
    required this.jumlah,
    required this.daftarTopping,
    required this.totalHargaItem,
  });

  factory ItemPesananTersimpanModel.dariMap(Map<String, dynamic> peta) {
    return ItemPesananTersimpanModel(
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

class PesananTersimpanModel {
  final String id;
  final String namaTagihan;
  final DateTime waktuSimpan;
  final List<ItemPesananTersimpanModel> daftarItem;
  final String jenisDiskon;
  final double nilaiDiskonInput;
  final int subtotal;

  PesananTersimpanModel({
    required this.id,
    required this.namaTagihan,
    required this.waktuSimpan,
    required this.daftarItem,
    required this.jenisDiskon,
    required this.nilaiDiskonInput,
    required this.subtotal,
  });

  factory PesananTersimpanModel.dariMap(Map<String, dynamic> peta) {
    return PesananTersimpanModel(
      id: peta['id'] ?? '',
      namaTagihan: peta['namaTagihan'] ?? '',
      waktuSimpan:
          DateTime.tryParse(peta['waktuSimpan'] ?? '') ?? DateTime.now(),
      daftarItem: (peta['daftarItem'] as List? ?? [])
          .map(
            (item) => ItemPesananTersimpanModel.dariMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      jenisDiskon: peta['jenisDiskon'] ?? 'nominal',
      nilaiDiskonInput: (peta['nilaiDiskonInput'] ?? 0.0).toDouble(),
      subtotal: (peta['subtotal'] ?? 0) as int,
    );
  }

  Map<String, dynamic> keMap() {
    return {
      'id': id,
      'namaTagihan': namaTagihan,
      'waktuSimpan': waktuSimpan.toIso8601String(),
      'daftarItem': daftarItem.map((item) => item.keMap()).toList(),
      'jenisDiskon': jenisDiskon,
      'nilaiDiskonInput': nilaiDiskonInput,
      'subtotal': subtotal,
    };
  }
}
