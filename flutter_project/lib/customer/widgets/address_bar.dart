import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/theme_provider.dart';
import '../../theme/app_theme.dart';
import '../services/location_service.dart';

class AddressBar extends StatelessWidget {
  const AddressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    // Determine if user has a valid address from UserLocation
    final hasAddress = userProvider.isLoggedIn &&
        userProvider.currentUserLocation != null &&
        userProvider.currentUserLocation!.address.isNotEmpty;

    return InkWell(
      onTap: () {
        if (!userProvider.isLoggedIn) {
          Navigator.pushNamed(context, '/login');
        } else {
          _showAddressOptions(context, hasAddress, userProvider);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMedium,
          vertical: AppTheme.spacingSmall + 2,
        ),
        color: AppTheme.primaryColor,
        child: Row(
          children: [
            Icon(
              hasAddress ? Icons.location_on : Icons.location_off,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: AppTheme.spacingSmall - 2),
            Expanded(
              child: Text(
                hasAddress
                    ? userProvider.displayAddress
                    : 'Add your address',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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

  void _showAddressOptions(
    BuildContext context,
    bool hasAddress,
    UserProvider userProvider,
  ) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadiusLarge),
        ),
      ),
      builder: (bottomSheetContext) => Container(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bottom sheet handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppTheme.spacingLarge),
              decoration: BoxDecoration(
                color: AppTheme.getDividerColor(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Text(
              'Select Address Option',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spacingLarge),

            if (hasAddress)
              ListTile(
                leading: Icon(
                  Icons.edit_location,
                  color: theme.primaryColor,
                ),
                title: const Text('Edit current address'),
                subtitle: const Text('Modify your saved address'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  Navigator.pushNamed(context, '/edit-profile');
                },
              ),

            ListTile(
              leading: Icon(
                Icons.my_location,
                color: theme.primaryColor,
              ),
              title: const Text('Use current location'),
              subtitle: const Text('Get address from GPS'),
              onTap: () async {
                Navigator.pop(bottomSheetContext);
                await _handleUseCurrentLocation(context, userProvider);
              },
            ),

            ListTile(
              leading: Icon(
                Icons.add_location,
                color: theme.primaryColor,
              ),
              title: Text(hasAddress ? 'Add new address' : 'Add address manually'),
              subtitle: const Text('Enter address details'),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                Navigator.pushNamed(context, '/edit-profile');
              },
            ),

            const SizedBox(height: AppTheme.spacingSmall),
          ],
        ),
      ),
    );
  }

  Future<void> _handleUseCurrentLocation(
    BuildContext context,
    UserProvider userProvider,
  ) async {
    try {
      // Request location and get address
      final locationData = await LocationService.handleLocationRequest(context);

      if (locationData != null && context.mounted) {
        // Extract location details
        final latitude = locationData['latitude'] as double;
        final longitude = locationData['longitude'] as double;
        final address = locationData['address'] as String;

        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // Update user's location via API
        final success = await userProvider.updateUserLocation(
          latitude: latitude,
          longitude: longitude,
          address: address,
        );

        // Close loading dialog
        if (context.mounted) {
          Navigator.pop(context);
        }

        if (context.mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: AppTheme.spacingSmall),
                    Expanded(
                      child: Text(
                        'Address updated: ${address.length > 40 ? "${address.substring(0, 40)}..." : address}',
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppTheme.successColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  userProvider.error ?? 'Failed to update location',
                ),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}