import 'dart:io';

import 'csv_export_result.dart';

class CsvExportService {
  static Future<CsvExportResult> download({
    required String csv,
    required String fileName,
  }) async {
    final file = File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}$fileName',
    );
    await file.writeAsString(csv, flush: true);

    return CsvExportResult(
      success: true,
      message: 'CSV berhasil disimpan.',
      path: file.path,
    );
  }
}
