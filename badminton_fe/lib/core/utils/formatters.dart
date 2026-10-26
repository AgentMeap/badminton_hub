/// Dinh dang tien Viet Nam (140.000đ) va ngay gio theo 01-kien-truc.md & 02-design-system.md.
class AppFormatters {
  AppFormatters._();

  /// Dinh dang so nguyen VND thanh chuoi co dau cham phan tach hang nghin, vi du: 140.000đ
  static String currencyVnd(int amount) {
    final isNegative = amount < 0;
    final digits = amount.abs().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    return '${isNegative ? '-' : ''}${buffer.toString()}đ';
  }

  /// Dinh dang khung gio tu gio bat dau, vi du: 18:00 - 19:00
  static String timeSlotRange(int startHour) {
    final start = startHour.toString().padLeft(2, '0');
    final end = (startHour + 1).toString().padLeft(2, '0');
    return '$start:00 - $end:00';
  }
}
