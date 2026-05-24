import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Backups'),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(CloudBackupState state) {
    if (state.status == CloudBackupStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == CloudBackupStatus.error) {
      return Center(
        child: Text(state.message ?? 'Error desconocido'),
      );
    }

    if (state.history.isEmpty) {
      return const Center(
        child: Text('No hay backups guardados'),
      );
    }

    return ListView.builder(
      itemCount: state.history.length,
      itemBuilder: (context, index) {
        final snapshot = state.history[index] as Map<String, dynamic>;
        final createdAt = DateTime.parse(snapshot['createdAt'] as String);
        final compraCount = snapshot['compraCount'] as int? ?? 0;

        return ListTile(
          leading: const Icon(Icons.backup),
          title: Text('Backup ${index + 1}'),
          subtitle: Text(
            '${DateFormat('dd/MM/yyyy HH:mm').format(createdAt)} · $compraCount compras',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            context.push('/selective-restore', extra: snapshot);
          },
        );
      },
    );
  }
}
