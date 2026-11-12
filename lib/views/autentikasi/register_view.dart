import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobiledev/controllers/autentikasi_controller.dart';
import 'package:mobiledev/utils/tema_aplikasi.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun Kasir')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: controller.formKunci,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Registrasi Akun Lokal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: TemaAplikasi.warnaTeksGelap,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Isi nama, username, dan password untuk mendaftar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: TemaAplikasi.warnaTeksAbu,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: controller.pengontrolNama,
                        decoration: const InputDecoration(
                          labelText: 'Nama',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (nilai) {
                          if (nilai == null || nilai.trim().isEmpty) {
                            return 'Nama wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: controller.pengontrolUsername,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (nilai) {
                          if (nilai == null || nilai.trim().isEmpty) {
                            return 'Username wajib diisi';
                          }
                          if (nilai.trim().length < 3) {
                            return 'Username minimal 3 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      Obx(() {
                        final tersembunyi =
                            controller.sembunyikanPassword.value;
                        return TextFormField(
                          controller: controller.pengontrolPassword,
                          obscureText: tersembunyi,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                tersembunyi
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: controller.ubahTampilanPassword,
                            ),
                          ),
                          validator: (nilai) {
                            if (nilai == null || nilai.isEmpty) {
                              return 'Password wajib diisi';
                            }
                            if (nilai.length < 4) {
                              return 'Password minimal 4 karakter';
                            }
                            return null;
                          },
                        );
                      }),
                      const SizedBox(height: 24),
                      Obx(() {
                        final memuat =
                            controller.autentikasi.sedangMemuat.value;
                        return ElevatedButton(
                          onPressed: memuat ? null : controller.tanganiDaftar,
                          child: memuat
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Daftar Sekarang',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
