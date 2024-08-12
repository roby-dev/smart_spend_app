import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/constants/app_colors.dart';
import 'package:smart_spend_app/features/home/providers/home_provider.dart';
import 'package:smart_spend_app/features/shared/utils/utils.dart';
import 'package:smart_spend_app/features/shared/widgets/checkbox_rounded.dart';
import 'package:smart_spend_app/models/compra_model.dart';

class MisCompras extends ConsumerWidget {
  const MisCompras({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);

    return ListView.builder(
      itemCount: homeState.compras.length,
      itemBuilder: (context, index) {
        final compra = homeState.compras[index];
        return _ComprasCard(compra: compra);
      },
    );
  }
}

class _ComprasCard extends ConsumerWidget {
  const _ComprasCard({
    required this.compra,
  });

  final Compra compra;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final isSelected = homeState.selectedCompras.contains(compra.id);
    final bool isMultiSelectMode = homeState.isComprasSelected;

    // Calcula el total de los precios de los detalles
    final double total = compra.detalles.fold(
      0.0,
      (sum, detalle) => sum + detalle.precio,
    );

    // Concatena los nombres de los detalles
    final String nombresDetalles = compra.detalles.isNotEmpty
        ? compra.detalles.map((detalle) => detalle.nombre).join(' - ')
        : 'Aún no se agregaron compras';

    return Card(
      elevation: 0,
      color: AppColors.white,
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(8.0), // Ajusta el radio según tu diseño
        ),
        onLongPress: () {
          ref.read(homeProvider.notifier).toggleComprasSelection();
          ref.read(homeProvider.notifier).toggleCompraSelection(compra.id!);
        },
        onTap: () {
          if (isMultiSelectMode) {
            ref.read(homeProvider.notifier).toggleCompraSelection(compra.id!);
          } else {
            ref.read(homeProvider.notifier).goDetalleCompra(compra: compra);
          }
        },
        contentPadding:
            const EdgeInsets.only(left: 20.0, right: 10.0, top: 10, bottom: 10),
        title: Text(
          compra.titulo,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 15,
            ),
            Text(
              nombresDetalles,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              'Total: S/ ${total.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: AppColors.gray700),
            ),
            Text(
              Utils.FormattedDate(compraFecha: compra.fecha),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: AppColors.gray500),
            ),
          ],
        ),
        minVerticalPadding: 10,
        trailing: isMultiSelectMode
            ? RoundedCheckbox(
                value: isSelected,
                onChanged: (bool? value) {
                  ref
                      .read(homeProvider.notifier)
                      .toggleCompraSelection(compra.id!);
                },
              )
            : null,
      ),
    );
  }
}
