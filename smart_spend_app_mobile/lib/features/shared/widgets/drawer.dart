import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/constants/app_colors.dart';
import 'package:smart_spend_app/features/auth/providers/auth_provider.dart';
import 'package:smart_spend_app/features/cloud_backup/providers/cloud_backup_provider.dart';

class MyDrawer extends ConsumerWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupState = ref.watch(cloudBackupProvider);
    final isBusy = backupState.status == CloudBackupStatus.loading;
    final isSignedIn = ref.watch(authProvider).status == AuthStatus.signedIn;

    return Drawer(
      backgroundColor: AppColors.gray100,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.gray300),
            child: Text(
              'Menú',
              style: TextStyle(color: AppColors.gray900, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_upload, color: AppColors.black),
            title: const Text('Backup en la nube',
                style: TextStyle(color: AppColors.black)),
            enabled: !isBusy,
            onTap: () => _runBackup(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_download, color: AppColors.black),
            title: const Text('Restaurar desde la nube',
                style: TextStyle(color: AppColors.black)),
            enabled: !isBusy,
            onTap: () => _runRestore(context, ref),
          ),
          if (isBusy)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (isSignedIn) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.black),
              title: const Text('Cerrar sesión',
                  style: TextStyle(color: AppColors.black)),
              onTap: () async {
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _runBackup(BuildContext context, WidgetRef ref) async {
    await ref.read(cloudBackupProvider.notifier).backupNow();
    if (!context.mounted) return;
    _showResult(context, ref);
  }

  Future<void> _runRestore(BuildContext context, WidgetRef ref) async {
    await ref.read(cloudBackupProvider.notifier).restoreNow();
    if (!context.mounted) return;
    _showResult(context, ref);
  }

  void _showResult(BuildContext context, WidgetRef ref) {
    final state = ref.read(cloudBackupProvider);
    final message = state.message;
    if (message == null || !context.mounted) return;
    final isError = state.status == CloudBackupStatus.error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : null,
      ),
    );
  }
}
