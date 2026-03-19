import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Language')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: languageProvider.availableLanguages.length,
              itemBuilder: (context, index) {
                final language = languageProvider.availableLanguages[index];
                final isSelected = languageProvider.currentLanguage == language['name'];
                final isEnabled = language['enabled'];

                return ListTile(
                  title: Text(language['name']),
                  subtitle: !isEnabled ? const Text('Coming Soon') : null,
                  trailing: isSelected ? Icon(Icons.check_circle, color: theme.primaryColor) : null,
                  enabled: isEnabled,
                  onTap: isEnabled
                      ? () => languageProvider.setLanguage(language['name'])
                      : null,
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    languageProvider.applyLanguage();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Language updated successfully')),
                    );
                  },
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Apply', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}