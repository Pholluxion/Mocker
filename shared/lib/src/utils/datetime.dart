import 'package:intl/intl.dart';

abstract class XDateTime {
  static String get formatDateTime => DateFormat('yyyy-MM-dd HH:mm:ss').format(toUTC_5);
  static DateTime get toUTC_5 => DateTime.now().toUtc().subtract(Duration(hours: 5));
}
