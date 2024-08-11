import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/features/home/providers/home_provider.dart';
import 'package:smart_spend_app/features/home/widgets/mis_compras.dart';
import 'package:smart_spend_app/constants/app_colors.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(homeProvider.notifier).loadCompras();
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final isMultiSelectMode = homeState.isComprasSelected;

    // Calcular el total de todas las compras
    final double totalCompras = homeState.compras.fold(
      0.0,
      (total, compra) =>
          total +
          compra.detalles.fold(
              0.0, (detalleTotal, detalle) => detalleTotal + detalle.precio),
    );

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (isMultiSelectMode) {
            ref.read(homeProvider.notifier).toggleComprasSelection();
          } else {
            ref.read(homeProvider.notifier).deselectCompra();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ref.read(homeProvider.notifier).tituloScreen(),
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.w200),
              ),
              const SizedBox(
                height: 16,
              ),
              const Expanded(child: MisCompras()),
              const Divider(color: AppColors.gray300),
              Padding(
                padding:
                    const EdgeInsets.only(top: 8.0, bottom: 16.0, right: 70),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total de Compras:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      'S/ ${totalCompras.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await ref
              .read(homeProvider.notifier)
              .showAddEditCompraDialog(context: context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
