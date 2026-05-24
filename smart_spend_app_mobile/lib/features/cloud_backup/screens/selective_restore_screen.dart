import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_spend_app/features/cloud_backup/providers/cloud_backup_provider.dart';

class SelectiveRestoreScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> snapshot;

  const SelectiveRestoreScreen({super.key, required this.snapshot});

  @override
  ConsumerState<SelectiveRestoreScreen> createState() =>
      _SelectiveRestoreScreenState();
}

class _SelectiveRestoreScreenState
    extends ConsumerState<SelectiveRestoreScreen> {
  final Set<String> _selectedUuids = {};
  bool _selectAll = false;

  List<dynamic> get _compras =>
      (widget.snapshot['compras'] as List<dynamic>?) ?? [];

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      if (_selectAll) {
        _selectedUuids.addAll(
          _compras
              .where((c) => c['uuid'] != null)
              .map((c) => c['uuid'] as String),
        );
      } else {
        _selectedUuids.clear();
      }
    });
  }

  Future<void> _restore() async {
    final id = widget.snapshot['id'] as String?;
    if (id == null) return;

    final uuids = _selectedUuids.toList();
    final notifier = ref.read(cloudBackupProvider.notifier);

    final success = await notifier.restoreSelected(
      id,
      uuids: uuids.isNotEmpty ? uuids : null,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup restaurado exitosamente')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cloudBackupProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurar Backup'),
        actions: [
          TextButton(
            onPressed: _toggleSelectAll,
            child: Text(_selectAll ? 'Desmarcar todo' : 'Seleccionar todo'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _compras.length,
              itemBuilder: (context, index) {
                final compra = _compras[index] as Map<String, dynamic>;
                final uuid = compra['uuid'] as String?;
                final titulo = compra['titulo'] as String? ?? 'Sin título';
                final detallesCount =
                    (compra['detalles'] as List<dynamic>?)?.length ?? 0;

                return CheckboxListTile(
                  value: uuid != null && _selectedUuids.contains(uuid),
                  onChanged: uuid != null
                      ? (selected) {
                          setState(() {
                            if (selected == true) {
                              _selectedUuids.add(uuid);
                            } else {
                              _selectedUuids.remove(uuid);
                            }
                            _selectAll =
                                _selectedUuids.length == _compras.length;
                          });
                        }
                      : null,
                  title: Text(titulo),
                  subtitle: Text('$detallesCount detalles'),
                );
              },
            ),
          ),
          if (state.status == CloudBackupStatus.loading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          if (state.status == CloudBackupStatus.error)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                state.message ?? 'Error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: state.status == CloudBackupStatus.loading
                  ? null
                  : _restore,
              child: const Text('Restaurar seleccionados'),
            ),
          ),
        ],
      ),
    );
  }
}
