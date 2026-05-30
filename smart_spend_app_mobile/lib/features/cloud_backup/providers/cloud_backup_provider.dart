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
  final List<dynamic> history;
  final Map<String, dynamic>? selectedSnapshot;

  const CloudBackupState({
    this.status = CloudBackupStatus.idle,
    this.message,
    this.history = const [],
    this.selectedSnapshot,
  });

  CloudBackupState copyWith({
    CloudBackupStatus? status,
    String? message,
    List<dynamic>? history,
    Map<String, dynamic>? selectedSnapshot,
  }) =>
      CloudBackupState(
        status: status ?? this.status,
        message: message ?? this.message,
        history: history ?? this.history,
        selectedSnapshot: selectedSnapshot ?? this.selectedSnapshot,
      );
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
  Future<bool> backupNow({String? name}) async {
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

      await ref
          .read(backupRemoteDatasourceProvider)
          .saveBackup(compras, name: name);

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
      final result = await repo.importFromJson(jsonEncode(compras));
      await ref.read(homeProvider.notifier).loadCompras();

      state = state.copyWith(
        status: CloudBackupStatus.success,
        message: result.hasFailures
            ? 'Backup restaurado. No se pudieron importar: '
                '${result.failedTitulos.join(', ')}'
            : 'Backup restaurado',
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

  /// Loads the backup history for the current user.
  Future<bool> loadHistory() async {
    state = state.copyWith(status: CloudBackupStatus.loading, message: null);

    final authed = await ref.read(authProvider.notifier).ensureAuthenticated();
    if (!authed) {
      state = state.copyWith(status: CloudBackupStatus.idle, message: null);
      return false;
    }

    try {
      final history =
          await ref.read(backupRemoteDatasourceProvider).getBackupHistory();
      state = state.copyWith(
        status: CloudBackupStatus.success,
        history: history,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: CloudBackupStatus.error,
        message: 'No se pudo cargar el historial: $e',
      );
      return false;
    }
  }

  /// Fetches a specific backup snapshot by id.
  Future<bool> selectSnapshot(String id) async {
    state = state.copyWith(status: CloudBackupStatus.loading, message: null);

    final authed = await ref.read(authProvider.notifier).ensureAuthenticated();
    if (!authed) {
      state = state.copyWith(status: CloudBackupStatus.idle, message: null);
      return false;
    }

    try {
      final snapshot =
          await ref.read(backupRemoteDatasourceProvider).getBackupById(id);
      if (snapshot == null) {
        state = state.copyWith(
          status: CloudBackupStatus.error,
          message: 'Backup no encontrado',
        );
        return false;
      }

      state = state.copyWith(
        status: CloudBackupStatus.success,
        selectedSnapshot: snapshot,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: CloudBackupStatus.error,
        message: 'No se pudo cargar el backup: $e',
      );
      return false;
    }
  }

  /// Restores selected compras from a snapshot. If [uuids] is null or empty,
  /// restores all compras from the snapshot.
  Future<bool> restoreSelected(String id, {List<String>? uuids}) async {
    state = state.copyWith(status: CloudBackupStatus.loading, message: null);

    final authed = await ref.read(authProvider.notifier).ensureAuthenticated();
    if (!authed) {
      state = state.copyWith(status: CloudBackupStatus.idle, message: null);
      return false;
    }

    try {
      final compras = await ref
          .read(backupRemoteDatasourceProvider)
          .restoreBackup(id, uuids: uuids);

      final repo = ref.read(compraRepositoryProvider);
      final result = await repo.importFromJson(jsonEncode(compras));
      await ref.read(homeProvider.notifier).loadCompras();

      state = state.copyWith(
        status: CloudBackupStatus.success,
        message: result.hasFailures
            ? 'Backup restaurado. No se pudieron importar: '
                '${result.failedTitulos.join(', ')}'
            : 'Backup restaurado',
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
