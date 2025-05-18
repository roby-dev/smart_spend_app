import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/features/compras_archivadas/provider/archivadas_provider.dart';
import 'package:smart_spend_app/features/home/widgets/mis_compras.dart';

class ComprasArchivadasScreen extends ConsumerStatefulWidget {
  const ComprasArchivadasScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ComprasArchivadasScreenState();
}

class _ComprasArchivadasScreenState
    extends ConsumerState<ComprasArchivadasScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(archivadasProvider.notifier).loadArchivadas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(archivadasProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ' Listas Archivadas',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w200),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: state.compras.isEmpty
                  ? const Center(child: Text("No hay listas archivadas."))
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref
                            .read(archivadasProvider.notifier)
                            .loadArchivadas();
                      },
                      child: ListView.builder(
                        itemCount: state.compras.length,
                        itemBuilder: (context, index) {
                          final compra = state.compras[index];
                          return ComprasCard(compra: compra);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
