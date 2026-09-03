import 'package:intl/intl.dart';

class Formatters {
  static String currency(double value, {String symbol = 'د.ل'}) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '${formatter.format(value)} $symbol';
  }

  static String integerCurrency(double value, {String symbol = 'د.ل'}) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return '${formatter.format(value)} $symbol';
  }

  static String date(DateTime date) {
    return DateFormat('yyyy/MM/dd', 'ar').format(date);
  }

  static String dateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'ar').format(date);
  }

  static String dateLong(DateTime date) {
    return DateFormat('EEEE, dd MMM yyyy', 'ar').format(date);
  }

  static String monthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'ar').format(date);
  }

  static String percentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  static String compact(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}

class Validators {
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال المبلغ';
    }
    final parsed = double.tryParse(value);
    if (parsed == null) {
      return 'مبلغ غير صحيح';
    }
    if (parsed <= 0) {
      return 'يجب أن يكون المبلغ أكبر من صفر';
    }
    return null;
  }

  static String? note(String? value) {
    if (value != null && value.length > 200) {
      return 'ملاحظة طويلة جدًا (أقصى 200 حرف)';
    }
    return null;
  }
}

class DateUtils {
  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59);

  static DateTime startOfMonth(DateTime date) =>
      DateTime(date.year, date.month, 1);

  static DateTime endOfMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0, 23, 59, 59);

  static DateTime startOfWeek(DateTime date) {
    final day = date.weekday;
    return startOfDay(date.subtract(Duration(days: day - 1)));
  }

  static DateTime endOfWeek(DateTime date) =>
      startOfWeek(date).add(const Duration(days: 6, hours: 23, minutes: 59));

  static DateTime addDays(DateTime date, int days) =>
      startOfDay(date).add(Duration(days: days));

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  static bool isSameWeek(DateTime a, DateTime b) =>
      startOfWeek(a).isAtSameMomentAs(startOfWeek(b));
}