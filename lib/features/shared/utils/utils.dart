import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_spend_app/config/database/database_helper_drift.dart';

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

  static Future<void> exportAndShareJson(AppDatabase db) async {
    final json = await db.exportToJson();

    final directory = await getTemporaryDirectory();
    final now = DateTime.now();
    final fileName =
        'smart_spend_backup-${DateFormat('yyyy-MM-dd_HH-mm-ss').format(now)}.json';
    final file = File('${directory.path}/$fileName');

    await file.writeAsString(json);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: '📦 Aquí tienes el backup de SmartSpend',
    );
  }
}
