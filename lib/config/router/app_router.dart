import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_spend_app/features/compra_detalle/routes/compra_detalle_router.dart';
import 'package:smart_spend_app/features/home/routes/home_router.dart';
import 'package:smart_spend_app/features/shared/layouts/layout_1.dart';
import 'package:smart_spend_app/features/shared/layouts/layout_2.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> mainShellNavigatorKey =
    GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  initialLocation: '/home',
  navigatorKey: rootNavigatorKey,
  routes: <RouteBase>[
    ShellRoute(
      builder: (context, state, child) => Layout1(child: child),
      routes: [homeRouter],
    ),
    ShellRoute(
        builder: (context, state, child) => Layout2(child: child),
        routes: [compraDetalleRouter],
        navigatorKey: mainShellNavigatorKey)
  ],
);

CustomTransitionPage transition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOutSine;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      var fadeTween = Tween(begin: 0.7, end: 1.0);
      var fadeAnimation = animation.drive(fadeTween);

      return FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(position: offsetAnimation, child: child),
      );
    },
  );
}

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
