import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme.dart';
import '../core/food_image.dart';
import '../data/mock_data.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onOpenRestock;

  const DashboardScreen({super.key, this.onOpenRestock});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat Pagi ☀️';
    if (h < 15) return 'Selamat Siang 👋';
    if (h < 18) return 'Selamat Sore 🌅';
    return 'Selamat Malam 🌙';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Warung Geprek Mas Bro',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: WessLessTheme.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: WessLessTheme.primary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Waste Reduction Banner
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: WessLessTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Food Waste Berkurang',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withAlpha(200),
                                  fontSize: 12,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${MockData.todayStats['waste_reduction']}%',
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hemat ${MockData.formatCurrency(MockData.todayStats['cost_saved'])} minggu ini',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.white.withAlpha(180)),
                          ),
                        ],
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/sprout.png',
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Quick Stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    _StatCard(
                      label: 'Penjualan Hari Ini',
                      value: MockData.formatCurrency(
                        MockData.todayStats['total_sales'],
                      ),
                      icon: Icons.payments_outlined,
                      color: WessLessTheme.info,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'Porsi Terjual',
                      value: '${MockData.todayStats['total_portions']}',
                      icon: Icons.restaurant_rounded,
                      color: WessLessTheme.primary,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'Sisa Hari Ini',
                      value: '${MockData.todayStats['total_waste']}',
                      icon: Icons.delete_outline_rounded,
                      color: WessLessTheme.riskLow,
                    ),
                  ],
                ),
              ),
            ),

            // Sales Chart Section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                padding: const EdgeInsets.all(20),
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
                            'Penjualan 7 Hari',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(width: 12),
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
                            'Minggu Ini',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: WessLessTheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 160,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 2500000,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                getTitlesWidget: (value, meta) {
                                  final days = MockData.salesHistory;
                                  if (value.toInt() < days.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        days[value.toInt()]['day'],
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: WessLessTheme.textHint,
                                          fontWeight: value.toInt() == 5
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                          barGroups: List.generate(
                            MockData.salesHistory.length,
                            (i) => BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY:
                                      (MockData.salesHistory[i]['sales'] as num)
                                          .toDouble(),
                                  color: i == 5
                                      ? WessLessTheme.primary
                                      : WessLessTheme.primary.withAlpha(80),
                                  width: 24,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tomorrow Forecast Preview
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: WessLessTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Prediksi Besok',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Icon(
                          Icons.auto_graph_rounded,
                          size: 18,
                          color: WessLessTheme.secondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Estimasi produksi berdasarkan pola penjualan',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    ...MockData.forecastData
                        .take(4)
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                FoodImage(assetPath: item['icon'], size: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['menu'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(fontSize: 13),
                                      ),
                                      const SizedBox(height: 2),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: (item['confidence'] as num)
                                              .toDouble(),
                                          minHeight: 4,
                                          backgroundColor: Colors.grey.shade200,
                                          valueColor: AlwaysStoppedAnimation(
                                            _confidenceColor(
                                              item['confidence'],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${item['predicted']} porsi',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: WessLessTheme.primary,
                                            fontSize: 13,
                                          ),
                                    ),
                                    Text(
                                      '${((item['confidence'] as num) * 100).toInt()}%',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(fontSize: 10),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),

            // Stock Alert
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Material(
                  color: WessLessTheme.warning.withAlpha(15),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: onOpenRestock,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: WessLessTheme.warning.withAlpha(60),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: WessLessTheme.warning.withAlpha(30),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.warning_amber_rounded,
                              color: WessLessTheme.warning,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '3 bahan baku perlu restock',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Bawang Merah, Beras, Tepung Terigu',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: WessLessTheme.textHint,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Recent Transactions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text(
                  'Transaksi Terakhir',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final trx = MockData.recentTransactions[index];
                return Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: WessLessTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: WessLessTheme.primary.withAlpha(15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${trx['qty']}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: WessLessTheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trx['id'],
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(fontSize: 13),
                            ),
                            Text(
                              (trx['items'] as List).take(2).join(', '),
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            MockData.formatCurrency(trx['total']),
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(fontSize: 13),
                          ),
                          Text(
                            trx['time'],
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }, childCount: MockData.recentTransactions.length),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  static Color _confidenceColor(dynamic val) {
    final v = (val as num).toDouble();
    if (v >= 0.9) return WessLessTheme.success;
    if (v >= 0.85) return WessLessTheme.primary;
    return WessLessTheme.warning;
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrencyValue = value.startsWith('Rp');

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: WessLessTheme.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: isCurrencyValue ? 13 : 15,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
