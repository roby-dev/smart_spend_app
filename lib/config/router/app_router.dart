import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_spend_app/features/compra_detalle/routes/compra_detalle_router.dart';
import 'package:smart_spend_app/features/compras_archivadas/routes/archivadas_router.dart';
import 'package:smart_spend_app/features/home/routes/home_router.dart';
import 'package:smart_spend_app/features/shared/layouts/bottom_nav_1.dart';
import 'package:smart_spend_app/features/shared/layouts/layout_2.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> mainShellNavigatorKey =
    GlobalKey<NavigatorState>();

// Guarda la última ruta visitada para saber si ir hacia la izquierda o derecha
String _lastLocation = '/home';

final appRouter = GoRouter(
  initialLocation: '/home',
  navigatorKey: rootNavigatorKey,
  routes: <RouteBase>[
    ShellRoute(
      builder: (context, state, child) => BottomNavLayout1(child: child),
      routes: [
        homeRouter,
        archivadasRouter,
      ],
    ),
    ShellRoute(
      builder: (context, state, child) => Layout2(child: child),
      routes: [
        compraDetalleRouter,
      ],
      navigatorKey: mainShellNavigatorKey,
    ),
  ],
);

/// Página con transición animada personalizada (izq/der dependiendo del orden)
CustomTransitionPage<T> transition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  // Usa state.uri.toString() en lugar de location (location NO existe en GoRouterState)
  final current = state.uri.toString();
  final isForward = _isForwardTransition(_lastLocation, current);
  _lastLocation = current;

  final beginOffset =
      isForward ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);

  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slideTween = Tween<Offset>(
        begin: beginOffset,
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));

      final fadeTween = Tween<double>(begin: 0.7, end: 1.0);

      return FadeTransition(
        opacity: animation.drive(fadeTween),
        child: SlideTransition(
          position: animation.drive(slideTween),
          child: child,
        ),
      );
    },
  );
}

/// Compara dos rutas para saber si la navegación fue hacia adelante o atrás
bool _isForwardTransition(String from, String to) {
  final order = ['/home', '/archivadas']; // Orden lógico de las tabs

  final fromIndex = order.indexOf(from);
  final toIndex = order.indexOf(to);

  return toIndex >= fromIndex;
}

/// Builder por defecto para usar la transición animada
Page<dynamic> Function(BuildContext, GoRouterState) defaultPageBuilder<T>({
  required Widget child,
  Brightness? brightness,
}) =>
    (BuildContext context, GoRouterState state) {
      return transition<T>(
        context: context,
        state: state,
        child: child,
      );
    };
