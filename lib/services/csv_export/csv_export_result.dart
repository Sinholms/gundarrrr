class CsvExportResult {
  final bool success;
  final String message;
  final String? path;

  const CsvExportResult({
    required this.success,
    required this.message,
    this.path,
  });
}
