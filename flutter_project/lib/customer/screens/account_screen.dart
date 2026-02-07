import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/theme_provider.dart';
import '../../theme/app_theme.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final isLoggedIn = userProvider.isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingXLarge),
              color: theme.primaryColor.withOpacity(0.1),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.primaryColor,
                    child: Text(
                      isLoggedIn
                          ? userProvider.currentUser!.name[0].toUpperCase()
                          : 'G',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  Text(
                    isLoggedIn ? userProvider.currentUser!.name : 'Guest User',
                    style: theme.textTheme.displayMedium,
                  ),
                  if (isLoggedIn) ...[
                    const SizedBox(height: AppTheme.spacingXSmall),
                    Text(
                      userProvider.currentUser!.email,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                  if (!isLoggedIn) ...[
                    const SizedBox(height: AppTheme.spacingLarge),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text('Login / Register'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingSmall),

            if (isLoggedIn) ...[
              _buildSection(
                context,
                title: 'Manage Account',
                children: [
                  _buildListTile(
                    context,
                    icon: Icons.edit,
                    title: 'Edit Profile',
                    onTap: () {
                      Navigator.pushNamed(context, '/edit-profile');
                    },
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.phone,
                    title: 'Mobile Number',
                    subtitle: userProvider.currentUser!.phone.isNotEmpty
                        ? userProvider.currentUser!.phone
                        : 'No mobile number added',
                    onTap: () {},
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.location_on,
                    title: 'Saved Address',
                    subtitle: userProvider.currentUserLocation != null &&
                            userProvider.currentUserLocation!.address.isNotEmpty
                        ? userProvider.currentUserLocation!.address
                        : 'No address added',
                    onTap: () {
                      Navigator.pushNamed(context, '/edit-profile');
                    },
                  ),
                ],
              ),
            ],

            _buildSection(
              context,
              title: 'Appearance',
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLarge,
                    vertical: AppTheme.spacingSmall,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.brightness_6),
                      const SizedBox(width: AppTheme.spacingLarge),
                      const Expanded(
                        child: Text(
                          'Appearance Mode',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Switch(
                        activeColor: theme.primaryColor,
                        value: themeProvider.themeMode == AppThemeMode.dark,
                        onChanged: (value) {
                          themeProvider.setThemeMode(
                            value ? AppThemeMode.dark : AppThemeMode.light,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLarge,
                    vertical: AppTheme.spacingSmall,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.palette),
                      const SizedBox(width: AppTheme.spacingLarge),
                      const Expanded(
                        child: Text(
                          'Theme Mode',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      DropdownButton<AppThemeMode>(
                        value: themeProvider.themeMode,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                            value: AppThemeMode.light,
                            child: Text('Light'),
                          ),
                          DropdownMenuItem(
                            value: AppThemeMode.dark,
                            child: Text('Dark'),
                          ),
                          DropdownMenuItem(
                            value: AppThemeMode.system,
                            child: Text('System'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            themeProvider.setThemeMode(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (isLoggedIn)
              _buildSection(
                context,
                title: 'Activity',
                children: [
                  _buildListTile(
                    context,
                    icon: Icons.star,
                    title: 'My Reviews',
                    onTap: () {
                      Navigator.pushNamed(context, '/reviews');
                    },
                  ),
                ],
              ),

            if (isLoggedIn)
              _buildSection(
                context,
                title: 'Settings',
                children: [
                  _buildListTile(
                    context,
                    icon: Icons.settings,
                    title: 'App Settings',
                    onTap: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                ],
              ),

            if (isLoggedIn)
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLarge),
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await userProvider.logout();
                              if (context.mounted) {
                                Navigator.pop(context);
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/',
                                  (route) => false,
                                );
                              }
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 0.5),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 24,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacingLarge,
            AppTheme.spacingLarge,
            AppTheme.spacingLarge,
            AppTheme.spacingSmall,
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:image_picker/image_picker.dart';
// import '../../providers/user_provider.dart';
// import '../../theme/theme_provider.dart';

// class AccountScreen extends StatelessWidget { // Account screen with profile management and settings
//   const AccountScreen({super.key});

//   Future<void> _showProfileOptions(BuildContext context) async {// Show options to manage profile picture
//     final userProvider = context.read<UserProvider>();
//     final hasPhoto = userProvider.currentUser?.profilePicture != null;  // Check if user has a profile picture

//     await showModalBottomSheet(
//       context: context,
//       builder: (context) => SafeArea(
//         child: Wrap(
//           children: [
//             ListTile(
//               leading: const Icon(Icons.visibility),
//               title: const Text('View Profile Picture'),
//               onTap: () {
//                 Navigator.pop(context);
//                 if (hasPhoto) {
//                   _showFullImage(context, userProvider.currentUser!.profilePicture!);
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('No profile picture to view')),
//                   );
//                 }
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo_library),
//               title: const Text('Change from Gallery'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickAndUpdateImage(context, ImageSource.gallery);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.camera_alt),
//               title: const Text('Take a Photo'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickAndUpdateImage(context, ImageSource.camera);
//               },
//             ),
//             if (hasPhoto)
//               ListTile(
//                 leading: const Icon(Icons.delete, color: Colors.red),
//                 title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
//                 onTap: () {
//                   Navigator.pop(context);
//                   userProvider.updateProfilePicture(null);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Profile picture removed')),
//                   );
//                 },
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _pickAndUpdateImage(BuildContext context, ImageSource source) async {
//     try {
//       final imagePicker = ImagePicker();
//       final XFile? image = await imagePicker.pickImage(
//         source: source,
//         maxWidth: 512,
//         maxHeight: 512,
//         imageQuality: 75,
//       );

//       if (image != null && context.mounted) {
//         context.read<UserProvider>().updateProfilePicture(image.path);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Profile picture updated!')),
//         );
//       }
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e')),
//         );
//       }
//     }
//   }

//   void _showFullImage(BuildContext context, String imagePath) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             AppBar(
//               title: const Text('Profile Picture'),
//               automaticallyImplyLeading: false,
//               actions: [
//                 IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ],
//             ),
//             Image.file(File(imagePath), fit: BoxFit.contain),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userProvider = context.watch<UserProvider>();
//     final themeProvider = context.watch<ThemeProvider>();
//     final theme = Theme.of(context);
//     final isLoggedIn = userProvider.isLoggedIn;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Account'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications_outlined),
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('No new notifications'),
//                   duration: Duration(seconds: 2),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Profile Header
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               color: theme.primaryColor.withOpacity(0.1),
//               child: Column(
//                 children: [
//                   // Profile Picture with tap handler
//                   GestureDetector(
//                     onTap: isLoggedIn ? () => _showProfileOptions(context) : null,
//                     child: Stack(
//                       children: [
//                         CircleAvatar(
//                           radius: 50,
//                           backgroundColor: theme.primaryColor,
//                           backgroundImage: isLoggedIn &&
//                                   userProvider.currentUser?.profilePicture != null
//                               ? FileImage(
//                                   File(userProvider.currentUser!.profilePicture!))
//                               : null,
//                           child: !isLoggedIn ||
//                                   userProvider.currentUser?.profilePicture == null
//                               ? Text(
//                                   isLoggedIn
//                                       ? userProvider.currentUser!.name[0]
//                                           .toUpperCase()
//                                       : 'G',
//                                   style: const TextStyle(
//                                     fontSize: 40,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 )
//                               : null,
//                         ),
//                         if (isLoggedIn)
//                           Positioned(
//                             bottom: 0,
//                             right: 0,
//                             child: Container(
//                               padding: const EdgeInsets.all(4),
//                               decoration: BoxDecoration(
//                                 color: theme.primaryColor,
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(
//                                 Icons.camera_alt,
//                                 color: Colors.white,
//                                 size: 16,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     isLoggedIn ? userProvider.currentUser!.name : 'Guest User',
//                     style: theme.textTheme.displayMedium,
//                   ),
//                   if (isLoggedIn) ...[
//                     const SizedBox(height: 4),
//                     Text(
//                       userProvider.currentUser!.email,
//                       style: theme.textTheme.bodyMedium,
//                     ),
//                   ],
//                   if (!isLoggedIn) ...[
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: () {
//                         Navigator.pushNamed(context, '/login');
//                       },
//                       child: const Text('Login / Register'),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//             const SizedBox(height: 8),

//             // Logged-in user options
//             if (isLoggedIn) ...[
//               _buildSection(
//                 context,
//                 title: 'Manage Account',
//                 children: [
//                   _buildListTile(
//                     context,
//                     icon: Icons.edit,
//                     title: 'Edit Profile',
//                     onTap: () {
//                       Navigator.pushNamed(context, '/edit-profile');
//                     },
//                   ),
//                   _buildListTile(
//                     context,
//                     icon: Icons.phone,
//                     title: 'Mobile Number',
//                     subtitle: userProvider.currentUser!.phone.isNotEmpty
//                         ? userProvider.currentUser!.phone
//                         : 'No mobile number added',
//                     onTap: () {},
//                   ),
//                   _buildListTile(
//                     context,
//                     icon: Icons.location_on,
//                     title: 'Saved Address',
//                     subtitle: userProvider.currentUser!.address.isNotEmpty
//                         ? userProvider.currentUser!.address
//                         : 'No address added',
//                     onTap: () {},
//                   ),
//                 ],
//               ),
//             ],

//             // Appearance Settings (Available for all users)
//             _buildSection(
//               context,
//               title: 'Appearance',
//               children: [
//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: Row(
//                     children: [
//                       const Icon(Icons.brightness_6),
//                       const SizedBox(width: 16),
//                       const Expanded(
//                         child: Text(
//                           'Appearance Mode',
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       ),
//                       Switch(
//                         value: themeProvider.themeMode == AppThemeMode.dark,
//                         onChanged: (value) {
//                           themeProvider.setThemeMode(
//                             value ? AppThemeMode.dark : AppThemeMode.light,
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: Row(
//                     children: [
//                       const Icon(Icons.palette),
//                       const SizedBox(width: 16),
//                       const Expanded(
//                         child: Text(
//                           'Theme Mode',
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       ),
//                       DropdownButton<AppThemeMode>(
//                         value: themeProvider.themeMode,
//                         underline: const SizedBox(),
//                         items: const [
//                           DropdownMenuItem(
//                             value: AppThemeMode.light,
//                             child: Text('Light'),
//                           ),
//                           DropdownMenuItem(
//                             value: AppThemeMode.dark,
//                             child: Text('Dark'),
//                           ),
//                           DropdownMenuItem(
//                             value: AppThemeMode.system,
//                             child: Text('System'),
//                           ),
//                         ],
//                         onChanged: (value) {
//                           if (value != null) {
//                             themeProvider.setThemeMode(value);
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             // Activity (Only for logged-in users)
//             if (isLoggedIn)
//               _buildSection(
//                 context,
//                 title: 'Activity',
//                 children: [
//                   _buildListTile(
//                     context,
//                     icon: Icons.star,
//                     title: 'My Reviews',
//                     onTap: () {
//                       Navigator.pushNamed(context, '/reviews');
//                     },
//                   ),
//                   // Removed Favorites ListTile as requested
//                 ],
//               ),

//             // Information section removed as requested

//             // Logout (Only for logged-in users)
//             if (isLoggedIn)
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: OutlinedButton.icon(
//                   onPressed: () {
//                     showDialog(
//                       context: context,
//                       builder: (context) => AlertDialog(
//                         title: const Text('Logout', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
//                         content: const Text('Are you sure you want to logout?'),
//                         actions: [
//                           TextButton(
//                             onPressed: () => Navigator.pop(context),
//                             child: const Text('Cancel'),
//                           ),
//                           TextButton(
//                             onPressed: () async {
//                               await userProvider.logout();
//                               if (context.mounted) {
//                                 Navigator.pop(context);
//                                 Navigator.pushNamedAndRemoveUntil(
//                                   context,
//                                   '/',
//                                   (route) => false,
//                                 );
//                               }
//                             },
//                             child: const Text('Logout'),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                   icon: const Icon(Icons.logout),
//                   label: const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: Colors.red,
//                     side: const BorderSide(color: Colors.red, width: 0.5),
//                     padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
//                   ),
//                 ),
//               ),
//             const SizedBox(height: 80),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSection( 
//     BuildContext context, {
//     required String title,
//     required List<Widget> children,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//           child: Text(
//             title,
//             style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: Theme.of(context).primaryColor,
//                 ),
//           ),
//         ),
//         Card(
//           margin: const EdgeInsets.symmetric(horizontal: 12),
//           child: Column(children: children),
//         ),
//       ],
//     );
//   }

//   Widget _buildListTile( 
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     String? subtitle,
//     required VoidCallback onTap,
//   }) {
//     return ListTile(
//       leading: Icon(icon),
//       title: Text(title),
//       subtitle: subtitle != null ? Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
//       trailing: const Icon(Icons.chevron_right),
//       onTap: onTap,
//     );
//   }
// }