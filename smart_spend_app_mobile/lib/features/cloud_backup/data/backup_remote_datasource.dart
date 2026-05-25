import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/config/network/dio_client.dart';

class BackupRemoteDatasource {
  BackupRemoteDatasource(this._dio);

  final Dio _dio;

  Future<void> saveBackup(List<dynamic> compras, {String? name}) async {
    final data = <String, dynamic>{'compras': compras};
    if (name != null && name.trim().isNotEmpty) {
      data['name'] = name.trim();
    }
    await _dio.post<Map<String, dynamic>>(
      '/backup',
      data: data,
    );
  }

  /// Returns the stored compras list, or null when the user has no backup yet
  /// (backend responds 404).
  Future<List<dynamic>?> getBackup() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/backup');
      return res.data?['compras'] as List<dynamic>?;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Returns the list of backup snapshots for the current user.
  Future<List<dynamic>> getBackupHistory() async {
    final res = await _dio.get<List<dynamic>>('/backup/history');
    return res.data ?? [];
  }

  /// Returns a specific backup snapshot by id.
  Future<Map<String, dynamic>?> getBackupById(String id) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/backup/$id');
      return res.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Restores a backup snapshot. Optionally pass a list of compra UUIDs
  /// for selective restore.
  Future<List<dynamic>> restoreBackup(String id, {List<String>? uuids}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/backup/$id/restore',
      data: uuids != null && uuids.isNotEmpty
          ? {'comprasUuids': uuids}
          : <String, dynamic>{},
    );
    return res.data?['compras'] as List<dynamic>? ?? [];
  }
}

final backupRemoteDatasourceProvider = Provider<BackupRemoteDatasource>((ref) {
  return BackupRemoteDatasource(ref.watch(authedDioProvider));
});
