import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';

class RestockScreen extends StatefulWidget {
  const RestockScreen({super.key});
  @override
  State<RestockScreen> createState() => _RestockScreenState();
}

class _RestockScreenState extends State<RestockScreen> {
  final Set<int> _selected = {};

  int get _selectedCost {
    int total = 0;
    for (final i in _selected) {
      total += MockData.restockItems[i]['cost'] as int;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final totalCost = MockData.restockItems.fold<int>(0, (s, e) => s + (e['cost'] as int));
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Smart Restock', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text('Rekomendasi berdasarkan prediksi AI', style: Theme.of(context).textTheme.bodyMedium),
                ]),
              ),
            ),
            // Cost summary
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: WessLessTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Estimasi Biaya Restock', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Text(MockData.formatCurrency(totalCost), style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('${MockData.restockItems.length} bahan perlu dibeli', style: Theme.of(context).textTheme.bodySmall),
                  ])),
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: WessLessTheme.secondary.withAlpha(20), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.shopping_basket_rounded, color: WessLessTheme.secondary),
                  ),
                ]),
              ),
            ),
            // Select all
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(children: [
                  Text('Daftar Belanja', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_selected.length == MockData.restockItems.length) {
                          _selected.clear();
                        } else {
                          _selected.clear();
                          for (int i = 0; i < MockData.restockItems.length; i++) {
                            _selected.add(i);
                          }
                        }
                      });
                    },
                    child: Text(
                      _selected.length == MockData.restockItems.length ? 'Batal Semua' : 'Pilih Semua',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WessLessTheme.primary),
                    ),
                  ),
                ]),
              ),
            ),
            // Items
            SliverList(
              delegate: SliverChildBuilderDelegate((ctx, i) {
                final item = MockData.restockItems[i];
                final checked = _selected.contains(i);
                final urgency = item['urgency'] as String;
                Color urgencyColor;
                switch (urgency) {
                  case 'critical': urgencyColor = WessLessTheme.error; break;
                  case 'high': urgencyColor = WessLessTheme.warning; break;
                  default: urgencyColor = WessLessTheme.info;
                }
                return GestureDetector(
                  onTap: () => setState(() { if (checked) _selected.remove(i); else _selected.add(i); }),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: checked ? WessLessTheme.primary.withAlpha(8) : WessLessTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: checked ? WessLessTheme.primary.withAlpha(60) : Colors.grey.shade200),
                    ),
                    child: Row(children: [
                      Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(
                          color: checked ? WessLessTheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: checked ? WessLessTheme.primary : Colors.grey.shade400, width: 1.5),
                        ),
                        child: checked ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text(item['name'], style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: urgencyColor.withAlpha(15), borderRadius: BorderRadius.circular(6)),
                            child: Text(urgency, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: urgencyColor)),
                          ),
                        ]),
                        const SizedBox(height: 6),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('${(item['needed'] as num).toStringAsFixed(1)} ${item['unit']}', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
                          Text(MockData.formatCurrency(item['cost']), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 13, color: WessLessTheme.primary)),
                        ]),
                      ])),
                    ]),
                  ),
                );
              }, childCount: MockData.restockItems.length),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      // WhatsApp button
      bottomSheet: _selected.isNotEmpty ? Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        decoration: BoxDecoration(color: WessLessTheme.surfaceCard, boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 16, offset: const Offset(0, -4))]),
        child: SafeArea(top: false, child: Row(children: [
          Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${_selected.length} bahan dipilih', style: Theme.of(context).textTheme.bodySmall),
            Text(MockData.formatCurrency(_selectedCost), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          ])),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(context: context, builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Text('Draft WhatsApp'),
                content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Pesan untuk supplier:', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      'Halo Pak, saya mau pesan:\n${_selected.map((i) { final it = MockData.restockItems[i]; return '• ${it['name']} ${(it['needed'] as num).toStringAsFixed(1)} ${it['unit']}'; }).join('\n')}\n\nMohon dikirim besok pagi ya. Terima kasih! 🙏',
                      style: const TextStyle(fontSize: 13, height: 1.5),
                    ),
                  ),
                ]),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
                  ElevatedButton.icon(
                    onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Draft siap dikirim via WhatsApp!'), backgroundColor: WessLessTheme.success, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))); },
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('Kirim'),
                  ),
                ],
              ));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
            icon: const Icon(Icons.chat_rounded, size: 18),
            label: const Text('WhatsApp Supplier'),
          ),
        ])),
      ) : null,
    );
  }
}
