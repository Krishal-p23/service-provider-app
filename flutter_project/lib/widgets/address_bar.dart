import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/app_theme.dart';

class AddressBar extends StatelessWidget {
  const AddressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
<<<<<<< HEAD
    // final theme = Theme.of(context);
=======

    // Determine if user has a valid address
    final hasAddress = userProvider.isLoggedIn && 
                       userProvider.currentUser?.address != null &&
                       userProvider.currentUser!.address.isNotEmpty;
>>>>>>> kajal

    return InkWell(
      onTap: () {
        if (!userProvider.isLoggedIn) {
          Navigator.pushNamed(context, '/login');
        } else {
<<<<<<< HEAD
          _showAddressOptions(context);
=======
          _showAddressOptions(context, hasAddress);
>>>>>>> kajal
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        color: AppTheme.primaryColor,
        child: Row(
          children: [
<<<<<<< HEAD
            const Icon(Icons.location_on, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                userProvider.displayAddress,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
=======
            Icon(
              hasAddress ? Icons.location_on : Icons.location_off,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                hasAddress
                    ? userProvider.displayAddress
                    : 'Add your address',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontStyle: hasAddress ? FontStyle.normal : FontStyle.italic,
>>>>>>> kajal
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  void _showAddressOptions(BuildContext context) {
=======
  void _showAddressOptions(BuildContext context, bool hasAddress) {
>>>>>>> kajal
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
<<<<<<< HEAD
=======
            if (hasAddress)
              ListTile(
                leading: const Icon(Icons.edit_location),
                title: const Text('Edit current address'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/edit-profile');
                },
              ),
>>>>>>> kajal
            ListTile(
              leading: const Icon(Icons.my_location),
              title: const Text('Use current location'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
<<<<<<< HEAD
                  const SnackBar(content: Text('Location feature - UI only')),
=======
                  const SnackBar(content: Text('Location feature - Coming soon!')),
>>>>>>> kajal
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_location),
<<<<<<< HEAD
              title: const Text('Add address manually'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add address - UI only')),
                );
=======
              title: Text(hasAddress ? 'Add new address' : 'Add address manually'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/edit-profile');
>>>>>>> kajal
              },
            ),
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> kajal
