import 'package:url_launcher/url_launcher.dart';

class MapLauncher {
  static Future<void> openNavigationToLocation({
    required double latitude,
    required double longitude,
  }) async {
    final Uri googleMapsApp = Uri.parse(
      'google.navigation:q=$latitude,$longitude&mode=d',
    );

    final Uri googleMapsBrowser = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving',
    );

    if (await canLaunchUrl(googleMapsApp)) {
      await launchUrl(googleMapsApp);
      return;
    }

    await launchUrl(
      googleMapsBrowser,
      mode: LaunchMode.externalApplication,
    );
  }
}
