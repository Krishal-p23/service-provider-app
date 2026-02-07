import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_project/customer/providers/wallet_provider.dart';
import 'package:flutter_project/providers/user_provider.dart';
import 'package:flutter_project/customer/models/wallet_transaction.dart';
import 'package:flutter_project/customer/widgets/wallet_transaction_card.dart';
import 'package:flutter_project/theme/app_theme.dart'; // Import AppTheme
import 'package:intl/intl.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final walletProvider = Provider.of<WalletProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('My Wallet'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 80,
                color: AppTheme.getTextColor(context, secondary: true).withOpacity(0.3),
              ),
              const SizedBox(height: 20),
              Text(
                'Please log in to access your wallet',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.getTextColor(context),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Login / Register'),
              ),
            ],
          ),
        ),
      );
    }

    final int userId = currentUser.id;
    final double balance = walletProvider.getUserBalance(userId);
    final List<WalletTransaction> allTransactions = walletProvider.getUserTransactions(userId);
    final List<WalletTransaction> creditTransactions = walletProvider.getCreditTransactions(userId);
    final List<WalletTransaction> debitTransactions = walletProvider.getDebitTransactions(userId);

    double totalReceived = creditTransactions.fold(0.0, (sum, t) => sum + t.amount);
    double totalSpent = debitTransactions.fold(0.0, (sum, t) => sum + t.amount);
    double totalRefunded = walletProvider.getRefundTransactions(userId).fold(0.0, (sum, t) => sum + t.amount);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Wallet'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Balance Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.account_balance_wallet, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text('Active', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '₹${balance.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        context,
                        icon: Icons.add_circle_outline,
                        label: 'Add Money',
                        onTap: () => _showAddMoneyBottomSheet(context, userId),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionButton(
                        context,
                        icon: Icons.send_outlined,
                        label: 'Send',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Quick Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _buildStatCard(context, icon: Icons.arrow_downward, iconColor: AppTheme.successColor, label: 'Received', amount: totalReceived)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(context, icon: Icons.arrow_upward, iconColor: AppTheme.errorColor, label: 'Spent', amount: totalSpent)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(context, icon: Icons.replay, iconColor: AppTheme.infoColor, label: 'Refunds', amount: totalRefunded)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.getDividerColor(context)),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.getTextColor(context, secondary: true),
              tabs: const [Tab(text: 'All'), Tab(text: 'Credit'), Tab(text: 'Debit')],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionList(allTransactions),
                _buildTransactionList(creditTransactions),
                _buildTransactionList(debitTransactions),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return Material(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {required IconData icon, required Color iconColor, required String label, required double amount}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getDividerColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: AppTheme.getTextColor(context, secondary: true), fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('₹${amount.toStringAsFixed(0)}', style: TextStyle(color: AppTheme.getTextColor(context), fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<WalletTransaction> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.getTextColor(context, secondary: true).withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('No transactions yet', style: TextStyle(color: AppTheme.getTextColor(context, secondary: true))),
          ],
        ),
      );
    }

    Map<String, List<WalletTransaction>> groupedTransactions = {};
    for (var transaction in transactions) {
      String dateKey = DateFormat('dd MMM yyyy').format(transaction.createdAt);
      groupedTransactions.putIfAbsent(dateKey, () => []).add(transaction);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        String dateKey = groupedTransactions.keys.elementAt(index);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(dateKey, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.getTextColor(context, secondary: true))),
            ),
            ...groupedTransactions[dateKey]!.map((t) => WalletTransactionCard(transaction: t)),
          ],
        );
      },
    );
  }

  void _showAddMoneyBottomSheet(BuildContext context, int userId) {
    final theme = Theme.of(context);
    final amountController = TextEditingController();
    final List<int> quickAmounts = [100, 500, 1000, 2000, 5000];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add Money to Wallet', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.getTextColor(context))),
                  IconButton(icon: Icon(Icons.close, color: AppTheme.getTextColor(context)), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.getTextColor(context)),
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16, top: 14),
                    child: Text('₹', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.getTextColor(context))),
                  ),
                  hintText: 'Enter amount',
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.getDividerColor(context))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: quickAmounts.map((amount) {
                  return InkWell(
                    onTap: () => amountController.text = amount.toString(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text('₹$amount', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text);
                    if (amount != null && amount > 0) {
                      await Provider.of<WalletProvider>(context, listen: false).addMoney(userId: userId, amount: amount, description: 'Money added to wallet');
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Add Money', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}