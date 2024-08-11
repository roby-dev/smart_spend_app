import 'package:flutter/material.dart';
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
    ref.read(homeProvider.notifier).loadCompras();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final isMultiSelectMode = homeState.isComprasSelected;

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
                height: 26,
              ),
              const Expanded(child: MisCompras()),
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
