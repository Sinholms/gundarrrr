import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../core/theme.dart';
import '../data/mock_data.dart';
import '../services/payment_service.dart';

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

/// Screen that handles Midtrans Snap payment flow.
///
/// 1. Calls the backend to create a Snap transaction → gets redirect_url
/// 2. Opens the Midtrans payment page in a WebView (mobile) or external browser (web)
/// 3. Detects payment completion and returns the result
class PaymentGatewayScreen extends StatefulWidget {
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
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  _PaymentState _state = _PaymentState.loading;
  String _errorMessage = '';
  String _redirectUrl = '';
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _createTransaction();
  }

  Future<void> _createTransaction() async {
    try {
      setState(() => _state = _PaymentState.loading);

      final result = await PaymentService.createTransaction(
        orderId: widget.orderId,
        grossAmount: widget.totalPrice,
        items: widget.items
            .map((item) => {
                  'id': item.name.hashCode.toString(),
                  'name': item.name,
                  'price': item.price,
                  'quantity': item.quantity,
                })
            .toList(),
      );

      _redirectUrl = result['redirect_url'] ?? '';

      if (_redirectUrl.isEmpty) {
        throw const PaymentException('Tidak mendapatkan URL pembayaran');
      }

      if (kIsWeb) {
        // On web: launch in a new browser tab
        setState(() => _state = _PaymentState.webRedirect);
      } else {
        // On mobile: load in WebView
        _initWebView();
        setState(() => _state = _PaymentState.webview);
      }
    } on PaymentException catch (e) {
      setState(() {
        _state = _PaymentState.error;
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _state = _PaymentState.error;
        _errorMessage = 'Terjadi kesalahan: $e';
      });
    }
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final url = request.url;

            // Detect deep links (GoPay, ShopeePay, etc.)
            if (url.startsWith('gojek://') ||
                url.startsWith('shopeeid://') ||
                url.startsWith('dana://') ||
                url.startsWith('ovo://') ||
                url.startsWith('linkaja://')) {
              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              return NavigationDecision.prevent;
            }

            // Detect completion URLs
            if (url.contains('transaction_status=settlement') ||
                url.contains('transaction_status=capture') ||
                url.contains('status_code=200')) {
              _onPaymentSuccess();
              return NavigationDecision.prevent;
            }

            if (url.contains('transaction_status=pending')) {
              _onPaymentPending();
              return NavigationDecision.prevent;
            }

            if (url.contains('transaction_status=deny') ||
                url.contains('transaction_status=cancel') ||
                url.contains('transaction_status=expire') ||
                url.contains('status_code=202')) {
              _onPaymentFailed();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onPageStarted: (url) {
            debugPrint('[Midtrans] Loading: $url');
          },
        ),
      )
      ..loadRequest(Uri.parse(_redirectUrl));
  }

  void _onPaymentSuccess() {
    if (!mounted) return;
    setState(() => _state = _PaymentState.success);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context, true);
    });
  }

  void _onPaymentPending() {
    if (!mounted) return;
    setState(() => _state = _PaymentState.pending);
  }

  void _onPaymentFailed() {
    if (!mounted) return;
    setState(() {
      _state = _PaymentState.error;
      _errorMessage = 'Pembayaran gagal atau dibatalkan.';
    });
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(_redirectUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _checkPaymentStatus() async {
    try {
      setState(() => _state = _PaymentState.loading);
      final status = await PaymentService.checkStatus(widget.orderId);
      final txStatus = status['transaction_status'] as String? ?? '';

      if (txStatus == 'settlement' || txStatus == 'capture') {
        _onPaymentSuccess();
      } else if (txStatus == 'pending') {
        _onPaymentPending();
      } else if (txStatus == 'deny' ||
          txStatus == 'cancel' ||
          txStatus == 'expire') {
        _onPaymentFailed();
      } else {
        setState(() => _state = _PaymentState.webRedirect);
      }
    } catch (e) {
      setState(() {
        _state = _PaymentState.webRedirect;
        _errorMessage = 'Gagal cek status: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WessLessTheme.background,
      appBar: _state == _PaymentState.webview
          ? AppBar(
              title: const Text('Pembayaran Midtrans'),
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context, false),
              ),
            )
          : AppBar(
              title: const Text('Pembayaran'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.pop(context, false),
              ),
            ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case _PaymentState.loading:
        return _LoadingView(totalPrice: widget.totalPrice);

      case _PaymentState.webview:
        if (_webViewController != null) {
          return WebViewWidget(controller: _webViewController!);
        }
        return _LoadingView(totalPrice: widget.totalPrice);

      case _PaymentState.webRedirect:
        return _WebRedirectView(
          orderId: widget.orderId,
          totalPrice: widget.totalPrice,
          items: widget.items,
          note: widget.note,
          onOpenBrowser: _openInBrowser,
          onCheckStatus: _checkPaymentStatus,
          onCancel: () => Navigator.pop(context, false),
        );

      case _PaymentState.success:
        return const _StatusView(
          icon: Icons.check_circle_rounded,
          color: WessLessTheme.success,
          title: 'Pembayaran Berhasil!',
          subtitle: 'Transaksi telah tercatat. Mengalihkan...',
        );

      case _PaymentState.pending:
        return _PendingView(
          orderId: widget.orderId,
          onCheckStatus: _checkPaymentStatus,
          onDone: () => Navigator.pop(context, false),
        );

      case _PaymentState.error:
        return _ErrorView(
          message: _errorMessage,
          onRetry: _createTransaction,
          onCancel: () => Navigator.pop(context, false),
        );
    }
  }
}

enum _PaymentState { loading, webview, webRedirect, success, pending, error }

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _LoadingView extends StatelessWidget {
  final int totalPrice;
  const _LoadingView({required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: WessLessTheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Menyiapkan pembayaran...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              MockData.formatCurrency(totalPrice),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: WessLessTheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebRedirectView extends StatelessWidget {
  final String orderId;
  final int totalPrice;
  final List<PaymentLineItem> items;
  final String note;
  final VoidCallback onOpenBrowser;
  final VoidCallback onCheckStatus;
  final VoidCallback onCancel;

  const _WebRedirectView({
    required this.orderId,
    required this.totalPrice,
    required this.items,
    required this.note,
    required this.onOpenBrowser,
    required this.onCheckStatus,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: WessLessTheme.primaryGradient,
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
                      Icons.payment_rounded,
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
                          MockData.formatCurrency(totalPrice),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          orderId,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withAlpha(210),
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Open browser button
            ElevatedButton.icon(
              onPressed: onOpenBrowser,
              icon: const Icon(Icons.open_in_browser_rounded, size: 20),
              label: const Text('Buka Halaman Pembayaran'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),

            // Check status button
            OutlinedButton.icon(
              onPressed: onCheckStatus,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Cek Status Pembayaran'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 20),

            // Order summary
            _OrderSummary(
              items: items,
              totalPrice: totalPrice,
              note: note,
            ),
            const SizedBox(height: 16),

            // Info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: WessLessTheme.info.withAlpha(12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: WessLessTheme.info.withAlpha(45)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_rounded,
                      color: WessLessTheme.info, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Halaman pembayaran Midtrans akan terbuka di browser. Setelah pelanggan selesai bayar, kembali ke sini dan tekan "Cek Status".',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: WessLessTheme.textPrimary,
                            height: 1.35,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            TextButton(
              onPressed: onCancel,
              child: const Text(
                'Batalkan',
                style: TextStyle(
                  color: WessLessTheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusView extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _StatusView({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: color),
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingView extends StatelessWidget {
  final String orderId;
  final VoidCallback onCheckStatus;
  final VoidCallback onDone;

  const _PendingView({
    required this.orderId,
    required this.onCheckStatus,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.schedule_rounded,
                size: 72, color: WessLessTheme.warning),
            const SizedBox(height: 20),
            Text(
              'Menunggu Pembayaran',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Transaksi $orderId sedang menunggu pembayaran pelanggan.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onCheckStatus,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Cek Lagi'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onDone,
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 72, color: WessLessTheme.error),
            const SizedBox(height: 20),
            Text(
              'Gagal',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onCancel,
              child: const Text('Batal'),
            ),
          ],
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
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
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
