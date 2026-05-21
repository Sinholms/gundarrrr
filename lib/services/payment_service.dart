import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/midtrans_config.dart';

/// Service to communicate with the WessLess backend for Midtrans payments.
class PaymentService {
  static final _client = http.Client();

  /// Creates a Midtrans Snap transaction via the backend.
  ///
  /// Returns a map with `token` and `redirect_url` on success.
  /// Throws [PaymentException] on failure.
  static Future<Map<String, String>> createTransaction({
    required String orderId,
    required int grossAmount,
    required List<Map<String, dynamic>> items,
    String customerName = 'Pelanggan WessLess',
  }) async {
    final url = Uri.parse(
      '${MidtransConfig.backendBaseUrl}${MidtransConfig.createPaymentEndpoint}',
    );

    final body = jsonEncode({
      'order_id': orderId,
      'gross_amount': grossAmount,
      'items': items
          .map((item) => {
                'id': item['id'].toString(),
                'name': item['name'],
                'price': item['price'],
                'quantity': item['quantity'],
              })
          .toList(),
      'customer_name': customerName,
    });

    try {
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'token': data['token'] as String,
          'redirect_url': data['redirect_url'] as String,
        };
      } else {
        throw PaymentException(
          data['error']?.toString() ?? 'Gagal membuat transaksi',
        );
      }
    } catch (e) {
      if (e is PaymentException) rethrow;
      throw PaymentException(
        'Tidak dapat terhubung ke server pembayaran. Pastikan backend berjalan.\n\nDetail: $e',
      );
    }
  }

  /// Check transaction status from the backend.
  static Future<Map<String, dynamic>> checkStatus(String orderId) async {
    final url = Uri.parse(
      '${MidtransConfig.backendBaseUrl}${MidtransConfig.paymentStatusEndpoint}/$orderId/status',
    );

    try {
      final response = await _client
          .get(url)
          .timeout(const Duration(seconds: 10));

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw PaymentException('Gagal mengecek status transaksi: $e');
    }
  }
}

class PaymentException implements Exception {
  final String message;
  const PaymentException(this.message);

  @override
  String toString() => message;
}
