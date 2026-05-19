// Mock data for WessLess demo/prototype

class MockData {
  // Menu Items
  static final List<Map<String, dynamic>> menuItems = [
    {'id': 1, 'name': 'Ayam Geprek Original', 'price': 15000, 'category': 'Makanan', 'icon': 'assets/images/ayam_geprek.png', 'sold_today': 42, 'predicted': 48},
    {'id': 2, 'name': 'Ayam Geprek Sambal Matah', 'price': 18000, 'category': 'Makanan', 'icon': 'assets/images/sambal_matah.png', 'sold_today': 28, 'predicted': 32},
    {'id': 3, 'name': 'Nasi Putih', 'price': 5000, 'category': 'Makanan', 'icon': 'assets/images/nasi_putih.png', 'sold_today': 65, 'predicted': 72},
    {'id': 4, 'name': 'Es Teh Manis', 'price': 5000, 'category': 'Minuman', 'icon': 'assets/images/es_teh.png', 'sold_today': 55, 'predicted': 60},
    {'id': 5, 'name': 'Es Jeruk', 'price': 7000, 'category': 'Minuman', 'icon': 'assets/images/es_jeruk.png', 'sold_today': 30, 'predicted': 35},
    {'id': 6, 'name': 'Ayam Geprek Mozarella', 'price': 22000, 'category': 'Makanan', 'icon': 'assets/images/ayam_mozarella.png', 'sold_today': 15, 'predicted': 18},
    {'id': 7, 'name': 'Tahu Crispy', 'price': 3000, 'category': 'Tambahan', 'icon': 'assets/images/tahu_crispy.png', 'sold_today': 40, 'predicted': 45},
    {'id': 8, 'name': 'Tempe Goreng', 'price': 3000, 'category': 'Tambahan', 'icon': 'assets/images/tempe_goreng.png', 'sold_today': 35, 'predicted': 38},
  ];

  // Sales data for chart (last 7 days)
  static final List<Map<String, dynamic>> salesHistory = [
    {'day': 'Sen', 'sales': 1250000, 'portions': 85, 'waste': 12},
    {'day': 'Sel', 'sales': 1450000, 'portions': 98, 'waste': 8},
    {'day': 'Rab', 'sales': 1100000, 'portions': 75, 'waste': 15},
    {'day': 'Kam', 'sales': 1350000, 'portions': 92, 'waste': 6},
    {'day': 'Jum', 'sales': 1680000, 'portions': 115, 'waste': 4},
    {'day': 'Sab', 'sales': 2100000, 'portions': 142, 'waste': 3},
    {'day': 'Min', 'sales': 1950000, 'portions': 130, 'waste': 5},
  ];

  // Ingredient stock
  static final List<Map<String, dynamic>> ingredients = [
    {'name': 'Ayam Potong', 'unit': 'kg', 'stock': 8.5, 'min_stock': 5.0, 'price_per_unit': 35000, 'status': 'ok'},
    {'name': 'Beras', 'unit': 'kg', 'stock': 3.0, 'min_stock': 10.0, 'price_per_unit': 14000, 'status': 'low'},
    {'name': 'Tepung Terigu', 'unit': 'kg', 'stock': 2.0, 'min_stock': 3.0, 'price_per_unit': 12000, 'status': 'low'},
    {'name': 'Minyak Goreng', 'unit': 'liter', 'stock': 5.0, 'min_stock': 3.0, 'price_per_unit': 18000, 'status': 'ok'},
    {'name': 'Cabai Rawit', 'unit': 'kg', 'stock': 1.5, 'min_stock': 1.0, 'price_per_unit': 45000, 'status': 'ok'},
    {'name': 'Bawang Merah', 'unit': 'kg', 'stock': 0.5, 'min_stock': 1.0, 'price_per_unit': 32000, 'status': 'critical'},
    {'name': 'Bawang Putih', 'unit': 'kg', 'stock': 1.0, 'min_stock': 1.0, 'price_per_unit': 28000, 'status': 'warning'},
    {'name': 'Gula Pasir', 'unit': 'kg', 'stock': 4.0, 'min_stock': 2.0, 'price_per_unit': 16000, 'status': 'ok'},
    {'name': 'Teh Celup', 'unit': 'box', 'stock': 3.0, 'min_stock': 2.0, 'price_per_unit': 8000, 'status': 'ok'},
    {'name': 'Keju Mozarella', 'unit': 'kg', 'stock': 0.8, 'min_stock': 1.0, 'price_per_unit': 95000, 'status': 'low'},
  ];

