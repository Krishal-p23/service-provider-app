import 'package:flutter/material.dart';

class AllServicesScreen extends StatelessWidget {
  const AllServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final services = [
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Services'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${service['name']} - UI only')),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.teal.withValues(alpha: 0.2)
                          : Colors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      service['icon'] as IconData,
                      color: isDark
                          ? Colors.teal.shade300
                          : Colors.teal.shade700,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      service['name'] as String,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}