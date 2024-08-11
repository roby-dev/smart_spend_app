import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
            context.push('/compra-detalle');
            //ref.read(homeProvider.notifier).selectCompra(compra.id!);
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
              compra.nombresDetalles.isNotEmpty
                  ? compra.nombresDetalles.join('-')
                  : 'Aún se agregaron compras',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  color: AppColors.gray700),
            ),
            const SizedBox(
              height: 5,
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
