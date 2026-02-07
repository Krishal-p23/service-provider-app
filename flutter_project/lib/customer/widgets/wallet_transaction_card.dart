// import 'package:flutter/material.dart';
// import '../models/wallet_transaction.dart';
// import 'package:intl/intl.dart';

// class WalletTransactionCard extends StatelessWidget {
//   final WalletTransaction transaction;

//   const WalletTransactionCard({
//     super.key,
//     required this.transaction,
//   });

//   IconData _getTransactionIcon(String type) {
//     switch (type.toLowerCase()) {
//       case 'credit':
//         return Icons.add_circle_outline;
//       case 'debit':
//         return Icons.remove_circle_outline;
//       case 'refund':
//         return Icons.replay_circle_filled_outlined;
//       default:
//         return Icons.account_balance_wallet_outlined;
//     }
//   }

//   Color _getTransactionColor(String type, ThemeData theme) {
//     switch (type.toLowerCase()) {
//       case 'credit':
//         return Colors.green;
//       case 'debit':
//         return Colors.red;
//       case 'refund':
//         return Colors.orange;
//       default:
//         return theme.primaryColor;
//     }
//   }

//   String _getTransactionSign(String type) {
//     switch (type.toLowerCase()) {
//       case 'credit':
//       case 'refund':
//         return '+';
//       case 'debit':
//         return '-';
//       default:
//         return '';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final dateFormat = DateFormat('MMM dd, yyyy');
//     final timeFormat = DateFormat('h:mm a');

//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Row(
//           children: [
//             // Icon
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: _getTransactionColor(transaction.type, theme)
//                     .withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 _getTransactionIcon(transaction.type),
//                 color: _getTransactionColor(transaction.type, theme),
//                 size: 24,
//               ),
//             ),
//             const SizedBox(width: 12),
            
//             // Transaction Details
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     transaction.description,
//                     style: theme.textTheme.bodyLarge?.copyWith(
//                       fontWeight: FontWeight.w600,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Text(
//                         dateFormat.format(transaction.createdAt),
//                         style: theme.textTheme.bodySmall,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         '•',
//                         style: theme.textTheme.bodySmall,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         timeFormat.format(transaction.createdAt),
//                         style: theme.textTheme.bodySmall,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
            
//             // Amount
//             Text(
//               '${_getTransactionSign(transaction.type)}₹${transaction.amount.toStringAsFixed(0)}',
//               style: theme.textTheme.displaySmall?.copyWith(
//                 color: _getTransactionColor(transaction.type, theme),
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../models/wallet_transaction.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart'; // Using your AppTheme

class WalletTransactionCard extends StatelessWidget {
  final WalletTransaction transaction;

  const WalletTransactionCard({
    super.key,
    required this.transaction,
  });

  IconData _getTransactionIcon(String type) {
    switch (type.toLowerCase()) {
      case 'credit':
        return Icons.add_circle_outline;
      case 'debit':
        return Icons.remove_circle_outline;
      case 'refund':
        return Icons.replay_circle_filled_outlined;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  // Updated to use AppTheme semantic colors
  Color _getTransactionColor(String type) {
    switch (type.toLowerCase()) {
      case 'credit':
        return AppTheme.successColor;
      case 'debit':
        return AppTheme.errorColor;
      case 'refund':
        return AppTheme.warningColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _getTransactionSign(String type) {
    switch (type.toLowerCase()) {
      case 'credit':
      case 'refund':
        return '+';
      case 'debit':
        return '-';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final color = _getTransactionColor(transaction.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context), // Using AppTheme helper
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getDividerColor(context)),
      ),
      child: Row(
        children: [
          // Icon
          Icon(
            _getTransactionIcon(transaction.type),
            color: color,
            size: 28,
          ),
          const SizedBox(width: 16),
          
          // Content - FIXED OVERFLOW
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextColor(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // Truncates if too long
                ),
                const SizedBox(height: 4),
                Text(
                  '${dateFormat.format(transaction.createdAt)} • ${timeFormat.format(transaction.createdAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.getTextColor(context, secondary: true),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Amount
          Text(
            '${_getTransactionSign(transaction.type)}₹${transaction.amount.toStringAsFixed(0)}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}