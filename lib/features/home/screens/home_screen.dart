import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/features/home/providers/home_provider.dart';
import 'package:smart_spend_app/constants/app_colors.dart';
import 'package:smart_spend_app/features/home/widgets/mis_compras.dart';
import 'package:smart_spend_app/models/compra_model.dart';

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

  Map<String, List<Compra>> _groupComprasByMonth(List<Compra> compras) {
    final Map<String, List<Compra>> groupedCompras = {};

    for (var compra in compras) {
      final String monthKey =
          '${compra.fecha.year}-${compra.fecha.month.toString().padLeft(2, '0')}';
      if (!groupedCompras.containsKey(monthKey)) {
        groupedCompras[monthKey] = [];
      }
      groupedCompras[monthKey]!.add(compra);
    }

    return groupedCompras;
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final groupedCompras = _groupComprasByMonth(homeState.compras);
    final currentMonthKey =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (homeState.isComprasSelected) {
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
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: groupedCompras.entries.map((entry) {
                    final monthKey = entry.key;
                    final compras = entry.value;

                    return Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent, // Eliminar líneas
                      ),
                      child: ExpansionTile(
                        title: Text(
                          _getMonthName(monthKey),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w400),
                        ),
                        initiallyExpanded: monthKey == currentMonthKey,
                        collapsedBackgroundColor: Colors.transparent,
                        backgroundColor: Colors.transparent,
                        children: [
                          SizedBox(
                            height: 190, // Altura fija para la lista horizontal
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: compras.length,
                              itemBuilder: (context, index) {
                                final compra = compras[index];
                                return ComprasCard(compra: compra);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Divider(color: AppColors.gray300),
              Padding(
                padding:
                    const EdgeInsets.only(top: 8.0, bottom: 16.0, right: 70),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total de Compras:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                    ),
                    Text(
                      'S/ ${_calculateTotalCompras(homeState.compras).toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w400),
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

  String _getMonthName(String monthKey) {
    final parts = monthKey.split('-');
    final year = parts[0];
    final month = int.parse(parts[1]);
    final monthNames = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return '${monthNames[month - 1]} $year';
  }

  double _calculateTotalCompras(List<Compra> compras) {
    return compras.fold(
        0.0,
        (total, compra) =>
            total +
            compra.detalles.fold(
                0.0, (detalleTotal, detalle) => detalleTotal + detalle.precio));
  }
}
