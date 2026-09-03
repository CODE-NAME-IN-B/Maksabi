enum PeriodType { day, week, month, custom }

extension PeriodTypeX on PeriodType {
  String get arabicLabel {
    switch (this) {
      case PeriodType.day:
        return 'يومي';
      case PeriodType.week:
        return 'أسبوعي';
      case PeriodType.month:
        return 'شهري';
      case PeriodType.custom:
        return 'مخصص';
    }
  }

  String get shortLabel {
    switch (this) {
      case PeriodType.day:
        return 'يوم';
      case PeriodType.week:
        return 'أسبوع';
      case PeriodType.month:
        return 'شهر';
      case PeriodType.custom:
        return 'مخصص';
    }
  }
}