import 'package:flutter/foundation.dart';
import '../models/wallet_transaction.dart';
import '../utils/mock_data.dart';

class WalletProvider with ChangeNotifier {
  List<WalletTransaction> _transactions = [];
  
  List<WalletTransaction> get transactions => _transactions;

  WalletProvider() {
    _loadTransactions();
  }

  void _loadTransactions() {
    _transactions = MockDatabase.walletTransactions;
    notifyListeners();
  }

  // Get user wallet balance
  double getUserBalance(int userId) {
    return MockDatabase.getUserWalletBalance(userId);
  }

  // Get user transactions
  List<WalletTransaction> getUserTransactions(int userId) {
    final userTransactions = MockDatabase.getWalletTransactionsByUserId(userId);
    // Sort by date (newest first)
    userTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return userTransactions;
  }

  // Get transactions by type
  List<WalletTransaction> getTransactionsByType(int userId, String type) {
    final userTransactions = getUserTransactions(userId);
    return userTransactions.where((t) => t.type == type).toList();
  }

  // Add money to wallet
  Future<void> addMoney({
    required int userId,
    required double amount,
    required String description,
  }) async {
    final transactionId = MockDatabase.generateId(MockDatabase.walletTransactions);
    
    final transaction = WalletTransaction(
      id: transactionId,
      userId: userId,
      amount: amount,
      type: 'credit',
      description: description,
      createdAt: DateTime.now(),
    );

    MockDatabase.addWalletTransaction(transaction);
    _loadTransactions();
  }

  // Deduct money from wallet
  Future<bool> deductMoney({
    required int userId,
    required double amount,
    required String description,
  }) async {
    // Check if user has sufficient balance
    final balance = getUserBalance(userId);
    if (balance < amount) {
      return false;
    }

    final transactionId = MockDatabase.generateId(MockDatabase.walletTransactions);
    
    final transaction = WalletTransaction(
      id: transactionId,
      userId: userId,
      amount: amount,
      type: 'debit',
      description: description,
      createdAt: DateTime.now(),
    );

    MockDatabase.addWalletTransaction(transaction);
    _loadTransactions();
    return true;
  }

  // Process refund
  Future<void> processRefund({
    required int userId,
    required double amount,
    required String description,
  }) async {
    final transactionId = MockDatabase.generateId(MockDatabase.walletTransactions);
    
    final transaction = WalletTransaction(
      id: transactionId,
      userId: userId,
      amount: amount,
      type: 'refund',
      description: description,
      createdAt: DateTime.now(),
    );

    MockDatabase.addWalletTransaction(transaction);
    _loadTransactions();
  }

  // Get recent transactions (last 10)
  List<WalletTransaction> getRecentTransactions(int userId) {
    final userTransactions = getUserTransactions(userId);
    return userTransactions.take(10).toList();
  }

  // Get credit transactions
  List<WalletTransaction> getCreditTransactions(int userId) {
    return getTransactionsByType(userId, 'credit');
  }

  // Get debit transactions
  List<WalletTransaction> getDebitTransactions(int userId) {
    return getTransactionsByType(userId, 'debit');
  }

  // Get refund transactions
  List<WalletTransaction> getRefundTransactions(int userId) {
    return getTransactionsByType(userId, 'refund');
  }

  // Get transactions for a specific period
  List<WalletTransaction> getTransactionsByDateRange({
    required int userId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final userTransactions = getUserTransactions(userId);
    return userTransactions.where((t) {
      return t.createdAt.isAfter(startDate) && t.createdAt.isBefore(endDate);
    }).toList();
  }
}