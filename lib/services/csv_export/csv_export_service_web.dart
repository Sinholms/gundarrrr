import 'dart:convert';

import 'package:web/web.dart' as web;

import 'csv_export_result.dart';

class CsvExportService {
  static Future<CsvExportResult> download({
    required String csv,
    required String fileName,
  }) async {
    final encodedCsv = base64Encode(utf8.encode(csv));
    final anchor = web.HTMLAnchorElement()
      ..href = 'data:text/csv;charset=utf-8;base64,$encodedCsv'
      ..download = fileName
      ..style.display = 'none';

    web.document.body?.append(anchor);
    anchor.click();
    anchor.remove();

    return const CsvExportResult(
      success: true,
      message: 'CSV berhasil diunduh.',
    );
  }
}
