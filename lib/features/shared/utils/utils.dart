import 'package:intl/intl.dart';

class Utils {
  static String FormattedDate({required DateTime compraFecha}) {
    final DateTime now = DateTime.now();
    if (DateFormat('yMd').format(compraFecha) ==
        DateFormat('yMd').format(now)) {
      return DateFormat('hh:mm a').format(compraFecha);
    } else if (compraFecha.year == now.year) {
      return DateFormat('d \'de\' MMMM - hh:mm a', 'es').format(compraFecha);
    } else {
      return DateFormat('d \'de\' MMMM \'de\' y - hh:mm a', 'es')
          .format(compraFecha);
    }
  }
}
