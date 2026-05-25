import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_spend_app/constants/app_colors.dart';
import 'package:smart_spend_app/features/cloud_backup/providers/cloud_backup_provider.dart';

class BackupHistoryScreen extends ConsumerStatefulWidget {
  const BackupHistoryScreen({super.key});

  @override
  ConsumerState<BackupHistoryScreen> createState() =>
      _BackupHistoryScreenState();
}

class _BackupHistoryScreenState extends ConsumerState<BackupHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cloudBackupProvider.notifier).loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cloudBackupProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historial de Backups',
            style: TextStyle(
              color: AppColors.gray900,
              fontSize: 28,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 18),
          Expanded(child: _buildBody(state)),
        ],
      ),
    );
  }

  Widget _buildBody(CloudBackupState state) {
    if (state.status == CloudBackupStatus.loading && state.history.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == CloudBackupStatus.error && state.history.isEmpty) {
      return Center(
        child: Text(
          state.message ?? 'Error desconocido',
          style: const TextStyle(color: AppColors.error500),
        ),
      );
    }

    if (state.history.isEmpty) {
      return const Center(
        child: Text(
          'No hay backups guardados',
          style: TextStyle(color: AppColors.gray500, fontSize: 15),
        ),
      );
    }

    return ListView.builder(
      itemCount: state.history.length,
      itemBuilder: (context, index) {
        final snapshot = state.history[index] as Map<String, dynamic>;
        final createdAt = DateTime.parse(snapshot['createdAt'] as String);
        final compraCount = snapshot['compraCount'] as int? ?? 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray200),
          ),
          child: ListTile(
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.backup,
                  color: AppColors.primary600, size: 21),
            ),
            title: Text(
              'Backup ${index + 1}',
              style: const TextStyle(
                color: AppColors.gray900,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${DateFormat('dd/MM/yyyy HH:mm').format(createdAt)} · $compraCount compras',
              style: const TextStyle(color: AppColors.gray500, fontSize: 12),
            ),
            trailing:
                const Icon(Icons.chevron_right, color: AppColors.gray500),
            onTap: () async {
              final id = snapshot['id'] as String;
              final success = await ref
                  .read(cloudBackupProvider.notifier)
                  .selectSnapshot(id);
              if (!context.mounted) return;
              if (success) {
                final fullSnapshot =
                    ref.read(cloudBackupProvider).selectedSnapshot;
                if (fullSnapshot != null) {
                  context.push('/selective-restore', extra: fullSnapshot);
                }
              }
            },
          ),
        );
      },
    );
  }
}
