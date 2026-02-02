import 'package:flutter/material.dart';
import '../delegates/service_search_delegate.dart';

class StickySearchBar extends StatelessWidget {
  const StickySearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      color: theme.scaffoldBackgroundColor,
      child: InkWell(
        onTap: () {
          // Open the real search UI
          showSearch(
            context: context,
            delegate: ServiceSearchDelegate(),
          );
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(
                Icons.search,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Search for services...',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
              const Icon(Icons.mic_none, color: Colors.grey),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}