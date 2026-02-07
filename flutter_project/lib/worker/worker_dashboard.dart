import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/worker_provider.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch worker profile on dashboard load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkerProvider>().fetchProfile();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const WorkerHomeTab(),
      const WorkerBookingsTab(),
      const WorkerProfileTab(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.getTextColor(context, secondary: true),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Home Tab
class WorkerHomeTab extends StatelessWidget {
  const WorkerHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workerProvider = context.watch<WorkerProvider>();
    final user = workerProvider.currentUser;
    final worker = workerProvider.workerProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Dashboard'),
        actions: [
          // Theme Toggle
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
          // Availability Toggle
          if (worker != null)
            Padding(
              padding: const EdgeInsets.only(right: AppTheme.spacingSmall),
              child: Row(
                children: [
                  Text(
                    worker.isAvailable ? 'Available' : 'Offline',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(width: AppTheme.spacingXSmall),
                  Switch(
                    value: worker.isAvailable,
                    onChanged: (value) {
                      // TODO: Update availability via API
                      // PATCH /api/workers/availability/
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value ? 'You are now available for jobs' : 'You are now offline',
                          ),
                          backgroundColor: value ? AppTheme.successColor : AppTheme.warningColor,
                        ),
                      );
                    },
                    activeColor: AppTheme.successColor,
                  ),
                ],
              ),
            ),
        ],
      ),
      body: workerProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingLarge),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingLarge),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome, ${user?.name ?? "Worker"}!',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spacingXSmall),
                                if (worker != null)
                                  Row(
                                    children: [
                                      if (worker.isVerified) ...[
                                        const Icon(
                                          Icons.verified,
                                          size: 16,
                                          color: AppTheme.successColor,
                                        ),
                                        const SizedBox(width: AppTheme.spacingXSmall),
                                        Text(
                                          'Verified',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: AppTheme.successColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ] else ...[
                                        const Icon(
                                          Icons.pending,
                                          size: 16,
                                          color: AppTheme.warningColor,
                                        ),
                                        const SizedBox(width: AppTheme.spacingXSmall),
                                        Text(
                                          'Pending Verification',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: AppTheme.warningColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                if (user?.phone != null) ...[
                                  const SizedBox(height: AppTheme.spacingXSmall - 2),
                                  Text(
                                    '+91 ${user!.phone}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppTheme.getTextColor(context, secondary: true),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),

                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Completed',
                          value: '0', // TODO: Fetch from backend
                          icon: Icons.check_circle,
                          color: AppTheme.successColor,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMedium),
                      Expanded(
                        child: _StatCard(
                          title: 'Pending',
                          value: '0', // TODO: Fetch from backend
                          icon: Icons.pending_actions,
                          color: AppTheme.warningColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Rating',
                          value: '0.0', // TODO: Fetch from backend
                          icon: Icons.star,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMedium),
                      Expanded(
                        child: _StatCard(
                          title: 'Earnings',
                          value: '₹0', // TODO: Fetch from backend
                          icon: Icons.account_balance_wallet,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingXLarge),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  
                  _ActionButton(
                    icon: Icons.work,
                    title: 'View Active Jobs',
                    subtitle: 'See your current bookings',
                    color: AppTheme.primaryColor,
                    onTap: () {
                      // Navigate to jobs tab
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  
                  _ActionButton(
                    icon: Icons.history,
                    title: 'Job History',
                    subtitle: 'View completed jobs',
                    color: AppTheme.successColor,
                    onTap: () {
                      // Navigate to history
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  
                  _ActionButton(
                    icon: Icons.account_balance_wallet,
                    title: 'Earnings',
                    subtitle: 'View your earnings',
                    color: Colors.green,
                    onTap: () {
                      // Navigate to earnings
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  
                  _ActionButton(
                    icon: Icons.settings,
                    title: 'Settings',
                    subtitle: 'Manage your account',
                    color: Colors.grey,
                    onTap: () {
                      // Navigate to settings
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

// Bookings Tab
class WorkerBookingsTab extends StatelessWidget {
  const WorkerBookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Jobs'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.work_outline,
                size: 80,
                color: AppTheme.getTextColor(context, secondary: true),
              ),
              const SizedBox(height: AppTheme.spacingXLarge),
              Text(
                'No Active Jobs',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              Text(
                'Your job bookings will appear here',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.getTextColor(context, secondary: true),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingXXLarge),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Navigate to available jobs or help
                },
                icon: const Icon(Icons.info_outline),
                label: const Text('How to get jobs?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Profile Tab
class WorkerProfileTab extends StatelessWidget {
  const WorkerProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workerProvider = context.watch<WorkerProvider>();
    final user = workerProvider.currentUser;
    final worker = workerProvider.workerProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLarge),
                Text(
                  user?.name ?? 'Worker',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXSmall),
                if (user?.phone != null)
                  Text(
                    '+91 ${user!.phone}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.getTextColor(context, secondary: true),
                    ),
                  ),
                const SizedBox(height: AppTheme.spacingSmall),
                if (worker != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMedium,
                      vertical: AppTheme.spacingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: worker.isVerified 
                          ? AppTheme.successColor.withOpacity(0.1)
                          : AppTheme.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                      border: Border.all(
                        color: worker.isVerified 
                            ? AppTheme.successColor.withOpacity(0.3)
                            : AppTheme.warningColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          worker.isVerified ? Icons.verified : Icons.pending,
                          size: 16,
                          color: worker.isVerified 
                              ? AppTheme.successColor 
                              : AppTheme.warningColor,
                        ),
                        const SizedBox(width: AppTheme.spacingXSmall),
                        Text(
                          worker.isVerified ? 'Verified Professional' : 'Pending Verification',
                          style: TextStyle(
                            color: worker.isVerified 
                                ? AppTheme.successColor 
                                : AppTheme.warningColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingXXLarge),

          // Profile Options
          _ProfileOption(
            icon: Icons.edit,
            title: 'Edit Profile',
            subtitle: 'Update your information',
            onTap: () {
              // TODO: Navigate to edit profile
            },
          ),
          _ProfileOption(
            icon: Icons.build,
            title: 'Services',
            subtitle: 'Manage your services',
            onTap: () {
              // TODO: Navigate to services
            },
          ),
          _ProfileOption(
            icon: Icons.schedule,
            title: 'Availability',
            subtitle: 'Set your working hours',
            onTap: () {
              // TODO: Navigate to availability settings
            },
          ),
          _ProfileOption(
            icon: Icons.payment,
            title: 'Payment Details',
            subtitle: 'Bank account & UPI',
            onTap: () {
              // TODO: Navigate to payment settings
            },
          ),
          _ProfileOption(
            icon: Icons.star,
            title: 'Reviews & Ratings',
            subtitle: 'See what customers say',
            onTap: () {
              // TODO: Navigate to reviews
            },
          ),
          _ProfileOption(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help or report issue',
            onTap: () {
              // TODO: Navigate to help
            },
          ),
          _ProfileOption(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version & info',
            onTap: () {
              // TODO: Show about dialog
            },
          ),
          const SizedBox(height: AppTheme.spacingXLarge),

          // Logout Button
          OutlinedButton.icon(
            onPressed: () async {
              // Show confirmation dialog
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await workerProvider.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                }
              }
            },
            icon: const Icon(Icons.logout, color: AppTheme.errorColor),
            label: const Text(
              'Logout',
              style: TextStyle(color: AppTheme.errorColor),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingLarge),
              side: const BorderSide(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXSmall),
            Text(
              title,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Action Button Widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppTheme.spacingSmall),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

// Profile Option Widget
class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.getTextColor(context, secondary: true),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}