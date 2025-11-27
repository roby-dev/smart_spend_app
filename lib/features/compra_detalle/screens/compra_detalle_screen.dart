import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/constants/app_colors.dart';
import 'package:smart_spend_app/features/compra_detalle/providers/compra_detalle_provider.dart';
import 'package:smart_spend_app/features/compra_detalle/widgets/mis_compras_detalle.dart';

class CompraDetalleScreen extends ConsumerStatefulWidget {
  const CompraDetalleScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      CompraDetalleScreenState();
}

class CompraDetalleScreenState extends ConsumerState<CompraDetalleScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _presupuestoController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _presupuestoFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(compraDetalleProvider.notifier).initDatos();
      final compra = ref.read(compraDetalleProvider).compra;
      _titleController.text = compra?.titulo ?? '';
      _presupuestoController.text = compra?.presupuesto?.toString() ?? '';

      _focusNode.addListener(() {
        if (!_focusNode.hasFocus) {
          ref
              .read(compraDetalleProvider.notifier)
              .saveTitle(newTitle: _titleController.text.trim());
        }
      });

      _presupuestoFocus.addListener(() {
        if (!_presupuestoFocus.hasFocus) {
          final text = _presupuestoController.text.trim();
          final valor = double.tryParse(text);
          ref.read(compraDetalleProvider.notifier).savePresupuesto(valor);
        }
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _presupuestoController.dispose();
    _focusNode.dispose();
    _presupuestoFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compraState = ref.watch(compraDetalleProvider);
    final compra = compraState.compra;
    final presupuesto = compra?.presupuesto;

    final total = compraState.detalles.fold<double>(
      0.0,
      (sum, item) => sum + item.precio,
    );

    final restante = presupuesto != null ? presupuesto - total : null;
    final sobrepasado = restante != null && restante < 0;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _focusNode.requestFocus(),
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
                  fontSize: 28,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),
            // 👇 Presupuesto debajo del título
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Presupuesto:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _presupuestoController,
                      focusNode: _presupuestoFocus,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: 'Agregue presupuesto',
                        hintStyle: const TextStyle(
                          fontWeight: FontWeight.w300,
                          color: AppColors.gray500,
                        ),
                        prefixText: presupuesto != null ? 'S/ ' : null,
                        prefixStyle: const TextStyle(
                          fontWeight: FontWeight.w300,
                          color: AppColors.gray700,
                        ),
                        isDense: true,
                        border: InputBorder.none,
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.gray500,
                            width: 1.0,
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w200,
                        color: AppColors.gray800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total: S/ ${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          if (presupuesto != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Restante: S/ ${restante!.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                  color: sobrepasado
                                      ? Colors.red
                                      : AppColors.gray600,
                                ),
                              ),
                            ),
                        ],
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
