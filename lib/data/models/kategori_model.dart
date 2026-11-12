class KategoriModel {
  final String id;
  final String nama;
  final String keterangan;

  KategoriModel({required this.id, required this.nama, this.keterangan = ''});

  factory KategoriModel.dariMap(Map<String, dynamic> peta) {
    return KategoriModel(
      id: peta['id'] ?? '',
      nama: peta['nama'] ?? '',
      keterangan: peta['keterangan'] ?? '',
    );
  }

  Map<String, dynamic> keMap() {
    return {'id': id, 'nama': nama, 'keterangan': keterangan};
  }

  KategoriModel salinDengan({String? id, String? nama, String? keterangan}) {
    return KategoriModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      keterangan: keterangan ?? this.keterangan,
    );
  }
}
