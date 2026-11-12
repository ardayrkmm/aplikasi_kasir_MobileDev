class PenggunaModel {
  final String id;
  final String nama;
  final String namaPengguna;
  final String kataSandi;

  PenggunaModel({
    required this.id,
    required this.nama,
    required this.namaPengguna,
    required this.kataSandi,
  });

  factory PenggunaModel.dariMap(Map<String, dynamic> peta) {
    return PenggunaModel(
      id: peta['id'] ?? '',
      nama: peta['nama'] ?? peta['namaLengkap'] ?? '',
      namaPengguna: peta['namaPengguna'] ?? '',
      kataSandi: peta['kataSandi'] ?? '',
    );
  }

  Map<String, dynamic> keMap() {
    return {
      'id': id,
      'nama': nama,
      'namaPengguna': namaPengguna,
      'kataSandi': kataSandi,
    };
  }
}
