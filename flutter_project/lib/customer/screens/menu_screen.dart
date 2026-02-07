// import 'package:flutter/material.dart';
// import 'package:flutter_project/screens/settings/help_support_screen.dart';
// import 'package:flutter_project/screens/settings/language_screen.dart';
// import 'package:flutter_project/screens/settings/rate_us_screen.dart';
// import 'package:flutter_project/screens/settings/settings_screen.dart';
// import 'package:flutter_project/screens/settings/share_app_bottom_sheet.dart';


// class MenuScreen extends StatelessWidget {
//   const MenuScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // final theme = Theme.of(context);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Menu')),
//       body: ListView(
//         padding: const EdgeInsets.only(bottom: 80),
//         children: [
//           _buildMenuItem(
//             context,
//             icon: Icons.help_outline,
//             title: 'Help & Support',
//             onTap: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Help & Support - UI only')),
//               );
//             },
//           ),
//           _buildMenuItem(
//             context,
//             icon: Icons.settings,
//             title: 'Settings',
//             onTap: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Settings - UI only')),
//               );
//             },
//           ),
//           _buildMenuItem(
//             context,
//             icon: Icons.language,
//             title: 'Language',
//             onTap: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Language - UI only')),
//               );
//             },
//           ),
//           _buildMenuItem(
//             context,
//             icon: Icons.share,
//             title: 'Share App',
//             onTap: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Share app - UI only')),
//               );
//             },
//           ),
//           _buildMenuItem(
//             context,
//             icon: Icons.star_rate,
//             title: 'Rate Us',
//             onTap: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Rate us - UI only')),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMenuItem(
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//       child: ListTile(
//         leading: Icon(icon),
//         title: Text(title),
//         trailing: const Icon(Icons.chevron_right),
//         onTap: onTap,
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_project/customer/screens/settings/help_support_screen.dart';
import 'package:flutter_project/customer/screens/settings/language_screen.dart';
import 'package:flutter_project/customer/screens/settings/rate_us_screen.dart';
import 'package:flutter_project/customer/screens/settings/settings_screen.dart';
import 'package:flutter_project/customer/screens/settings/share_app_bottom_sheet.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          _buildMenuItem(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.language,
            title: 'Language',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LanguageScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.share,
            title: 'Share App',
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const ShareAppBottomSheet(),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.star_rate,
            title: 'Rate Us',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RateUsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}