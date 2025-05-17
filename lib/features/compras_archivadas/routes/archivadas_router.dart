import 'package:go_router/go_router.dart';
import 'package:smart_spend_app/config/router/app_router.dart';
import 'package:smart_spend_app/features/compras_archivadas/screens/compras_archivadas_screen.dart';

final archivadasRouter = GoRoute(
  path: '/archivadas',
  pageBuilder: defaultPageBuilder(
    child: const ComprasArchivadasScreen(),
  ),
);
