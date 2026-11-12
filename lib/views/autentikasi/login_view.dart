import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobiledev/controllers/autentikasi_controller.dart';
import 'package:mobiledev/utils/tema_aplikasi.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Login',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: TemaAplikasi.warnaTeksGelap,
                        ),
                      ),

                      const SizedBox(height: 24),
                      TextFormField(
                        controller: controller.pengontrolUsername,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (nilai) {
                          if (nilai == null || nilai.trim().isEmpty) {
                            return 'Username tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
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
                              return 'Password tidak boleh kosong';
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
                          onPressed: memuat ? null : controller.tanganiMasuk,
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
                                  'Masuk',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        );
                      }),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Belum punya akun?',
                            style: TextStyle(fontSize: 13),
                          ),
                          TextButton(
                            onPressed: () => Get.toNamed('/register'),
                            child: const Text(
                              'Daftar Baru',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: TemaAplikasi.warnaUtama,
                              ),
                            ),
                          ),
                        ],
                      ),
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
