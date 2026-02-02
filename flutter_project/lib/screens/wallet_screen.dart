import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 80,
              color: theme.primaryColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'Wallet Feature',
              style: theme.textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}