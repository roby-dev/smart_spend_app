import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/constants/app_colors.dart';
import 'package:smart_spend_app/features/compra_detalle/providers/compra_detalle_provider.dart';
import 'package:smart_spend_app/features/compra_detalle/widgets/mis_compras_detalle.dart';
import 'package:smart_spend_app/features/home/providers/home_provider.dart';

class CompraDetalleScreen extends ConsumerStatefulWidget {
  const CompraDetalleScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      CompraDetalleScreenState();
}

class CompraDetalleScreenState extends ConsumerState<CompraDetalleScreen> {
  late TextEditingController _titleController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(compraDetalleProvider.notifier).initDatos();
    });

    final compra = ref.read(homeProvider).selectedCompra;
    _titleController = TextEditingController(text: compra?.titulo ?? '');
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        ref
            .read(compraDetalleProvider.notifier)
            .saveTitle(newTitle: _titleController.text.trim());
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compraDetalleState = ref.watch(compraDetalleProvider);

    // Calcular el total de los precios de los detalles de compra
    final double total =
        compraDetalleState.detalles.fold(0.0, (sum, item) => sum + item.precio);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            compraDetalleState.isDetallesSelected
                ? Text(
                    ref.read(compraDetalleProvider.notifier).tituloScreen(),
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.w200),
                  )
                : GestureDetector(
                    onTap: () {
                      _focusNode.requestFocus();
                    },
                    child: TextFormField(
                      controller: _titleController,
                      focusNode: _focusNode,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.gray500,
                            width: 2.0,
                          ),
                        ),
                      ),
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.w200),
                      // Se desactiva la edición directa para usar el detector de tap
                      enabled: true,
                    ),
                  ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    const Expanded(child: MisComprasDetalle()),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: AppColors.gray300,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: Text(
                        'S/ ${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await ref
              .read(compraDetalleProvider.notifier)
              .showAddDetalleDialog(context: context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
