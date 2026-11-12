import 'package:intl/intl.dart';

String formatRupiah(num nominal) {
  final pemisahRibuan = NumberFormat(
    '#,###',
    'en_US',
  ).format(nominal.round()).replaceAll(',', '.');
  return 'Rp $pemisahRibuan';
}

String formatTanggalWaktu(DateTime waktu) {
  const daftarBulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  final hari = waktu.day.toString().padLeft(2, '0');
  final bulan = daftarBulan[waktu.month - 1];
  final tahun = waktu.year;
  final jam = waktu.hour.toString().padLeft(2, '0');
  final menit = waktu.minute.toString().padLeft(2, '0');

  return '$hari $bulan $tahun, $jam:$menit';
}

String formatTanggalSingkat(DateTime waktu) {
  const daftarBulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  final hari = waktu.day.toString().padLeft(2, '0');
  final bulan = daftarBulan[waktu.month - 1];
  final tahun = waktu.year;

  return '$hari $bulan $tahun';
}
