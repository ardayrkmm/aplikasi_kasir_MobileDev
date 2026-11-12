import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobiledev/controllers/master_form_controller.dart';
import 'package:mobiledev/data/models/topping_model.dart';
import 'package:mobiledev/utils/notifikasi_helper.dart';

class FormToppingDialog extends StatelessWidget {
  final ToppingModel? toppingAwal;

  const FormToppingDialog({super.key, this.toppingAwal});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FormToppingController>(
      init: FormToppingController(toppingAwal),
      tag: 'topping_${toppingAwal?.id ?? "baru"}',
      builder: (c) => AlertDialog(
        title: Text(
          c.sedangUbah ? 'Ubah Add-on / Topping' : 'Tambah Add-on / Topping',
        ),
        content: Form(
          key: c.formKunci,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: c.pengontrolNama,
                  decoration: const InputDecoration(
                    labelText: 'Nama Add-on / Topping',
                    hintText: 'Contoh: Boba, Keju Parut',
                  ),
                  validator: (nilai) {
                    if (nilai == null || nilai.trim().isEmpty) {
                      return 'Nama add-on wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: c.pengontrolHarga,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Harga Tambahan (Rp)',
                    prefixText: 'Rp ',
                  ),
                  validator: (nilai) {
                    if (nilai == null || nilai.trim().isEmpty) {
                      return 'Harga tambahan wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: c.pengontrolStok,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Stok Tersedia'),
                  validator: (nilai) {
                    if (nilai == null || nilai.trim().isEmpty) {
                      return 'Stok wajib diisi';
                    }
                    return null;
                  },
                ),
              ],
            ),
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
