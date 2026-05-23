import 'package:go_router/go_router.dart';
import 'package:smart_spend_app/config/router/app_router.dart';
import 'package:smart_spend_app/features/compra_detalle/screens/compra_detalle_screen.dart';

final compraDetalleRouter = GoRoute(
  path: '/compra-detalle',
  pageBuilder: defaultPageBuilder(child: const CompraDetalleScreen()),
);
