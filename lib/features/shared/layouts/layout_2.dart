import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/features/compra_detalle/providers/compra_detalle_provider.dart';
import 'package:smart_spend_app/features/shared/widgets/appbar_2.dart';

class Layout2 extends ConsumerStatefulWidget {
  const Layout2({
    super.key,
    required this.child,
    this.onBack,
  });

  final Widget child;
  final Future<void> Function()? onBack;

  @override
  Layout2State createState() => Layout2State();
}

class Layout2State extends ConsumerState<Layout2> {
  @override
  Widget build(BuildContext context) {
    final compraDetalleState = ref.watch(compraDetalleProvider);

    return Scaffold(
      appBar: MyAppBar2(
        isDetallesSelected: compraDetalleState.isDetallesSelected,
        onBack: widget.onBack,
        onCancel: () =>
            ref.read(compraDetalleProvider.notifier).toggleDetallesSelection(),
        onDelete: () =>
            ref.read(compraDetalleProvider.notifier).deleteSelectedDetalles(),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: widget.child,
            )
          ],
        ),
      ),
    );
  }
}
