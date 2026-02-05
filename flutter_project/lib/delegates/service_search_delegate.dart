import 'package:flutter/material.dart';

class ServiceSearchDelegate extends SearchDelegate {
  // Use the list of services from your AllServicesScreen
  final List<Map<String, dynamic>> services = [
    {'icon': Icons.ac_unit, 'name': 'AC & Cooler'},
    {'icon': Icons.plumbing, 'name': 'Plumbing'},
    {'icon': Icons.electrical_services, 'name': 'Electrician'},
    {'icon': Icons.cleaning_services, 'name': 'Cleaning'},
    {'icon': Icons.format_paint, 'name': 'Painting'},
    {'icon': Icons.handyman, 'name': 'Carpenter'},
    {'icon': Icons.pest_control, 'name': 'Pest Control'},
    {'icon': Icons.tv, 'name': 'Appliance Repair'},
    {'icon': Icons.construction, 'name': 'Masonry'},
    {'icon': Icons.water_drop, 'name': 'Water Purifier'},
    {'icon': Icons.content_cut, 'name': 'Home Salon'},
    {'icon': Icons.local_laundry_service, 'name': 'Washing Machine'},
    {'icon': Icons.kitchen, 'name': 'Refrigerator'},
    {'icon': Icons.microwave, 'name': 'Microwave'},
    {'icon': Icons.chair, 'name': 'Furniture'},
    {'icon': Icons.window, 'name': 'Window Cleaning'},
  ];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    final suggestions = services.where((service) {
      return service['name'].toString().toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (suggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No services available for "$query"',
              style: const TextStyle(color: Colors.grey, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final service = suggestions[index];
        return ListTile(
          leading: Icon(service['icon'] as IconData, color: Colors.teal),
          title: Text(service['name'] as String),
          onTap: () {
            // Close search and show result
            close(context, null);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Selected: ${service['name']}')),
            );
          },
        );
      },
    );
  }
}
