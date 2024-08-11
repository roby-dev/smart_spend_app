import 'package:intl/intl.dart';

class Utils {
  static String FormattedDate({required DateTime compraFecha}) {
    final DateTime now = DateTime.now();
    if (DateFormat('yMd').format(compraFecha) ==
        DateFormat('yMd').format(now)) {
      // Si es hoy, mostrar la hora
      return DateFormat('hh:mm a').format(compraFecha);
    } else if (compraFecha.year == now.year) {
      // Si es este año, mostrar la fecha en formato "1 de agosto"
      return DateFormat('d \'de\' MMMM', 'es').format(compraFecha);
    } else {
      // Si es de otro año, mostrar la fecha con el año
      return DateFormat('d \'de\' MMMM \'de\' y', 'es').format(compraFecha);
    }
  }
}
