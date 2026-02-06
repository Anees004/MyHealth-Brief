import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../../core/errors/exceptions.dart';

/// Stores report files on the device only. No cloud upload.
/// Keeps health reports private and avoids compliance issues.
abstract class LocalReportStorage {
  /// Save report file locally. Returns path for optional "view original" later.
  Future<String> saveDocument({
    required String briefId,
    required File file,
    required bool isPdf,
  });

  /// Get local file path if the report is stored on this device.
  Future<String?> getLocalDocumentPath(String briefId);

  /// Delete local file when user deletes the brief.
  Future<void> deleteLocalDocument(String briefId);
}

/// Implementation using path_provider (app documents directory).
class LocalReportStorageImpl implements LocalReportStorage {
  static const String _reportsSubdir = 'reports';

  @override
  Future<String> saveDocument({
    required String briefId,
    required File file,
    required bool isPdf,
  }) async {
    try {
      final dir = await _reportsDirectory();
      final ext = isPdf ? 'pdf' : 'jpg';
      final path = '${dir.path}/$briefId.$ext';
      await file.copy(path);
      return path;
    } catch (e) {
      throw StorageException(
        message: 'Failed to save report locally: $e',
        code: 'local_save',
      );
    }
  }

  @override
  Future<String?> getLocalDocumentPath(String briefId) async {
    final dir = await _reportsDirectory();
    for (final ext in ['pdf', 'jpg', 'jpeg', 'png']) {
      final file = File('${dir.path}/$briefId.$ext');
      if (await file.exists()) return file.path;
    }
    return null;
  }

  @override
  Future<void> deleteLocalDocument(String briefId) async {
    try {
      final dir = await _reportsDirectory();
      for (final ext in ['pdf', 'jpg', 'jpeg', 'png']) {
        final file = File('${dir.path}/$briefId.$ext');
        if (await file.exists()) {
          await file.delete();
          return;
        }
      }
    } catch (_) {
      // Ignore if file not found or delete fails
    }
  }

  Future<Directory> _reportsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/$_reportsSubdir');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }
}