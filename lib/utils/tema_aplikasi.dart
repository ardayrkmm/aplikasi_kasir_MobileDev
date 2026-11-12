import 'package:flutter/material.dart';

class TemaAplikasi {
  static const Color warnaUtama = Color(0xFF1E56A0);
  static const Color warnaAksen = Color(0xFF163172);
  static const Color warnaLatar = Color(0xFFF6F8FC);
  static const Color warnaKartu = Colors.white;
  static const Color warnaSukses = Color(0xFF1E9E63);
  static const Color warnaPeringatan = Color(0xFFE68A00);
  static const Color warnaBahaya = Color(0xFFD63848);
  static const Color warnaTeksGelap = Color(0xFF1F2937);
  static const Color warnaTeksAbu = Color(0xFF6B7280);

  static ThemeData get temaTerang {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: warnaUtama,
        primary: warnaUtama,
        secondary: warnaAksen,
        surface: warnaKartu,
      ),
      scaffoldBackgroundColor: warnaLatar,
      appBarTheme: const AppBarTheme(
        backgroundColor: warnaUtama,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: warnaKartu,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: warnaUtama,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: warnaUtama, width: 1.5),
        ),
      ),
    );
  }
}
