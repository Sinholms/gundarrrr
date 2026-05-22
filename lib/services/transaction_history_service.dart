import '../models/sales_transaction.dart';

class TransactionHistoryService {
  TransactionHistoryService._();

  static final List<SalesTransaction> _transactions = _seedTransactions();

  static List<SalesTransaction> get transactions {
    return List.unmodifiable(_transactions);
  }

  static List<SalesTransaction> get recentTransactions {
    final items = [..._transactions]
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return List.unmodifiable(items);
  }

  static void addTransaction(SalesTransaction transaction) {
    _transactions.insert(0, transaction);
  }

  static void clear() {
    _transactions.clear();
  }

  static List<SalesTransaction> _seedTransactions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      SalesTransaction(
        transactionId: 'TRX-001',
        dateTime: today.add(const Duration(hours: 14, minutes: 30)),
        items: const [
          SalesTransactionItem(
            itemName: 'Ayam Geprek Original',
            quantity: 2,
            price: 15000,
          ),
          SalesTransactionItem(
            itemName: 'Es Teh Manis',
            quantity: 1,
            price: 5000,
          ),
        ],
        totalAmount: 35000,
        paymentMethod: 'Tunai',
      ),
      SalesTransaction(
        transactionId: 'TRX-002',
        dateTime: today.add(const Duration(hours: 13, minutes: 12)),
        items: const [
          SalesTransactionItem(
            itemName: 'Ayam Geprek Sambal Matah',
            quantity: 1,
            price: 18000,
          ),
          SalesTransactionItem(
            itemName: 'Nasi Putih',
            quantity: 1,
            price: 5000,
          ),
          SalesTransactionItem(itemName: 'Es Jeruk', quantity: 1, price: 7000),
        ],
        totalAmount: 30000,
        paymentMethod: 'QRIS',
      ),
      SalesTransaction(
        transactionId: 'TRX-003',
        dateTime: today.add(const Duration(hours: 11, minutes: 45)),
        items: const [
          SalesTransactionItem(
            itemName: 'Ayam Geprek Mozarella',
            quantity: 1,
            price: 22000,
          ),
          SalesTransactionItem(
            itemName: 'Tahu Crispy',
            quantity: 2,
            price: 3000,
          ),
        ],
        totalAmount: 28000,
        paymentMethod: 'Midtrans',
      ),
      SalesTransaction(
        transactionId: 'TRX-004',
        dateTime: today
            .subtract(const Duration(days: 1))
            .add(const Duration(hours: 18, minutes: 5)),
        items: const [
          SalesTransactionItem(
            itemName: 'Ayam Geprek Original',
            quantity: 3,
            price: 15000,
          ),
          SalesTransactionItem(
            itemName: 'Nasi Putih',
            quantity: 3,
            price: 5000,
          ),
          SalesTransactionItem(
            itemName: 'Es Teh Manis',
            quantity: 2,
            price: 5000,
          ),
        ],
        totalAmount: 70000,
        paymentMethod: 'Tunai',
      ),
      SalesTransaction(
        transactionId: 'TRX-005',
        dateTime: today
            .subtract(const Duration(days: 3))
            .add(const Duration(hours: 12, minutes: 20)),
        items: const [
          SalesTransactionItem(
            itemName: 'Ayam Geprek Sambal Matah',
            quantity: 2,
            price: 18000,
          ),
          SalesTransactionItem(
            itemName: 'Tempe Goreng',
            quantity: 2,
            price: 3000,
          ),
          SalesTransactionItem(itemName: 'Es Jeruk', quantity: 2, price: 7000),
        ],
        totalAmount: 56000,
        paymentMethod: 'QRIS',
      ),
      SalesTransaction(
        transactionId: 'TRX-006',
        dateTime: today
            .subtract(const Duration(days: 7))
            .add(const Duration(hours: 16, minutes: 40)),
        items: const [
          SalesTransactionItem(
            itemName: 'Ayam Geprek Original',
            quantity: 1,
            price: 15000,
          ),
          SalesTransactionItem(
            itemName: 'Nasi Putih',
            quantity: 1,
            price: 5000,
          ),
        ],
        totalAmount: 20000,
        paymentMethod: 'Tunai',
      ),
    ];
  }
}
