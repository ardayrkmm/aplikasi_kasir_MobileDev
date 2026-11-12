import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobiledev/controllers/master_form_controller.dart';
import 'package:mobiledev/data/models/produk_model.dart';
import 'package:mobiledev/utils/format_uang.dart';
import 'package:mobiledev/utils/gambar_produk_widget.dart';
import 'package:mobiledev/utils/responsif_helper.dart';
import 'package:mobiledev/utils/tema_aplikasi.dart';

class FormProdukView extends StatelessWidget {
  final ProdukModel? produkAwal;

  const FormProdukView({super.key, this.produkAwal});

  void _bukaDialogUrlGambar(BuildContext context, FormProdukController c) {
    final pathSaatIni = c.pathFoto.value;
    c.pengontrolUrlFoto.text =
        (pathSaatIni != null && pathSaatIni.startsWith('http'))
        ? pathSaatIni
        : '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Masukkan URL Gambar'),
        content: TextField(
          controller: c.pengontrolUrlFoto,
          decoration: const InputDecoration(
            labelText: 'Link Gambar',
            hintText: 'https://contoh.com/gambar.jpg',
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (c.gunakanUrlGambar(c.pengontrolUrlFoto.text)) {
                Navigator.pop(ctx);
              }
            },
            child: const Text('Pakai Gambar'),
          ),
        ],
      ),
    );
  }

  void _bukaPilihanUpload(BuildContext context, FormProdukController c) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      backgroundColor: Colors.transparent,
      builder: (ctx) => PembungkusModalResponsif(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Upload Gambar Produk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFEBF3FF),
                      child: Icon(
                        Icons.upload_file_rounded,
                        color: TemaAplikasi.warnaUtama,
                      ),
                    ),
                    title: const Text('Pilih File / Galeri'),
                    subtitle: const Text(
                      'Unggah foto dari penyimpanan perangkat/galeri',
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      c.ambilFoto(ImageSource.gallery);
                    },
                  ),
                  if (c.apakahMendukungKamera)
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE8F7F0),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: TemaAplikasi.warnaSukses,
                        ),
                      ),
                      title: const Text('Ambil Foto dari Kamera'),
                      subtitle: const Text('Potret produk secara langsung'),
                      onTap: () {
                        Navigator.pop(ctx);
                        c.ambilFoto(ImageSource.camera);
                      },
                    ),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFF3ECFF),
                      child: Icon(Icons.link_rounded, color: Colors.deepPurple),
                    ),
                    title: const Text('Gunakan Tautan URL Gambar'),
                    subtitle: const Text('Tempel link gambar (https://...)'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _bukaDialogUrlGambar(context, c);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lebar = MediaQuery.sizeOf(context).width;
    final duaKolom = lebar >= 720;

    return GetBuilder<FormProdukController>(
      init: FormProdukController(produkAwal),
      tag: 'produk_${produkAwal?.id ?? "baru"}',
      builder: (c) => Scaffold(
        appBar: AppBar(
          title: Text(c.sedangUbah ? 'Ubah Produk' : 'Tambah Produk'),
        ),
        body: Form(
          key: c.formKunci,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: duaKolom ? 960 : 600),
              child: duaKolom
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _bagianUploadFoto(context, c),
                                const SizedBox(height: 20),
                                ..._bagianInputUtama(c),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [..._bagianToppingDanSimpan(c)],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _bagianUploadFoto(context, c),
                        const SizedBox(height: 20),
                        ..._bagianInputUtama(c),
                        const SizedBox(height: 20),
                        ..._bagianToppingDanSimpan(c),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bagianUploadFoto(BuildContext context, FormProdukController c) {
    return Center(
      child: Obx(() {
        final path = c.pathFoto.value;
        final mengunggah = c.sedangMengunggahFoto.value;

        return Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: mengunggah ? null : () => _bukaPilihanUpload(context, c),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: TemaAplikasi.warnaUtama.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (path != null && path.isNotEmpty)
                      tampilkanFotoProduk(
                        pathFoto: path,
                        ukuran: 138,
                        radius: 14,
                      )
                    else
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 40,
                            color: TemaAplikasi.warnaUtama.withValues(
                              alpha: 0.75,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap untuk\nUpload Gambar',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: TemaAplikasi.warnaTeksAbu,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    if (mengunggah)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    const Positioned(
                      right: 6,
                      bottom: 6,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: TemaAplikasi.warnaUtama,
                        child: Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: mengunggah
                      ? null
                      : () => _bukaPilihanUpload(context, c),
                  icon: const Icon(Icons.upload_rounded, size: 18),
                  label: Text(path == null ? 'Upload Gambar' : 'Ganti Gambar'),
                ),
                OutlinedButton.icon(
                  onPressed: mengunggah
                      ? null
                      : () => c.ambilFoto(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: const Text('Pilih File'),
                ),
                if (path != null)
                  TextButton.icon(
                    onPressed: c.hapusFotoPilihan,
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: TemaAplikasi.warnaBahaya,
                    ),
                    label: const Text(
                      'Hapus',
                      style: TextStyle(color: TemaAplikasi.warnaBahaya),
                    ),
                  ),
              ],
            ),
          ],
        );
      }),
    );
  }

  List<Widget> _bagianInputUtama(FormProdukController c) {
    return [
      TextFormField(
        controller: c.pengontrolNama,
        decoration: const InputDecoration(
          labelText: 'Nama Produk',
          hintText: 'Contoh: Es Kopi Susu',
        ),
        validator: (nilai) {
          if (nilai == null || nilai.trim().isEmpty) {
            return 'Nama produk wajib diisi';
          }
          return null;
        },
      ),
      const SizedBox(height: 14),
      Obx(() {
        final kategoriTersedia = c.masterData.daftarKategori;
        if (kategoriTersedia.isEmpty) {
          return const Card(
            color: Color(0xFFFFF4E5),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Belum ada kategori. Tambahkan kategori terlebih dahulu di tab Kategori.',
                style: TextStyle(color: TemaAplikasi.warnaPeringatan),
              ),
            ),
          );
        }

        final idTerpilih = c.idKategoriTerpilih.value;
        final nilaiValid = kategoriTersedia.any((k) => k.id == idTerpilih)
            ? idTerpilih
            : kategoriTersedia.first.id;

        return DropdownButtonFormField<String>(
          initialValue: nilaiValid,
          decoration: const InputDecoration(labelText: 'Kategori Produk'),
          items: kategoriTersedia.map((kat) {
            return DropdownMenuItem<String>(
              value: kat.id,
              child: Text(kat.nama),
            );
          }).toList(),
          onChanged: c.ubahKategori,
        );
      }),
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: c.pengontrolHarga,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Harga Jual',
                prefixText: 'Rp ',
              ),
              validator: (nilai) {
                if (nilai == null || nilai.trim().isEmpty) {
                  return 'Harga wajib diisi';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: c.pengontrolStok,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Stok'),
              validator: (nilai) {
                if (nilai == null || nilai.trim().isEmpty) {
                  return 'Stok wajib diisi';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _bagianToppingDanSimpan(FormProdukController c) {
    return [
      const Text(
        'Tempelkan Add-on / Topping (Opsional)',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: TemaAplikasi.warnaTeksGelap,
        ),
      ),
      const SizedBox(height: 6),
      const Text(
        'Pilih add-on yang bisa ditambahkan pembeli saat memesan produk ini.',
        style: TextStyle(fontSize: 12, color: TemaAplikasi.warnaTeksAbu),
      ),
      const SizedBox(height: 8),
      Obx(() {
        final daftarTopping = c.masterData.daftarTopping;
        final terpilihDaftar = c.daftarIdToppingTerpilih.toList();

        if (daftarTopping.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Belum ada data add-on/topping.',
                style: TextStyle(color: TemaAplikasi.warnaTeksAbu),
              ),
            ),
          );
        }

        return Card(
          child: Column(
            children: daftarTopping.map((topping) {
              final terpilih = terpilihDaftar.contains(topping.id);
              return CheckboxListTile(
                value: terpilih,
                title: Text(topping.nama),
                subtitle: Text(
                  '+ ${formatRupiah(topping.hargaTambahan)}  •  Stok: ${topping.stok}',
                  style: const TextStyle(fontSize: 12),
                ),
                onChanged: (centang) =>
                    c.ubahPilihanTopping(topping.id, centang),
              );
            }).toList(),
          ),
        );
      }),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: c.simpanProduk,
        child: Text(
          c.sedangUbah ? 'Simpan Perubahan' : 'Simpan Produk',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    ];
  }
}
