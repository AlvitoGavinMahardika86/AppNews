class DateFormatter {
  static const _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  static const _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static String? fullDateTime(String? value) {
    if (value == null) return null;
    final date = DateTime.tryParse(value)?.toLocal();
    if (date == null) return null;

    final day = _days[date.weekday - 1];
    final month = _months[date.month - 1];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day, ${date.day} $month ${date.year} pukul $hour:$minute';
  }
}