  // Restock recommendations
  static final List<Map<String, dynamic>> restockItems = [
    {'name': 'Bawang Merah', 'needed': 2.0, 'unit': 'kg', 'cost': 64000, 'urgency': 'critical'},
    {'name': 'Beras', 'needed': 10.0, 'unit': 'kg', 'cost': 140000, 'urgency': 'high'},
    {'name': 'Tepung Terigu', 'needed': 5.0, 'unit': 'kg', 'cost': 60000, 'urgency': 'high'},
    {'name': 'Bawang Putih', 'needed': 1.0, 'unit': 'kg', 'cost': 28000, 'urgency': 'medium'},
    {'name': 'Keju Mozarella', 'needed': 1.0, 'unit': 'kg', 'cost': 95000, 'urgency': 'medium'},
  ];

  // Dashboard stats
  static const Map<String, dynamic> todayStats = {
    'total_sales': 1850000,
    'total_portions': 125,
    'total_waste': 5,
    'waste_reduction': 62,  // percentage reduction vs before WessLess
    'predicted_tomorrow': 135,
    'cost_saved': 185000,  // from waste reduction
  };

  // Forecast data
  static final List<Map<String, dynamic>> forecastData = [
    {'menu': 'Ayam Geprek Original', 'icon': 'assets/images/ayam_geprek.png', 'predicted': 48, 'confidence': 0.92, 'trend': 'up'},
    {'menu': 'Ayam Geprek Sambal Matah', 'icon': 'assets/images/sambal_matah.png', 'predicted': 32, 'confidence': 0.88, 'trend': 'up'},
    {'menu': 'Nasi Putih', 'icon': 'assets/images/nasi_putih.png', 'predicted': 72, 'confidence': 0.95, 'trend': 'stable'},
    {'menu': 'Es Teh Manis', 'icon': 'assets/images/es_teh.png', 'predicted': 60, 'confidence': 0.90, 'trend': 'up'},
    {'menu': 'Es Jeruk', 'icon': 'assets/images/es_jeruk.png', 'predicted': 35, 'confidence': 0.85, 'trend': 'down'},
    {'menu': 'Ayam Geprek Mozarella', 'icon': 'assets/images/ayam_mozarella.png', 'predicted': 18, 'confidence': 0.82, 'trend': 'up'},
    {'menu': 'Tahu Crispy', 'icon': 'assets/images/tahu_crispy.png', 'predicted': 45, 'confidence': 0.87, 'trend': 'stable'},
    {'menu': 'Tempe Goreng', 'icon': 'assets/images/tempe_goreng.png', 'predicted': 38, 'confidence': 0.86, 'trend': 'stable'},
  ];

  // Recent transactions
  static final List<Map<String, dynamic>> recentTransactions = [
    {'id': 'TRX-001', 'time': '11:42', 'items': ['Ayam Geprek Original', 'Nasi Putih', 'Es Teh'], 'total': 25000, 'qty': 3},
    {'id': 'TRX-002', 'time': '11:38', 'items': ['Ayam Geprek Mozarella', 'Nasi Putih', 'Es Jeruk'], 'total': 34000, 'qty': 3},
    {'id': 'TRX-003', 'time': '11:35', 'items': ['2x Ayam Geprek Original', '2x Nasi Putih', '2x Es Teh'], 'total': 50000, 'qty': 6},
    {'id': 'TRX-004', 'time': '11:30', 'items': ['Ayam Geprek Sambal Matah', 'Nasi Putih', 'Tahu Crispy'], 'total': 26000, 'qty': 3},
    {'id': 'TRX-005', 'time': '11:25', 'items': ['3x Ayam Geprek Original', '3x Nasi Putih'], 'total': 60000, 'qty': 6},
  ];

  static String formatCurrency(num amount) {
    final str = amount.toInt().toString();
    final result = StringBuffer();
    var count = 0;
    for (var i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        result.write('.');
      }
      result.write(str[i]);
      count++;
    }
    return 'Rp${result.toString().split('').reversed.join()}';
  }
}
