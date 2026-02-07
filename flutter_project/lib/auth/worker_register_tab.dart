import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'worker_otp_verification_screen.dart';

class WorkerRegisterTab extends StatefulWidget {
  final Color roleColor;
  final VoidCallback onSwitchToLogin;

  const WorkerRegisterTab({
    super.key,
    required this.roleColor,
    required this.onSwitchToLogin,
  });

  @override
  State<WorkerRegisterTab> createState() => _WorkerRegisterTabState();
}

class _WorkerRegisterTabState extends State<WorkerRegisterTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Service type dropdown
  String? _selectedServiceType;
  final List<String> _serviceTypes = [
    'plumber',
    'electrician',
    'carpenter',
    'cleaner',
    'cook',
    'gardener',
    'pest_control',
    'ac_technician',
    'baby_sitter',
  ];

  bool _obscurePassword = true;
  bool _acceptTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Generate username from phone number
  String _getUsernameFromPhone() {
    return 'worker_${_phoneController.text.trim()}';
  }

  Future<void> _handleRegister() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please accept the Terms of Service'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_selectedServiceType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a service type'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Navigate to Worker OTP verification
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkerOTPVerificationScreen(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
            serviceType: _selectedServiceType!,
          ),
        ),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatServiceType(String type) {
    return type.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
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

            // Worker Registration Header
            Icon(Icons.engineering_rounded, size: 64, color: widget.roleColor),
            const SizedBox(height: AppTheme.spacingLarge),
            Text(
              'Join as Professional',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: widget.roleColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              'Start earning by providing quality services',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.getTextColor(context, secondary: true),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXXLarge),

            // Name Field
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.darkSurfaceVariant
                    : widget.roleColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: Icon(Icons.person, color: widget.roleColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(AppTheme.spacingLarge),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppTheme.spacingLarge),

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
                  hintText: '10-digit mobile number',
                  prefixIcon: Icon(Icons.phone, color: widget.roleColor),
                  prefixText: '+91 ',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(AppTheme.spacingLarge),
                ),
                keyboardType: TextInputType.phone,
                maxLength: 10,
                buildCounter: (context,
                        {required currentLength, required isFocused, maxLength}) =>
                    null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (value.length != 10) {
                    return 'Please enter a valid 10-digit number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppTheme.spacingLarge),

            // Service Type Dropdown
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.darkSurfaceVariant
                    : widget.roleColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLarge,
                vertical: AppTheme.spacingXSmall,
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedServiceType,
                decoration: InputDecoration(
                  labelText: 'Service Type',
                  prefixIcon: Icon(Icons.build, color: widget.roleColor),
                  border: InputBorder.none,
                ),
                dropdownColor: isDark ? AppTheme.darkSurface : Colors.white,
                items: _serviceTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_formatServiceType(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedServiceType = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a service type';
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
                  hintText: 'Create a strong password',
                  prefixIcon: Icon(Icons.lock, color: widget.roleColor),
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
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppTheme.spacingLarge),

            // Terms Checkbox
            Row(
              children: [
                Checkbox(
                  value: _acceptTerms,
                  onChanged: (value) {
                    setState(() {
                      _acceptTerms = value ?? false;
                    });
                  },
                  activeColor: widget.roleColor,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _acceptTerms = !_acceptTerms;
                      });
                    },
                    child: Text.rich(
                      TextSpan(
                        text: 'I agree to the ',
                        style: theme.textTheme.bodySmall,
                        children: [
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              color: widget.roleColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingXLarge),

            // Register Button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
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
                  : const Text(
                      'Register as Worker',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(height: AppTheme.spacingXLarge),

            // Login Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already registered? ',
                  style: theme.textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: widget.onSwitchToLogin,
                  child: Text(
                    'Sign In',
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