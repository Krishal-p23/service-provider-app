import 'package:flutter/material.dart';
import '../services/location_service.dart';

/// Mixin to add location permission request functionality to widgets
/// This can be used for category navigation, search, booking, etc.
mixin LocationPermissionMixin {
  /// Request location permission before performing an action
  /// If user grants permission, execute the action
  /// Returns true if action was executed, false otherwise
  Future<bool> requestLocationBeforeAction(
    BuildContext context, {
    required Function() onPermissionGranted,
    required String actionDescription,
    bool showOptionalDialog = true,
  }) async {
    if (!showOptionalDialog) {
      // Directly request permission without asking user first
      final locationData = await LocationService.handleLocationRequest(context);
      if (locationData != null) {
        onPermissionGranted();
        return true;
      }
      return false;
    }

    // Show dialog asking if user wants to enable location
    final bool? userWantsLocation = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.location_on, color: theme.primaryColor),
              const SizedBox(width: 8),
              const Text('Enable Location?'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                actionDescription,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              const Text(
                'Enabling location will help us:',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 8),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, size: 18, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Find service providers near you',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, size: 18, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Show accurate distance & time',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, size: 18, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Auto-fill your service address',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Skip'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Enable'),
            ),
          ],
        );
      },
    );

    if (userWantsLocation == true && context.mounted) {
      final locationData = await LocationService.handleLocationRequest(context);
      if (locationData != null) {
        onPermissionGranted();
        return true;
      }
    } else {
      // User skipped location, still execute the action
      onPermissionGranted();
      return true;
    }
    
    return false;
  }
}

/// Standalone helper class for location-aware navigation
class LocationAwareNavigation {
  /// Navigate to a screen with optional location request
  /// This is useful for category/service navigation from home screen
  static Future<void> navigateWithLocationCheck(
    BuildContext context, {
    required Widget destination,
    required String actionDescription,
    bool requestLocation = true,
    bool showOptionalDialog = true,
  }) async {
    if (!requestLocation) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination),
      );
      return;
    }

    if (showOptionalDialog) {
      // Show dialog asking if user wants to enable location
      final bool? userWantsLocation = await _showLocationDialog(
        context,
        actionDescription,
      );

      if (userWantsLocation == true && context.mounted) {
        // Request location permission
        await LocationService.handleLocationRequest(context);
      }
      
      // Navigate regardless of location permission result
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      }
    } else {
      // Directly request without dialog
      await LocationService.handleLocationRequest(context);
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      }
    }
  }

  static Future<bool?> _showLocationDialog(
    BuildContext context,
    String actionDescription,
  ) async {
    final theme = Theme.of(context);
    return await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.location_on, color: theme.primaryColor),
              const SizedBox(width: 8),
              const Text('Enable Location?'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                actionDescription,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              const Text(
                'Enabling location will help us:',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 8),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, size: 18, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Find service providers near you',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, size: 18, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Show accurate distance & time',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, size: 18, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Auto-fill your service address',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Skip'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Enable'),
            ),
          ],
        );
      },
    );
  }
}