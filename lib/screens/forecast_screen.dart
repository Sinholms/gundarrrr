import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/food_image.dart';
import '../data/mock_data.dart';
import '../widgets/wessless_logo_mark.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final totalPredicted = MockData.forecastData.fold<int>(
      0,
      (s, e) => s + (e['predicted'] as int),
    );
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Forecast',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Prediksi produksi untuk besok',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            // Summary card
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
                            'Total Prediksi',
                            style: TextStyle(
                              color: Colors.white.withAlpha(200),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$totalPredicted porsi',
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Berdasarkan data 30 hari terakhir',
                            style: TextStyle(
                              color: Colors.white.withAlpha(160),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        const WessLessLogoMark(size: 54),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(30),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'ML Model',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Info
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  children: [
                    Text(
                      'Detail Per Menu',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: WessLessTheme.textHint,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Confidence',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            // Forecast items
            SliverList(
              delegate: SliverChildBuilderDelegate((context, i) {
                final item = MockData.forecastData[i];
                final conf = ((item['confidence'] as num) * 100).toInt();
                final trend = item['trend'] as String;
                return Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: WessLessTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      FoodImage(assetPath: item['icon'], size: 36),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['menu'],
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(fontSize: 14),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: (item['confidence'] as num)
                                          .toDouble(),
                                      minHeight: 6,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation(
                                        _confColor(item['confidence']),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$conf%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _confColor(item['confidence']),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${item['predicted']}',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontSize: 22,
                                  color: WessLessTheme.primary,
                                ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                trend == 'up'
                                    ? Icons.trending_up_rounded
                                    : trend == 'down'
                                    ? Icons.trending_down_rounded
                                    : Icons.trending_flat_rounded,
                                size: 14,
                                color: trend == 'up'
                                    ? WessLessTheme.success
                                    : trend == 'down'
                                    ? WessLessTheme.error
                                    : WessLessTheme.textHint,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'porsi',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }, childCount: MockData.forecastData.length),
            ),
            // Disclaimer
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: WessLessTheme.info.withAlpha(10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: WessLessTheme.info.withAlpha(40)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 16,
                        color: WessLessTheme.info,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Prediksi menggunakan algoritma Random Forest berdasarkan pola penjualan harian, tren mingguan, dan faktor hari kerja/weekend. Akurasi meningkat seiring bertambahnya data transaksi.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: WessLessTheme.info,
                                height: 1.5,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _confColor(dynamic v) {
    final d = (v as num).toDouble();
    if (d >= 0.9) return WessLessTheme.success;
    if (d >= 0.85) return WessLessTheme.primary;
    return WessLessTheme.warning;
  }
}
