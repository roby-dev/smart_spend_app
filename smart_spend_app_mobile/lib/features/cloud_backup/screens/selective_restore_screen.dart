import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_spend_app/constants/app_colors.dart';
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
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cloudBackupProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Restaurar Backup',
                style: TextStyle(
                  color: AppColors.gray900,
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                ),
              ),
              TextButton(
                onPressed: _toggleSelectAll,
                child: Text(
                  _selectAll ? 'Desmarcar todo' : 'Seleccionar todo',
                  style: const TextStyle(color: AppColors.primary600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(child: _buildChecklist()),
          if (state.status == CloudBackupStatus.loading)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (state.status == CloudBackupStatus.error)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                state.message ?? 'Error',
                style:
                    const TextStyle(color: AppColors.error500, fontSize: 13),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  state.status == CloudBackupStatus.loading ? null : _restore,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary600,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                _selectedUuids.isEmpty
                    ? 'Restaurar todo'
                    : 'Restaurar ${_selectedUuids.length} seleccionadas',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklist() {
    if (_compras.isEmpty) {
      return const Center(
        child: Text(
          'No hay compras en este backup',
          style: TextStyle(color: AppColors.gray500, fontSize: 15),
        ),
      );
    }

    return ListView.builder(
      itemCount: _compras.length,
      itemBuilder: (context, index) {
        final compra = _compras[index] as Map<String, dynamic>;
        final uuid = compra['uuid'] as String?;
        final titulo = compra['titulo'] as String? ?? 'Sin título';
        final detallesCount =
            (compra['detalles'] as List<dynamic>?)?.length ?? 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.gray200),
          ),
          child: CheckboxListTile(
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
            activeColor: AppColors.primary600,
            title: Text(
              titulo,
              style: const TextStyle(
                color: AppColors.gray900,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '$detallesCount detalles',
              style: const TextStyle(color: AppColors.gray500, fontSize: 12),
            ),
          ),
        );
      },
    );
  }
}
