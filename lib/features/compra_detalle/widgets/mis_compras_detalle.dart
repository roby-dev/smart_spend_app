import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/constants/app_colors.dart';
import 'package:smart_spend_app/features/compra_detalle/providers/compra_detalle_provider.dart';
import 'package:smart_spend_app/models/compra_detalle_model.dart';

class CompraDetalle extends ConsumerWidget {
  const CompraDetalle({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compraDetalleState = ref.watch(compraDetalleProvider);

    return ListView.builder(
      itemCount: compraDetalleState.detalles.length,
      itemBuilder: (context, index) {
        final compraDetalle = compraDetalleState.detalles[index];
        return _ComprasDetalleCard(compra: compraDetalle);
      },
    );
  }
}

class _ComprasDetalleCard extends ConsumerWidget {
  const _ComprasDetalleCard({
    required this.compra,
  });

  final CompraDetalle compra;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      color: AppColors.white,
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(8.0), // Ajusta el radio según tu diseño
        ),
        onTap: () {
          //ref.read(homeProvider.notifier).goDetalleCompra(compra: compra);
        },
        contentPadding:
            const EdgeInsets.only(left: 20.0, right: 10.0, top: 10, bottom: 10),
        title: Text(
          compra.nombre,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 15,
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              compra.precio.toString(),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: AppColors.gray500),
            ),
          ],
        ),
        minVerticalPadding: 10,
      ),
    );
  }
}
