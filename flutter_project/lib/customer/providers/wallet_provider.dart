import 'package:flutter/foundation.dart';
import '../models/wallet_transaction.dart';
import '../services/api_service.dart';

class WalletProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<WalletTransaction> _transactions = [];

  List<WalletTransaction> get transactions => _transactions;

  // Get user wallet balance
  Future<double> getUserBalance(int userId) async {
    await _apiService.initialize();
    final result = await _apiService.getUserWalletBalance(userId);
    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>;
      return ((data['balance'] ?? 0) as num).toDouble();
    }
    return 0;
  }

  // Get user transactions
  Future<List<WalletTransaction>> getUserTransactions(int userId) async {
    await _apiService.initialize();
    final result = await _apiService.getUserWalletTransactions(userId);
    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>;
      final items = (data['transactions'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(WalletTransaction.fromJson)
          .toList();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _transactions = items;
      notifyListeners();
      return items;
    }
    _transactions = <WalletTransaction>[];
    notifyListeners();
    return <WalletTransaction>[];
  }

  // Get transactions by type
  Future<List<WalletTransaction>> getTransactionsByType(
    int userId,
    String type,
  ) async {
    final userTransactions = await getUserTransactions(userId);
    return userTransactions.where((t) => t.type == type).toList();
  }

  // Add money to wallet
  Future<void> addMoney({
    required int userId,
    required double amount,
    required String description,
  }) async {
    await _apiService.initialize();
    await _apiService.addMoneyToWallet(
      userId: userId,
      amount: amount,
      description: description,
    );
    await getUserTransactions(userId);
  }

  // Deduct money from wallet
  Future<bool> deductMoney({
    required int userId,
    required double amount,
    required String description,
  }) async {
    await _apiService.initialize();
    final result = await _apiService.deductMoneyFromWallet(
      userId: userId,
      amount: amount,
      description: description,
    );
    if (result['success'] == true) {
      await getUserTransactions(userId);
      return true;
    }
    return false;
  }

  // Process refund
  Future<void> processRefund({
    required int userId,
    required double amount,
    required String description,
  }) async {
    await _apiService.initialize();
    await _apiService.processWalletRefund(
      userId: userId,
      amount: amount,
      description: description,
    );
    await getUserTransactions(userId);
  }

  // Get recent transactions (last 10)
  Future<List<WalletTransaction>> getRecentTransactions(int userId) async {
    final userTransactions = await getUserTransactions(userId);
    return userTransactions.take(10).toList();
  }

  // Get credit transactions
  Future<List<WalletTransaction>> getCreditTransactions(int userId) async {
    return getTransactionsByType(userId, 'credit');
  }

  // Get debit transactions
  Future<List<WalletTransaction>> getDebitTransactions(int userId) async {
    return getTransactionsByType(userId, 'debit');
  }

  // Get refund transactions
  Future<List<WalletTransaction>> getRefundTransactions(int userId) async {
    return getTransactionsByType(userId, 'refund');
  }

  // Get transactions for a specific period
  Future<List<WalletTransaction>> getTransactionsByDateRange({
    required int userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final userTransactions = await getUserTransactions(userId);
    return userTransactions.where((t) {
      return t.createdAt.isAfter(startDate) && t.createdAt.isBefore(endDate);
    }).toList();
  }
}
