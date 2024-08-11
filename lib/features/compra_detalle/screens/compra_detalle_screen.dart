import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/constants/app_colors.dart';
import 'package:smart_spend_app/features/compra_detalle/widgets/mis_compras_detalle.dart';
import 'package:smart_spend_app/features/home/providers/home_provider.dart';

class CompraDetalleScreen extends ConsumerStatefulWidget {
  const CompraDetalleScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      CompraDetalleScrenState();
}

class CompraDetalleScrenState extends ConsumerState<CompraDetalleScreen> {
  @override
  Widget build(BuildContext context) {
    final compra = ref.watch(homeProvider).selectedCompra;

    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              compra!.titulo,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w200),
            ),
            const SizedBox(
              height: 26,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8.0)),
                child: const MisComprasDetalle(),
              ),
            ),
          ],
        ));
  }
}
