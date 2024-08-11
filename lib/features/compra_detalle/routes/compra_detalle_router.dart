import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_spend_app/features/compra_detalle/screens/compra_detalle_screen.dart';

final compraDetalleRouter = GoRoute(
  path: '/compra-detalle',
  pageBuilder: (context, state) {
    return transition(
      context: context,
      state: state,
      child: const CompraDetalleScreen(),
    );
  },
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
      const begin = Offset.zero;
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      animation.drive(tween);

      var scaleTween = Tween(begin: 0.8, end: 1.0);
      var scaleAnimation = animation.drive(scaleTween);

      return ScaleTransition(
        scale: scaleAnimation,
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}
