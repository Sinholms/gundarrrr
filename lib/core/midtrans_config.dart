/// Midtrans configuration for WessLess
/// For hackathon demo: keys are loaded from the backend.
/// The Flutter app only needs the backend URL.
class MidtransConfig {
  /// Backend API base URL
  /// Change this to your deployed backend URL or ngrok URL
  static const String backendBaseUrl = 'http://localhost:3000';

  /// API endpoints
  static const String createPaymentEndpoint = '/api/payments/create';
  static const String paymentStatusEndpoint = '/api/payments'; // + /:orderId/status
  static const String notificationEndpoint = '/api/payments/notification';

  /// Midtrans Sandbox Client Key (safe to expose in frontend)
  /// Replace with your actual Sandbox Client Key
  static const String clientKey = 'SB-Mid-client-YOUR_KEY_HERE';

  /// Whether using production environment
  static const bool isProduction = false;

  /// Snap page base URL
  static String get snapBaseUrl => isProduction
      ? 'https://app.midtrans.com/snap/v2/vtweb'
      : 'https://app.sandbox.midtrans.com/snap/v2/vtweb';
}
