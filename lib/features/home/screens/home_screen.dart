import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/features/home/providers/home_provider.dart';
import 'package:smart_spend_app/features/home/widgets/mis_compras.dart';

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
    final homeNotifier = ref.read(homeProvider.notifier);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              homeNotifier.tituloScreen(),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w200),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: homeState.compras.isEmpty
                  ? const Center(child: Text("No hay listas registradas."))
                  : homeState.isReordering
                      ? ReorderableListView.builder(
                          itemCount: homeState.compras.length,
                          onReorder: (oldIndex, newIndex) {
                            if (newIndex > oldIndex) newIndex -= 1;
                            final updated = [...homeState.compras];
                            final item = updated.removeAt(oldIndex);
                            updated.insert(newIndex, item);
                            ref
                                .read(homeProvider.notifier)
                                .updateOrdenCompras(updated);
                          },
                          itemBuilder: (context, index) {
                            final compra = homeState.compras[index];
                            return KeyedSubtree(
                              key: ValueKey(compra.id),
                              child: ComprasCard(
                                compra: compra,
                                disableLongPress: true,
                                enableShake: true,
                              ),
                            );
                          },
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            await ref.read(homeProvider.notifier).loadCompras();
                          },
                          child: ListView.builder(
                            itemCount: homeState.compras.length,
                            itemBuilder: (context, index) {
                              final compra = homeState.compras[index];
                              return ComprasCard(
                                compra: compra,
                                disableLongPress: false,
                                enableShake: false,
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: homeState.isReordering
          ? FloatingActionButton(
              tooltip: "Salir del modo mover",
              onPressed: () => homeNotifier.toggleReordering(),
              child: const Icon(Icons.close),
            )
          : FloatingActionButton(
              onPressed: () async {
                await homeNotifier.showAddEditCompraDialog(context: context);
              },
              child: const Icon(Icons.add),
            ),
    );
  }
}
