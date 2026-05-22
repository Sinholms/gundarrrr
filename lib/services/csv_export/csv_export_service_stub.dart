import 'csv_export_result.dart';

class CsvExportService {
  static Future<CsvExportResult> download({
    required String csv,
    required String fileName,
  }) async {
    return const CsvExportResult(
      success: false,
      message: 'Export CSV belum didukung di platform ini.',
    );
  }
}
