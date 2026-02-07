import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/worker_provider.dart';
import '../theme/app_theme.dart';

class WorkerLoginTab extends StatefulWidget {
  final Color roleColor;
  final VoidCallback onSwitchToRegister;

  const WorkerLoginTab({
    super.key,
    required this.roleColor,
    required this.onSwitchToRegister,
  });

  @override
  State<WorkerLoginTab> createState() => _WorkerLoginTabState();
}

class _WorkerLoginTabState extends State<WorkerLoginTab> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Generate username from phone number
  String _getUsernameFromPhone() {
    return 'worker_${_phoneController.text.trim()}';
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final workerProvider = context.read<WorkerProvider>();
      final username = _getUsernameFromPhone();
      
      final success = await workerProvider.login(
        username: username,
        password: _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (success && mounted) {
        // Navigate to worker dashboard - update route as needed
        Navigator.pushReplacementNamed(context, '/worker-dashboard');
      } else if (mounted) {
        final error = workerProvider.error ?? 'Login failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingXLarge),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppTheme.spacingSmall),

            // Worker Welcome Header
            Icon(
              Icons.work_outline_rounded,
              size: 64,
              color: widget.roleColor,
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            Text(
              'Worker Login',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: widget.roleColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              'Access your professional dashboard',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.getTextColor(context, secondary: true),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXXLarge + AppTheme.spacingSmall),

            // Phone Number Field
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.darkSurfaceVariant
                    : widget.roleColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
              child: TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your registered phone',
                  prefixIcon: Icon(Icons.phone_android, color: widget.roleColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(AppTheme.spacingLarge),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppTheme.spacingLarge),

            // Password Field
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.darkSurfaceVariant
                    : widget.roleColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
              child: TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icon(Icons.lock_outline, color: widget.roleColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(AppTheme.spacingLarge),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppTheme.spacingXXLarge),

            // Login Button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.roleColor,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
                elevation: AppTheme.cardElevationHigh,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: AppTheme.spacingSmall),
                        Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                      ],
                    ),
            ),

            const SizedBox(height: AppTheme.spacingXLarge),

            // Register Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "New worker? ",
                  style: theme.textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: widget.onSwitchToRegister,
                  child: Text(
                    'Join as Professional',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: widget.roleColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}