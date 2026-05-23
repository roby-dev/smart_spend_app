import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/config/network/dio_client.dart';

class BackupRemoteDatasource {
  BackupRemoteDatasource(this._dio);

  final Dio _dio;

  Future<void> saveBackup(List<dynamic> compras) async {
    await _dio.post<Map<String, dynamic>>(
      '/backup',
      data: {'compras': compras},
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
}

final backupRemoteDatasourceProvider = Provider<BackupRemoteDatasource>((ref) {
  return BackupRemoteDatasource(ref.watch(authedDioProvider));
});
