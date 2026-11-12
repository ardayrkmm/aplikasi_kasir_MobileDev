import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobiledev/data/services/penyimpanan_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const String _namaFolderFoto = 'foto_produk';

Future<String> salinFotoKePenyimpananPermanen(XFile sumberFoto) async {
  final baitFoto = await sumberFoto.readAsBytes();

  if (kIsWeb) {
    final namaLower = sumberFoto.name.toLowerCase();
    final tipeMime = namaLower.endsWith('.png')
        ? 'png'
        : namaLower.endsWith('.webp')
        ? 'webp'
        : 'jpeg';
    return 'data:image/$tipeMime;base64,${base64Encode(baitFoto)}';
  }

  final direktoriDokumen = await _ambilDirektoriDokumen();
  final folderTujuan = Directory(p.join(direktoriDokumen, _namaFolderFoto));
  if (!await folderTujuan.exists()) {
    await folderTujuan.create(recursive: true);
  }

  var ekstensi = p.extension(sumberFoto.path);
  if (ekstensi.isEmpty) {
    ekstensi = p.extension(sumberFoto.name);
  }
  if (ekstensi.isEmpty || ekstensi.length > 6) {
    ekstensi = '.jpg';
  }

  final namaBerkas = 'produk_${DateTime.now().millisecondsSinceEpoch}$ekstensi';
  final pathLengkapTujuan = p.join(folderTujuan.path, namaBerkas);

  await File(pathLengkapTujuan).writeAsBytes(baitFoto, flush: true);

  return '$_namaFolderFoto/$namaBerkas';
}

String? selesaikanPathFotoPermanen(String? pathTersimpan) {
  if (pathTersimpan == null || pathTersimpan.isEmpty) return null;
  if (pathTersimpan.startsWith('data:image') ||
      pathTersimpan.startsWith('http://') ||
      pathTersimpan.startsWith('https://')) {
    return pathTersimpan;
  }
  if (kIsWeb) return pathTersimpan;

  final berkasLangsung = File(pathTersimpan);
  if (berkasLangsung.isAbsolute && berkasLangsung.existsSync()) {
    return pathTersimpan;
  }

  if (Get.isRegistered<PenyimpananService>()) {
    final direktoriDokumen = Get.find<PenyimpananService>().direktoriDokumen;
    if (direktoriDokumen.isNotEmpty) {
      final pathGabungan = p.normalize(p.join(direktoriDokumen, pathTersimpan));
      if (File(pathGabungan).existsSync()) {
        return pathGabungan;
      }

      final pathNamaBerkas = p.normalize(
        p.join(direktoriDokumen, _namaFolderFoto, p.basename(pathTersimpan)),
      );
      if (File(pathNamaBerkas).existsSync()) {
        return pathNamaBerkas;
      }
    }
  }

  return null;
}

Future<void> hapusFotoPermanen(String? pathTersimpan) async {
  if (kIsWeb || pathTersimpan == null || pathTersimpan.isEmpty) return;
  if (pathTersimpan.startsWith('data:image') ||
      pathTersimpan.startsWith('http://') ||
      pathTersimpan.startsWith('https://')) {
    return;
  }

  final pathValid = selesaikanPathFotoPermanen(pathTersimpan);
  if (pathValid != null) {
    final berkas = File(pathValid);
    if (await berkas.exists()) {
      await berkas.delete();
    }
  }
}

Future<String> _ambilDirektoriDokumen() async {
  if (Get.isRegistered<PenyimpananService>()) {
    final cached = Get.find<PenyimpananService>().direktoriDokumen;
    if (cached.isNotEmpty) return cached;
  }
  final direktori = await getApplicationDocumentsDirectory();
  return direktori.path;
}
