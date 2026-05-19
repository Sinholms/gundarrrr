import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/food_image.dart';
import '../data/mock_data.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
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
                            'Menu & Resep',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kelola produk dan pemetaan bahan baku',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: WessLessTheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Product list with ingredient mapping
            SliverList(
              delegate: SliverChildBuilderDelegate((ctx, i) {
                final item = MockData.menuItems[i];
                final ingredients = _getIngredients(item['name']);
                return Container(
                  margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  decoration: BoxDecoration(
                    color: WessLessTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      leading: FoodImage(
                        assetPath: item['icon'],
                        size: 40,
                        imageBytes: item['image_bytes'] as Uint8List?,
                      ),
                      title: Text(
                        item['name'],
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontSize: 14),
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            MockData.formatCurrency(item['price']),
                            style: TextStyle(
                              fontSize: 12,
                              color: WessLessTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item['category'],
                              style: TextStyle(
                                fontSize: 10,
                                color: WessLessTheme.textHint,
                              ),
                            ),
                          ),
                        ],
                      ),
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: WessLessTheme.surface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.receipt_long_rounded,
                                    size: 14,
                                    color: WessLessTheme.textHint,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Bahan Baku per Porsi',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: WessLessTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ...ingredients.map(
                                (ing) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 4,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: WessLessTheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          ing['name'],
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      Text(
                                        '${ing['amount']} ${ing['unit']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: WessLessTheme.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Divider(height: 1),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calculate_outlined,
                                    size: 14,
                                    color: WessLessTheme.textHint,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'HPP: ',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: WessLessTheme.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    _calcHpp(ingredients),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: WessLessTheme.primary,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Margin: ',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: WessLessTheme.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '${_calcMargin(item['price'], ingredients)}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: WessLessTheme.success,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: MockData.menuItems.length),
            ),
            // Info card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: WessLessTheme.primary.withAlpha(10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: WessLessTheme.primary.withAlpha(30),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 16,
                        color: WessLessTheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Ingredient Mapping otomatis menghitung kebutuhan bahan baku berdasarkan jumlah prediksi produksi AI. Data ini digunakan untuk Smart Restock.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: WessLessTheme.primary,
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

  List<Map<String, dynamic>> _getIngredients(String menuName) {
    final map = {
      'Ayam Geprek Original': [
        {'name': 'Ayam Potong', 'amount': '200', 'unit': 'g', 'cost': 7000},
        {'name': 'Tepung Terigu', 'amount': '50', 'unit': 'g', 'cost': 600},
        {'name': 'Cabai Rawit', 'amount': '30', 'unit': 'g', 'cost': 1350},
        {'name': 'Bawang Merah', 'amount': '20', 'unit': 'g', 'cost': 640},
        {'name': 'Minyak Goreng', 'amount': '100', 'unit': 'ml', 'cost': 1800},
      ],
      'Ayam Geprek Sambal Matah': [
        {'name': 'Ayam Potong', 'amount': '200', 'unit': 'g', 'cost': 7000},
        {'name': 'Tepung Terigu', 'amount': '50', 'unit': 'g', 'cost': 600},
        {'name': 'Bawang Merah', 'amount': '40', 'unit': 'g', 'cost': 1280},
        {'name': 'Sereh', 'amount': '10', 'unit': 'g', 'cost': 200},
        {'name': 'Minyak Goreng', 'amount': '100', 'unit': 'ml', 'cost': 1800},
      ],
      'Nasi Putih': [
        {'name': 'Beras', 'amount': '150', 'unit': 'g', 'cost': 2100},
      ],
      'Es Teh Manis': [
        {'name': 'Teh Celup', 'amount': '1', 'unit': 'pcs', 'cost': 320},
        {'name': 'Gula Pasir', 'amount': '30', 'unit': 'g', 'cost': 480},
      ],
      'Es Jeruk': [
        {'name': 'Jeruk Peras', 'amount': '2', 'unit': 'buah', 'cost': 2000},
        {'name': 'Gula Pasir', 'amount': '25', 'unit': 'g', 'cost': 400},
      ],
      'Ayam Geprek Mozarella': [
        {'name': 'Ayam Potong', 'amount': '200', 'unit': 'g', 'cost': 7000},
        {'name': 'Tepung Terigu', 'amount': '50', 'unit': 'g', 'cost': 600},
        {'name': 'Keju Mozarella', 'amount': '50', 'unit': 'g', 'cost': 4750},
        {'name': 'Cabai Rawit', 'amount': '30', 'unit': 'g', 'cost': 1350},
        {'name': 'Minyak Goreng', 'amount': '100', 'unit': 'ml', 'cost': 1800},
      ],
      'Tahu Crispy': [
        {'name': 'Tahu', 'amount': '100', 'unit': 'g', 'cost': 500},
        {'name': 'Tepung Terigu', 'amount': '30', 'unit': 'g', 'cost': 360},
        {'name': 'Minyak Goreng', 'amount': '50', 'unit': 'ml', 'cost': 900},
      ],
      'Tempe Goreng': [
        {'name': 'Tempe', 'amount': '100', 'unit': 'g', 'cost': 600},
        {'name': 'Tepung Terigu', 'amount': '30', 'unit': 'g', 'cost': 360},
        {'name': 'Minyak Goreng', 'amount': '50', 'unit': 'ml', 'cost': 900},
      ],
    };
    return map[menuName] ??
        [
          {'name': 'Belum dipetakan', 'amount': '-', 'unit': '', 'cost': 0},
        ];
  }

  String _calcHpp(List<Map<String, dynamic>> ingredients) {
    final total = ingredients.fold<int>(0, (s, e) => s + (e['cost'] as int));
    return MockData.formatCurrency(total);
  }

  String _calcMargin(int price, List<Map<String, dynamic>> ingredients) {
    final hpp = ingredients.fold<int>(0, (s, e) => s + (e['cost'] as int));
    if (hpp == 0) return '0';
    return (((price - hpp) / price) * 100).toInt().toString();
  }
}
