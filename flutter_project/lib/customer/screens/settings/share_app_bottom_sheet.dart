import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Required import
import 'package:share_plus/share_plus.dart';

class ShareAppBottomSheet extends StatelessWidget {
  const ShareAppBottomSheet({super.key});

  static const String _defaultShareUrl = String.fromEnvironment(
    'APP_SHARE_URL',
    defaultValue: 'https://servigopro.onrender.com/downloads/servigo-app.apk',
  );

  static const String _shareText =
      'Try Servigo app. Download here: $_defaultShareUrl';

  Future<void> _share(BuildContext context, {String? channelHint}) async {
    try {
      await Share.share(
        channelHint == null
            ? _shareText
            : '$_shareText\nShared via $channelHint',
        subject: 'Servigo App',
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open share options')),
        );
      }
    }
  }

  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: _defaultShareUrl));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('APK link copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text('Share App', style: theme.textTheme.displayMedium),
          const SizedBox(height: 24),

          // Share Options Grid
          // ... inside ShareAppBottomSheet Column children ...

          // Share Options Grid
          GridView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(), // Important inside a BottomSheet
            itemCount: 6, // Total number of options
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio:
                  0.8, // Adjusted ratio to give the text more vertical room
            ),
            itemBuilder: (context, index) {
              // List of data for each index
              final options = [
                {
                  'icon': FontAwesomeIcons.whatsapp,
                  'label': 'WhatsApp',
                  'color': const Color(0xFF25D366),
                },
                {'icon': Icons.email, 'label': 'Email', 'color': Colors.red},
                {
                  'icon': FontAwesomeIcons.telegram,
                  'label': 'Telegram',
                  'color': const Color(0xFF0088CC),
                },
                {
                  'icon': FontAwesomeIcons.facebook,
                  'label': 'Facebook',
                  'color': const Color(0xFF1877F2),
                },
                {
                  'icon': Icons.link,
                  'label': 'Copy Link',
                  'color': Colors.grey,
                },
                {
                  'icon': Icons.more_horiz,
                  'label': 'More',
                  'color': Colors.grey,
                },
              ];

              final option = options[index];

              return _ShareOption(
                icon: option['icon'] as IconData,
                label: option['label'] as String,
                color: option['color'] as Color,
                onTap: () async {
                  final label = option['label'] as String;
                  Navigator.pop(context);

                  if (label == 'Copy Link') {
                    await _copyLink(context);
                    return;
                  }

                  await _share(
                    context,
                    channelHint: label == 'More' ? null : label,
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(
                0.1,
              ), // Fixed from withValues for broader compatibility
              borderRadius: BorderRadius.circular(12),
            ),
            child: FaIcon(
              icon,
              color: color,
              size: 28,
            ), // Changed Icon to FaIcon
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
