import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobiledev/controllers/master_form_controller.dart';
import 'package:mobiledev/data/models/kategori_model.dart';
import 'package:mobiledev/utils/notifikasi_helper.dart';

class FormKategoriDialog extends StatelessWidget {
  final KategoriModel? kategoriAwal;

  const FormKategoriDialog({super.key, this.kategoriAwal});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FormKategoriController>(
      init: FormKategoriController(kategoriAwal),
      tag: 'kategori_${kategoriAwal?.id ?? "baru"}',
      builder: (c) => AlertDialog(
        title: Text(c.sedangUbah ? 'Ubah Kategori' : 'Tambah Kategori'),
        content: Form(
          key: c.formKunci,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: c.pengontrolNama,
                decoration: const InputDecoration(
                  labelText: 'Nama Kategori',
                  hintText: 'Contoh: Minuman, Makanan',
                ),
                validator: (nilai) {
                  if (nilai == null || nilai.trim().isEmpty) {
                    return 'Nama kategori wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: c.pengontrolKeterangan,
                decoration: const InputDecoration(
                  labelText: 'Keterangan (Opsional)',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: tutupRuteAktif, child: const Text('Batal')),
          ElevatedButton(
            onPressed: c.simpan,
            child: Text(c.sedangUbah ? 'Simpan' : 'Tambah'),
          ),
        ],
      ),
    );
  }
}
