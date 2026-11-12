import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobiledev/utils/penyimpanan_foto.dart';
import 'package:mobiledev/utils/tema_aplikasi.dart';

Widget tampilkanFotoProduk({
  required String? pathFoto,
  double ukuran = 60,
  double radius = 8,
}) {
  final ukuranIkon = ukuran.isFinite ? ukuran * 0.45 : 44.0;

  if (pathFoto == null || pathFoto.isEmpty) {
    return _placeholderFoto(ukuran, ukuranIkon, radius);
  }

  if (pathFoto.startsWith('data:image')) {
    try {
      final bagianBase64 = pathFoto.split(',').last;
      final baitGambar = base64Decode(bagianBase64);
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.memory(
          baitGambar,
          width: ukuran,
          height: ukuran,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _placeholderFoto(ukuran, ukuranIkon, radius),
        ),
      );
    } catch (_) {
      return _placeholderFoto(ukuran, ukuranIkon, radius);
    }
  }

  if (kIsWeb ||
      pathFoto.startsWith('http://') ||
      pathFoto.startsWith('https://')) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        pathFoto,
        width: ukuran,
        height: ukuran,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _placeholderFoto(ukuran, ukuranIkon, radius),
      ),
    );
  }

  final pathValid = selesaikanPathFotoPermanen(pathFoto);
  if (pathValid == null) {
    return _placeholderFoto(ukuran, ukuranIkon, radius);
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Image.file(
      File(pathValid),
      width: ukuran,
      height: ukuran,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          _placeholderFoto(ukuran, ukuranIkon, radius),
    ),
  );
}

Widget _placeholderFoto(double ukuran, double ukuranIkon, double radius) {
  return Container(
    width: ukuran,
    height: ukuran,
    decoration: BoxDecoration(
      color: TemaAplikasi.warnaUtama.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(radius),
    ),
    child: Center(
      child: Icon(
        Icons.fastfood_rounded,
        size: ukuranIkon,
        color: TemaAplikasi.warnaUtama.withValues(alpha: 0.65),
      ),
    ),
  );
}
