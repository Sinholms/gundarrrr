import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/mock_data.dart';
import '../models/sales_transaction.dart';
import '../services/csv_export_service.dart';
import '../services/sales_report_service.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  DateTime? _activeStartDate;
  DateTime? _activeEndDate;
  bool _isExporting = false;

  bool get _hasActiveFilter =>
      _activeStartDate != null && _activeEndDate != null;

  List<SalesTransaction> get _filteredTransactions {
    return SalesReportService.filterTransactions(
      startDate: _activeStartDate,
      endDate: _activeEndDate,
    );
  }

  SalesSummary get _summary {
    return SalesReportService.summarize(_filteredTransactions);
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final currentValue = isStart ? _selectedStartDate : _selectedEndDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: currentValue ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        _selectedStartDate = picked;
        if (_selectedEndDate != null && _selectedEndDate!.isBefore(picked)) {
          _selectedEndDate = picked;
        }
      } else {
        _selectedEndDate = picked;
        if (_selectedStartDate != null &&
            picked.isBefore(_selectedStartDate!)) {
          _selectedStartDate = picked;
        }
      }
    });
  }

  void _applyFilter() {
    if (_selectedStartDate == null || _selectedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal mulai dan tanggal akhir.')),
      );
      return;
    }

    setState(() {
      _activeStartDate = _selectedStartDate;
      _activeEndDate = _selectedEndDate;
    });
  }

  void _resetFilter() {
    setState(() {
      _selectedStartDate = null;
      _selectedEndDate = null;
      _activeStartDate = null;
      _activeEndDate = null;
    });
  }

  Future<void> _downloadCsv() async {
    final transactions = _filteredTransactions;
    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belum ada data transaksi untuk diunduh.'),
        ),
      );
      return;
    }

    setState(() => _isExporting = true);
    try {
      final csv = SalesReportService.buildCsv(transactions);
      final fileName = SalesReportService.csvFileName(
        startDate: _activeStartDate,
        endDate: _activeEndDate,
      );
      final result = await CsvExportService.download(
        csv: csv,
        fileName: fileName,
      );

      if (!mounted) return;
      final pathSuffix = result.path == null ? '' : ' ${result.path}';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${result.message}$pathSuffix')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal export CSV: $error')));
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = _filteredTransactions;
    final summary = _summary;

    return Scaffold(
      appBar: AppBar(title: const Text('Report Penjualan')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _SummaryCard(summary: summary),
            const SizedBox(height: 16),
            _FilterCard(
              selectedStartDate: _selectedStartDate,
              selectedEndDate: _selectedEndDate,
              hasActiveFilter: _hasActiveFilter,
              onPickStart: () => _pickDate(isStart: true),
              onPickEnd: () => _pickDate(isStart: false),
              onApply: _applyFilter,
              onReset: _resetFilter,
            ),
            const SizedBox(height: 16),
            _ReportHeader(
              transactionCount: transactions.length,
              isExporting: _isExporting,
              canDownload: transactions.isNotEmpty,
              onDownload: _downloadCsv,
            ),
            const SizedBox(height: 10),
            if (transactions.isEmpty)
              const _EmptyReportState()
            else
              ...transactions.map((transaction) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TransactionCard(transaction: transaction),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final SalesSummary summary;

  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: WessLessTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ringkasan', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          Row(
            children: [
              _SummaryMetric(
                label: 'Total omzet',
                value: MockData.formatCurrency(summary.totalRevenue),
              ),
              const SizedBox(width: 10),
              _SummaryMetric(
                label: 'Transaksi',
                value: '${summary.transactionCount}',
              ),
              const SizedBox(width: 10),
              _SummaryMetric(
                label: 'Item terjual',
                value: '${summary.totalItemsSold}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isCurrencyValue = value.startsWith('Rp');

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: isCurrencyValue ? 13 : 18,
                  fontWeight: FontWeight.w900,
                ),
                maxLines: 1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _FilterCard extends StatelessWidget {
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final bool hasActiveFilter;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final VoidCallback onApply;
  final VoidCallback onReset;

  const _FilterCard({
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.hasActiveFilter,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onApply,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: WessLessTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Filter Tanggal',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (hasActiveFilter)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: WessLessTheme.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Aktif',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: WessLessTheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _DateSelector(
                  label: 'Mulai',
                  value: selectedStartDate,
                  onTap: onPickStart,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateSelector(
                  label: 'Akhir',
                  value: selectedEndDate,
                  onTap: onPickEnd,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onApply,
                  icon: const Icon(Icons.filter_alt_rounded, size: 18),
                  label: const Text('Terapkan Filter'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                onPressed: onReset,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Reset',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DateSelector({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? 'Pilih tanggal'
        : SalesReportService.formatReadableDate(value!);

    return Material(
      color: WessLessTheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                size: 18,
                color: WessLessTheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontSize: 10),
                    ),
                    Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: WessLessTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportHeader extends StatelessWidget {
  final int transactionCount;
  final bool isExporting;
  final bool canDownload;
  final VoidCallback onDownload;

  const _ReportHeader({
    required this.transactionCount,
    required this.isExporting,
    required this.canDownload,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Riwayat Transaksi',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 2),
              Text(
                '$transactionCount transaksi tampil',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: canDownload && !isExporting ? onDownload : null,
          icon: isExporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download_rounded, size: 18),
          label: const Text('Download CSV'),
        ),
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final SalesTransaction transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WessLessTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  transaction.transactionId,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                MockData.formatCurrency(transaction.totalAmount),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: WessLessTheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${SalesReportService.formatReadableDate(transaction.dateTime)}, ${transaction.time}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          Text(
            _formatItems(transaction.items),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: WessLessTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                size: 16,
                color: WessLessTheme.textHint,
              ),
              const SizedBox(width: 6),
              Text(
                'Metode: ${transaction.paymentMethod}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatItems(List<SalesTransactionItem> items) {
    return items
        .map(
          (item) => item.quantity > 1
              ? '${item.itemName} x${item.quantity}'
              : item.itemName,
        )
        .join(', ');
  }
}

class _EmptyReportState extends StatelessWidget {
  const _EmptyReportState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: WessLessTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: WessLessTheme.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: WessLessTheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Belum ada transaksi',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Transaksi dari POS akan muncul di halaman ini.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
