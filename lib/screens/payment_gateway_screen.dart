import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/mock_data.dart';

class PaymentLineItem {
  final String name;
  final int price;
  final int quantity;

  const PaymentLineItem({
    required this.name,
    required this.price,
    required this.quantity,
  });

  int get subtotal => price * quantity;
}

class PaymentGatewayScreen extends StatelessWidget {
  final String orderId;
  final List<PaymentLineItem> items;
  final int totalPrice;
  final String note;

  const PaymentGatewayScreen({
    super.key,
    required this.orderId,
    required this.items,
    required this.totalPrice,
    this.note = '',
  });

  @override
  Widget build(BuildContext context) {
    // Replace this payload with the QRIS string from a payment gateway later.
    final qrPayload = 'QRIS|WESSLESS|$orderId|$totalPrice';

    return Scaffold(
      backgroundColor: WessLessTheme.background,
      appBar: AppBar(
        title: const Text('Pembayaran'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StatusBanner(orderId: orderId),
              const SizedBox(height: 16),
              _QrisPanel(payload: qrPayload, totalPrice: totalPrice),
              const SizedBox(height: 16),
              _OrderSummary(items: items, totalPrice: totalPrice, note: note),
              const SizedBox(height: 16),
              _PaymentTips(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context, false),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.verified_rounded, size: 18),
                  label: const Text('Selesai'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String orderId;

  const _StatusBanner({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WessLessTheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scan QRIS untuk bayar',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  orderId,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withAlpha(210),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QrisPanel extends StatelessWidget {
  final String payload;
  final int totalPrice;

  const _QrisPanel({
    required this.payload,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: WessLessTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet_rounded,
                  color: WessLessTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'QRIS WessLess',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _PrototypeQrCode(payload: payload),
          const SizedBox(height: 16),
          Text(
            MockData.formatCurrency(totalPrice),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: WessLessTheme.primaryDark,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tunjukkan layar ini ke pelanggan untuk discan',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _PrototypeQrCode extends StatelessWidget {
  final String payload;

  const _PrototypeQrCode({required this.payload});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: SizedBox.square(
        dimension: 230,
        child: CustomPaint(
          painter: _QrPatternPainter(payload),
        ),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final List<PaymentLineItem> items;
  final int totalPrice;
  final String note;

  const _OrderSummary({
    required this.items,
    required this.totalPrice,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WessLessTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Pesanan',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: WessLessTheme.primary.withAlpha(15),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        '${item.quantity}x',
                        style: const TextStyle(
                          color: WessLessTheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: WessLessTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    Text(
                      MockData.formatCurrency(item.subtotal),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: WessLessTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              )),
          Divider(color: Colors.grey.shade200),
          if (note.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.edit_note_rounded,
                    size: 18, color: WessLessTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    note,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: WessLessTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(color: Colors.grey.shade200),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                MockData.formatCurrency(totalPrice),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentTips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WessLessTheme.info.withAlpha(12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: WessLessTheme.info.withAlpha(45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_rounded, color: WessLessTheme.info, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tekan Selesai setelah pembayaran pelanggan berhasil. Pesanan akan otomatis tercatat di kasir.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: WessLessTheme.textPrimary,
                    height: 1.35,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QrPatternPainter extends CustomPainter {
  final String payload;

  _QrPatternPainter(this.payload);

  static const int _gridSize = 29;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / _gridSize;
    final paint = Paint()..color = WessLessTheme.textPrimary;
    final accentPaint = Paint()..color = WessLessTheme.primary;

    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);

    _drawFinder(canvas, Offset.zero, cell, paint);
    _drawFinder(canvas, Offset((_gridSize - 7) * cell, 0), cell, paint);
    _drawFinder(canvas, Offset(0, (_gridSize - 7) * cell), cell, paint);

    var seed = 0;
    for (final codeUnit in payload.codeUnits) {
      seed = (seed * 31 + codeUnit) & 0x7fffffff;
    }

    for (var y = 0; y < _gridSize; y++) {
      for (var x = 0; x < _gridSize; x++) {
        if (_isFinderArea(x, y)) continue;

        final value = (x * 73 + y * 151 + seed + (x * y * 17)) & 0xff;
        final shouldFill =
            value % 5 == 0 || value % 7 == 0 || (x + y + seed) % 11 == 0;

        if (!shouldFill) continue;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x * cell, y * cell, cell * 0.9, cell * 0.9),
            Radius.circular(cell * 0.18),
          ),
          (x + y) % 9 == 0 ? accentPaint : paint,
        );
      }
    }

    final labelRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cell * 7.8,
      height: cell * 3.1,
    );
    final labelPaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, Radius.circular(cell * 0.7)),
      labelPaint,
    );

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'QRIS',
        style: TextStyle(
          color: WessLessTheme.primaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  void _drawFinder(Canvas canvas, Offset origin, double cell, Paint paint) {
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(origin.dx, origin.dy, cell * 7, cell * 7),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(origin.dx + cell, origin.dy + cell, cell * 5, cell * 5),
      whitePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(origin.dx + cell * 2, origin.dy + cell * 2, cell * 3,
          cell * 3),
      paint,
    );
  }

  bool _isFinderArea(int x, int y) {
    final inTopLeft = x < 8 && y < 8;
    final inTopRight = x >= _gridSize - 8 && y < 8;
    final inBottomLeft = x < 8 && y >= _gridSize - 8;
    return inTopLeft || inTopRight || inBottomLeft;
  }

  @override
  bool shouldRepaint(covariant _QrPatternPainter oldDelegate) {
    return oldDelegate.payload != payload;
  }
}
