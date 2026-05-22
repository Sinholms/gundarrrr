import '../models/sales_transaction.dart';
import 'transaction_history_service.dart';

class SalesReportService {
  SalesReportService._();

  static List<SalesTransaction> allTransactions() {
    return TransactionHistoryService.recentTransactions;
  }

  static List<SalesTransaction> todayTransactions() {
    final now = DateTime.now();
    return filterTransactions(
      startDate: DateTime(now.year, now.month, now.day),
      endDate: DateTime(now.year, now.month, now.day),
    );
  }

  static List<SalesTransaction> filterTransactions({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final transactions = allTransactions();
    if (startDate == null || endDate == null) return transactions;

    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    return transactions.where((transaction) {
      final date = transaction.dateTime;
      return !date.isBefore(start) && !date.isAfter(end);
    }).toList();
  }

  static SalesSummary summarize(List<SalesTransaction> transactions) {
    if (transactions.isEmpty) return SalesSummary.empty;

    return SalesSummary(
      totalRevenue: transactions.fold<int>(
        0,
        (sum, transaction) => sum + transaction.totalAmount,
      ),
      transactionCount: transactions.length,
      totalItemsSold: transactions.fold<int>(
        0,
        (sum, transaction) => sum + transaction.totalQuantity,
      ),
    );
  }

  static String buildCsv(List<SalesTransaction> transactions) {
    final rows = <List<Object?>>[
      [
        'Tanggal',
        'Jam',
        'ID Transaksi',
        'Nama Item',
        'Qty',
        'Harga Satuan',
        'Subtotal',
        'Metode Pembayaran',
        'Total Transaksi',
      ],
    ];

    for (final transaction in transactions) {
      for (final item in transaction.items) {
        rows.add([
          formatIsoDate(transaction.dateTime),
          transaction.time,
          transaction.transactionId,
          item.itemName,
          item.quantity,
          item.price,
          item.subtotal,
          transaction.paymentMethod,
          transaction.totalAmount,
        ]);
      }
    }

    return rows.map(_csvRow).join('\n');
  }

  static String csvFileName({DateTime? startDate, DateTime? endDate}) {
    if (startDate == null || endDate == null) {
      return 'report_penjualan_semua.csv';
    }

    return 'report_penjualan_${formatIsoDate(startDate)}_sampai_${formatIsoDate(endDate)}.csv';
  }

  static String formatIsoDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String formatReadableDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String _csvRow(List<Object?> values) {
    return values.map(_csvCell).join(',');
  }

  static String _csvCell(Object? value) {
    final text = value?.toString() ?? '';
    final mustQuote =
        text.contains(',') || text.contains('"') || text.contains('\n');
    if (!mustQuote) return text;
    return '"${text.replaceAll('"', '""')}"';
  }
}
