class SalesTransactionItem {
  final String itemName;
  final int quantity;
  final int price;

  const SalesTransactionItem({
    required this.itemName,
    required this.quantity,
    required this.price,
  });

  int get subtotal => price * quantity;
}

class SalesTransaction {
  final String transactionId;
  final DateTime dateTime;
  final List<SalesTransactionItem> items;
  final int totalAmount;
  final String paymentMethod;

  const SalesTransaction({
    required this.transactionId,
    required this.dateTime,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
  });

  DateTime get date => DateTime(dateTime.year, dateTime.month, dateTime.day);

  String get time {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  int get totalQuantity {
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }
}

class SalesSummary {
  final int totalRevenue;
  final int transactionCount;
  final int totalItemsSold;

  const SalesSummary({
    required this.totalRevenue,
    required this.transactionCount,
    required this.totalItemsSold,
  });

  static const empty = SalesSummary(
    totalRevenue: 0,
    transactionCount: 0,
    totalItemsSold: 0,
  );
}
