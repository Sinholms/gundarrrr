import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final critical = MockData.ingredients.where((e) => e['status'] == 'critical' || e['status'] == 'low').toList();
    final ok = MockData.ingredients.where((e) => e['status'] == 'ok' || e['status'] == 'warning').toList();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Stok Bahan Baku', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text('${MockData.ingredients.length} bahan terpantau', style: Theme.of(context).textTheme.bodyMedium),
                ]),
              ),
            ),
            // Summary row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(children: [
                  _SummaryChip(label: 'Perlu Restock', count: critical.length, color: WessLessTheme.error),
                  const SizedBox(width: 10),
                  _SummaryChip(label: 'Aman', count: ok.length, color: WessLessTheme.success),
                ]),
              ),
            ),
            // Critical section
            if (critical.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                  child: Text('⚠️ Perlu Perhatian', style: Theme.of(context).textTheme.titleLarge),
                ),
              ),
              SliverList(delegate: SliverChildBuilderDelegate((ctx, i) => _IngredientTile(item: critical[i]), childCount: critical.length)),
            ],
            // OK section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text('✅ Stok Aman', style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
            SliverList(delegate: SliverChildBuilderDelegate((ctx, i) => _IngredientTile(item: ok[i]), childCount: ok.length)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _SummaryChip({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(color: color.withAlpha(15), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withAlpha(50))),
        child: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text('$count', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color))),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ]),
      ),
    );
  }
}

class _IngredientTile extends StatelessWidget {
  final Map<String, dynamic> item;
  const _IngredientTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final status = item['status'] as String;
    final stock = (item['stock'] as num).toDouble();
    final minStock = (item['min_stock'] as num).toDouble();
    final ratio = minStock > 0 ? (stock / minStock).clamp(0.0, 1.0) : 1.0;

    Color barColor;
    String statusLabel;
    switch (status) {
      case 'critical':
        barColor = WessLessTheme.error;
        statusLabel = 'Kritis';
        break;
      case 'low':
        barColor = WessLessTheme.warning;
        statusLabel = 'Rendah';
        break;
      case 'warning':
        barColor = WessLessTheme.secondary;
        statusLabel = 'Hampir Habis';
        break;
      default:
        barColor = WessLessTheme.success;
        statusLabel = 'Aman';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WessLessTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status == 'critical' ? WessLessTheme.error.withAlpha(60) : Colors.grey.shade200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(item['name'], style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: barColor.withAlpha(20), borderRadius: BorderRadius.circular(6)),
            child: Text(statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: barColor)),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: ratio, minHeight: 6, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation(barColor)),
            ),
          ),
          const SizedBox(width: 12),
          Text('${stock.toStringAsFixed(1)} / ${minStock.toStringAsFixed(1)} ${item['unit']}', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w500)),
        ]),
      ]),
    );
  }
}
