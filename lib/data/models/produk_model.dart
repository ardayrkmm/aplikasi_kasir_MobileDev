class ProdukModel {
  final String id;
  final String nama;
  final String idKategori;
  final int harga;
  final int stok;
  final String? pathFoto;
  final List<String> daftarIdTopping;

  ProdukModel({
    required this.id,
    required this.nama,
    required this.idKategori,
    required this.harga,
    required this.stok,
    this.pathFoto,
    this.daftarIdTopping = const [],
  });

  factory ProdukModel.dariMap(Map<String, dynamic> peta) {
    return ProdukModel(
      id: peta['id'] ?? '',
      nama: peta['nama'] ?? '',
      idKategori: peta['idKategori'] ?? '',
      harga: (peta['harga'] ?? 0) as int,
      stok: (peta['stok'] ?? 0) as int,
      pathFoto: peta['pathFoto'],
      daftarIdTopping: List<String>.from(peta['daftarIdTopping'] ?? []),
    );
  }

  Map<String, dynamic> keMap() {
    return {
      'id': id,
      'nama': nama,
      'idKategori': idKategori,
      'harga': harga,
      'stok': stok,
      'pathFoto': pathFoto,
      'daftarIdTopping': daftarIdTopping,
    };
  }

  ProdukModel salinDengan({
    String? id,
    String? nama,
    String? idKategori,
    int? harga,
    int? stok,
    String? pathFoto,
    List<String>? daftarIdTopping,
  }) {
    return ProdukModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      idKategori: idKategori ?? this.idKategori,
      harga: harga ?? this.harga,
      stok: stok ?? this.stok,
      pathFoto: pathFoto ?? this.pathFoto,
      daftarIdTopping: daftarIdTopping ?? this.daftarIdTopping,
    );
  }
}
