import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/constants/app_colors.dart';
import 'package:smart_spend_app/features/home/providers/home_provider.dart';
import 'package:smart_spend_app/features/shared/utils/utils.dart';
import 'package:smart_spend_app/features/shared/widgets/checkbox_rounded.dart';
import 'package:smart_spend_app/models/compra_model.dart';

// class MisCompras extends ConsumerWidget {
//   final Compra compra;

//   const MisCompras({super.key, required this.compra});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final homeState = ref.watch(homeProvider);

//     return ListView.builder(
//       itemCount: homeState.compras.length,
//       itemBuilder: (context, index) {
//         final compra = homeState.compras[index];
//         return _ComprasCard(compra: compra);
//       },
//     );
//   }
// }

class ComprasCard extends ConsumerWidget {
  const ComprasCard({
    super.key,
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

    return GestureDetector(
      onTap: () async {
        if (isMultiSelectMode) {
          ref.read(homeProvider.notifier).toggleCompraSelection(compra.id!);
        } else {
          await ref.read(homeProvider.notifier).goDetalleCompra(compra: compra);
        }
      },
      onLongPress: () {
        ref.read(homeProvider.notifier).toggleComprasSelection();
        ref.read(homeProvider.notifier).toggleCompraSelection(compra.id!);
      },
      child: Card(
        elevation: 0,
        color: AppColors.white,
        child: Container(
          width: 270, // Ajustar ancho de las tarjetas
          padding: const EdgeInsets.all(16.0), // Añadir padding manualmente
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    compra.titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Subtítulo
                  Text(
                    nombresDetalles,
                    maxLines: 2, // Limitar a un máximo de dos líneas
                    overflow: TextOverflow.ellipsis, // Agregar "..."
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const Spacer(), // Empuja el total hacia abajo
                  // Total y fecha
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total: S/ ${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.gray700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Utils.FormattedDate(compraFecha: compra.fecha),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (isMultiSelectMode)
                Positioned(
                  top: -10,
                  right: -10,
                  child: RoundedCheckbox(
                    value: isSelected,
                    onChanged: (bool? value) {
                      ref
                          .read(homeProvider.notifier)
                          .toggleCompraSelection(compra.id!);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
