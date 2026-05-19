import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/food_image.dart';
import '../data/mock_data.dart';
import 'payment_gateway_screen.dart';

class PosScreen extends StatefulWidget {
  final VoidCallback? onTransactionCompleted;

  const PosScreen({super.key, this.onTransactionCompleted});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final Map<int, int> _cart = {};
  final TextEditingController _noteController = TextEditingController();
  String _activeCategory = 'Semua';

  int get _totalItems => _cart.values.fold(0, (a, b) => a + b);
  int get _totalPrice {
    int total = 0;
    _cart.forEach((id, qty) {
      final item = _findMenuItemById(id);
      if (item == null) return;
      total += (item['price'] as int) * qty;
    });
    return total;
  }

  Map<String, dynamic>? _findMenuItemById(int id) {
    for (final item in MockData.menuItems) {
      if (item['id'] == id) return item;
    }
    return null;
  }

  void _removeUnavailableCartItems() {
    _cart.removeWhere((id, quantity) => _findMenuItemById(id) == null);
  }

  List<Map<String, dynamic>> get _filteredMenu {
    if (_activeCategory == 'Semua') return MockData.menuItems;
    return MockData.menuItems
        .where((m) => m['category'] == _activeCategory)
        .toList();
  }

  String get _orderRecap {
    final names = _cart.entries
        .map((entry) {
          final item = _findMenuItemById(entry.key);
          if (item == null) return null;
          final name = item['name'] as String;
          return entry.value > 1 ? '${entry.value}x $name' : name;
        })
        .whereType<String>()
        .toList();

    return names.join(' + ');
  }

  List<PaymentLineItem> get _paymentItems {
    return _cart.entries
        .map((entry) {
          final item = _findMenuItemById(entry.key);
          if (item == null) return null;
          return PaymentLineItem(
            name: item['name'] as String,
            price: item['price'] as int,
            quantity: entry.value,
          );
        })
        .whereType<PaymentLineItem>()
        .toList();
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _recordPaidOrder({
    required String orderId,
    required List<PaymentLineItem> items,
    required int total,
  }) {
    final totalQuantity = items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    MockData.recentTransactions.insert(0, {
      'id': orderId,
      'time': _formatTime(DateTime.now()),
      'items': items
          .map(
            (item) => item.quantity > 1
                ? '${item.quantity}x ${item.name}'
                : item.name,
          )
          .toList(),
      'total': total,
      'qty': totalQuantity,
    });
    if (MockData.recentTransactions.length > 10) {
      MockData.recentTransactions.removeRange(
        10,
        MockData.recentTransactions.length,
      );
    }
  }

  Future<void> _openPaymentGateway() async {
    _removeUnavailableCartItems();
    if (_cart.isEmpty) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Menu di keranjang sudah tidak tersedia.'),
          backgroundColor: WessLessTheme.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final total = _totalPrice;
    final items = _paymentItems;
    if (items.isEmpty) return;
    final orderId =
        'TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final paid = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PaymentGatewayScreen(
          orderId: orderId,
          items: items,
          totalPrice: total,
          note: _noteController.text.trim(),
        ),
      ),
    );

    if (!mounted || paid != true) return;

    _recordPaidOrder(orderId: orderId, items: items, total: total);
    widget.onTransactionCompleted?.call();

    setState(() => _cart.clear());
    _noteController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Transaksi ${MockData.formatCurrency(total)} berhasil dibayar!',
        ),
        backgroundColor: WessLessTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Proactively remove items that are no longer in the menu
    _removeUnavailableCartItems();

    final categories = ['Semua', 'Makanan', 'Minuman', 'Tambahan'];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Kasir',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  if (_cart.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() => _cart.clear());
                        _noteController.clear();
                      },
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          color: WessLessTheme.error,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 0, 12),
              child: SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  padding: const EdgeInsets.only(right: 20),
                  itemBuilder: (context, i) {
                    final cat = categories[i];
                    final active = cat == _activeCategory;
                    return GestureDetector(
                      onTap: () => setState(() => _activeCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: active
                              ? WessLessTheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: active
                                ? WessLessTheme.primary
                                : Colors.grey.shade300,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: active
                                ? Colors.white
                                : WessLessTheme.textSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 190),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.98,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _filteredMenu.length,
                itemBuilder: (context, i) {
                  final item = _filteredMenu[i];
                  final qty = _cart[item['id']] ?? 0;
                  return GestureDetector(
                    onTap: () => setState(() => _cart[item['id']] = qty + 1),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: qty > 0
                            ? WessLessTheme.primary.withAlpha(10)
                            : WessLessTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: qty > 0
                              ? WessLessTheme.primary.withAlpha(80)
                              : Colors.grey.shade200,
                          width: qty > 0 ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FoodImage(
                                assetPath: item['icon'],
                                size: 72,
                                imageBytes: item['image_bytes'] as Uint8List?,
                              ),
                              if (qty > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: WessLessTheme.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$qty',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            item['name'],
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                MockData.formatCurrency(item['price']),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: WessLessTheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              if (qty > 0)
                                GestureDetector(
                                  onTap: () => setState(() {
                                    if (qty <= 1) {
                                      _cart.remove(item['id']);
                                    } else {
                                      _cart[item['id']] = qty - 1;
                                    }
                                  }),
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: WessLessTheme.error.withAlpha(15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.remove_rounded,
                                      size: 14,
                                      color: WessLessTheme.error,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _cart.isNotEmpty
          ? Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
              decoration: BoxDecoration(
                color: WessLessTheme.surfaceCard,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$_totalItems item',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                MockData.formatCurrency(_totalPrice),
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _openPaymentGateway,
                          icon: const Icon(Icons.qr_code_rounded, size: 18),
                          label: const Text('Bayar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.receipt_long_rounded,
                          size: 16,
                          color: WessLessTheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _orderRecap,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: WessLessTheme.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 42,
                      child: TextField(
                        controller: _noteController,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: 'Catatan tambahan',
                          prefixIcon: const Icon(
                            Icons.edit_note_rounded,
                            size: 20,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          filled: true,
                          fillColor: WessLessTheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              color: WessLessTheme.primary,
                              width: 1.4,
                            ),
                          ),
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: WessLessTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
