import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/data/repositories/compra_repository_provider.dart';
import 'package:smart_spend_app/features/auth/providers/auth_provider.dart';
import 'package:smart_spend_app/features/cloud_backup/data/backup_remote_datasource.dart';
import 'package:smart_spend_app/features/home/providers/home_provider.dart';

enum CloudBackupStatus { idle, loading, success, error }

class CloudBackupState {
  final CloudBackupStatus status;
  final String? message;

  const CloudBackupState({this.status = CloudBackupStatus.idle, this.message});

  CloudBackupState copyWith({CloudBackupStatus? status, String? message}) =>
      CloudBackupState(status: status ?? this.status, message: message);
}

final cloudBackupProvider =
    NotifierProvider<CloudBackupNotifier, CloudBackupState>(
  () => CloudBackupNotifier(),
);

class CloudBackupNotifier extends Notifier<CloudBackupState> {
  @override
  CloudBackupState build() => const CloudBackupState();

  /// Uploads the full local export to the cloud. Triggers Google Sign-In if
  /// there is no active session. Returns true on success.
  Future<bool> backupNow() async {
    state = state.copyWith(status: CloudBackupStatus.loading, message: null);

    final authed = await ref.read(authProvider.notifier).ensureAuthenticated();
    if (!authed) {
      state = state.copyWith(
        status: CloudBackupStatus.idle,
        message: null,
      );
      return false;
    }

    try {
      final repo = ref.read(compraRepositoryProvider);
      final jsonString = await repo.exportToJson();
      final compras = jsonDecode(jsonString) as List<dynamic>;

      await ref.read(backupRemoteDatasourceProvider).saveBackup(compras);

      state = state.copyWith(
        status: CloudBackupStatus.success,
        message: 'Backup guardado en la nube',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: CloudBackupStatus.error,
        message: 'No se pudo hacer backup: $e',
      );
      return false;
    }
  }

  /// Downloads the cloud backup and imports it into the local database.
  /// Returns true on success.
  Future<bool> restoreNow() async {
    state = state.copyWith(status: CloudBackupStatus.loading, message: null);

    final authed = await ref.read(authProvider.notifier).ensureAuthenticated();
    if (!authed) {
      state = state.copyWith(status: CloudBackupStatus.idle, message: null);
      return false;
    }

    try {
      final compras =
          await ref.read(backupRemoteDatasourceProvider).getBackup();
      if (compras == null) {
        state = state.copyWith(
          status: CloudBackupStatus.error,
          message: 'No hay backup en la nube todavía',
        );
        return false;
      }

      final repo = ref.read(compraRepositoryProvider);
      await repo.importFromJson(jsonEncode(compras));
      await ref.read(homeProvider.notifier).loadCompras();

      state = state.copyWith(
        status: CloudBackupStatus.success,
        message: 'Backup restaurado',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: CloudBackupStatus.error,
        message: 'No se pudo restaurar: $e',
      );
      return false;
    }
  }
}
