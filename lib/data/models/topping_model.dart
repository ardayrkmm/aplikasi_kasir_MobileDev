class ToppingModel {
  final String id;
  final String nama;
  final int hargaTambahan;
  final int stok;

  ToppingModel({
    required this.id,
    required this.nama,
    required this.hargaTambahan,
    required this.stok,
  });

  factory ToppingModel.dariMap(Map<String, dynamic> peta) {
    return ToppingModel(
      id: peta['id'] ?? '',
      nama: peta['nama'] ?? '',
      hargaTambahan: (peta['hargaTambahan'] ?? 0) as int,
      stok: (peta['stok'] ?? 0) as int,
    );
  }

  Map<String, dynamic> keMap() {
    return {
      'id': id,
      'nama': nama,
      'hargaTambahan': hargaTambahan,
      'stok': stok,
    };
  }

  ToppingModel salinDengan({
    String? id,
    String? nama,
    int? hargaTambahan,
    int? stok,
  }) {
    return ToppingModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      hargaTambahan: hargaTambahan ?? this.hargaTambahan,
      stok: stok ?? this.stok,
    );
  }
}
