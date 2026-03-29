import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/worker_provider.dart';
import '../../theme/app_theme.dart';
import '../../customer/screens/onboarding_screen.dart';
import 'edit_profile_screen.dart';
import 'verification_screen.dart';
import 'bank_transfers_screen.dart';
import 'past_services_screen.dart';
import 'my_reviews_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';
import 'help_support_screen.dart';
import 'settings_screen.dart';

class WorkerAccountScreen extends StatelessWidget {
  const WorkerAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workerProvider = context.watch<WorkerProvider>();
    final user = workerProvider.currentUser;
    final worker = workerProvider.currentWorker;
    final surfaceColor = AppTheme.getSurfaceColor(context);
    final textColor = AppTheme.getTextColor(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Account',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: surfaceColor,
        elevation: 0,
        foregroundColor: textColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Profile Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.workerPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: AppTheme.workerPrimaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Worker',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getTextColor(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.phone ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.getTextColor(
                                context,
                                secondary: true,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.successColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified,
                                  size: 14,
                                  color: AppTheme.successColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Verified Worker',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.successColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Stats Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Jobs Completed',
                        '${workerProvider.todayJobsCount}',
                        Icons.check_circle_outline,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Rating',
                        workerProvider.averageRating > 0
                            ? '${workerProvider.averageRating.toStringAsFixed(1)} ★'
                            : 'N/A',
                        Icons.star_outline,
                        Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Personal Information Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12,
                ),
                child: Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
              ),

              _buildInfoTile(
                Icons.person_outline,
                'Full Name',
                user?.name ?? 'Not set',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
              ),

              _buildInfoTile(
                Icons.phone_outlined,
                'Mobile Number',
                user?.phone ?? 'Not set',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
              ),

              _buildInfoTile(
                Icons.email_outlined,
                'Email',
                user?.email ?? 'Not set',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
              ),

              _buildInfoTile(
                Icons.location_on_outlined,
                'Address',
                'Not set', // TODO: Add address to user model
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Work Details Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12,
                ),
                child: Text(
                  'Work Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
              ),

              _buildActionTile(
                Icons.verified_user_outlined,
                'Verification Status',
                'View your verification documents',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VerificationScreen(),
                    ),
                  );
                },
              ),

              _buildActionTile(
                Icons.account_balance_outlined,
                'Bank Details',
                'Manage your payment methods',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BankTransfersScreen(),
                    ),
                  );
                },
              ),

              _buildActionTile(
                Icons.work_history_outlined,
                'Work History',
                'View your completed jobs',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PastServicesScreen(),
                    ),
                  );
                },
              ),

              _buildActionTile(
                Icons.star_border_outlined,
                'Reviews & Ratings',
                'See what customers say about you',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyReviewsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Other Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12,
                ),
                child: Text(
                  'Other',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
              ),

              _buildActionTile(
                Icons.privacy_tip_outlined,
                'Privacy Policy',
                'Read our privacy policy',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),

              _buildActionTile(
                Icons.article_outlined,
                'Terms & Conditions',
                'Read terms and conditions',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TermsConditionsScreen(),
                    ),
                  );
                },
              ),

              _buildActionTile(
                Icons.help_outline,
                'Help & Support',
                'Get help with your account',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpSupportScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text(
                            'Are you sure you want to logout?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );

                      if (shouldLogout == true && context.mounted) {
                        await workerProvider.logout();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OnboardingScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final backgroundColor = isDarkMode
            ? color.withOpacity(0.15)
            : color.withOpacity(0.1);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.getTextColor(context, secondary: true),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final leadingBgColor = isDarkMode
            ? Colors.grey.shade800
            : Colors.grey.shade100;
        final leadingIconColor = isDarkMode
            ? Colors.grey.shade400
            : Colors.grey.shade700;
        final labelColor = AppTheme.getTextColor(context, secondary: true);
        final valueColor = AppTheme.getTextColor(context);
        final trailingColor = isDarkMode
            ? Colors.grey.shade400
            : Colors.grey.shade600;

        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: leadingBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: leadingIconColor),
          ),
          title: Text(label, style: TextStyle(fontSize: 13, color: labelColor)),
          subtitle: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
          trailing: Icon(Icons.edit_outlined, size: 18, color: trailingColor),
          onTap: onTap,
        );
      },
    );
  }

  Widget _buildActionTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final leadingBgColor = isDarkMode
            ? AppTheme.workerPrimaryColor.withOpacity(0.2)
            : AppTheme.workerPrimaryColor.withOpacity(0.1);
        final titleColor = AppTheme.getTextColor(context);
        final subtitleColor = AppTheme.getTextColor(context, secondary: true);

        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: leadingBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppTheme.workerPrimaryColor),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: titleColor,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: subtitleColor),
          ),
          trailing: const Icon(Icons.chevron_right, size: 20),
          onTap: onTap,
        );
      },
    );
  }
}
