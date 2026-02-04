import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/user_role.dart';
import '../../models/user.dart';
import 'package:flutter_project/screens/auth/otp_verification_screen.dart';

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
  final _skillsController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  String? _photoPath;
  String? _idProofPath;
  bool _obscurePassword = true;
  bool _acceptTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument(bool isPhoto) async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (file != null) {
        setState(() {
          if (isPhoto) {
            _photoPath = file.path;
          } else {
            _idProofPath = file.path;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms of Service'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_photoPath == null || _idProofPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload both photo and ID proof'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Navigate to OTP verification
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerificationScreen(
            name: _nameController.text.trim(),
            email: '', // Workers don't need email
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
            role: UserRole.worker,
          ),
        ),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),

            // Worker Registration Header
            Icon(Icons.engineering_rounded, size: 64, color: widget.roleColor),
            const SizedBox(height: 16),
            Text(
              'Join as Professional',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: widget.roleColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Register to start offering your professional services',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Professional Details Section
            Row(
              children: [
                Icon(Icons.badge_outlined, size: 20, color: widget.roleColor),
                const SizedBox(width: 8),
                Text(
                  'Professional Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: widget.roleColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Name Field
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E1E1E)
                    : widget.roleColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: widget.roleColor,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),

            // Skills Field
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E1E1E)
                    : widget.roleColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextFormField(
                controller: _skillsController,
                decoration: InputDecoration(
                  labelText: 'Primary Skills',
                  hintText: 'e.g., Plumbing, Electrical, Carpentry',
                  prefixIcon: Icon(
                    Icons.build_outlined,
                    color: widget.roleColor,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your skills';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 24),

            // Documents Section
            Row(
              children: [
                Icon(
                  Icons.upload_file_outlined,
                  size: 20,
                  color: widget.roleColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Upload Documents',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: widget.roleColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Photo Upload Box
            _buildUploadBox(
              context: context,
              title: 'Profile Photo',
              subtitle: 'Upload a clear photo of yourself',
              filePath: _photoPath,
              onTap: () => _pickDocument(true),
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // ID Proof Upload Box
            _buildUploadBox(
              context: context,
              title: 'Government ID Proof',
              subtitle: 'Aadhaar, PAN, Driving License, etc.',
              filePath: _idProofPath,
              onTap: () => _pickDocument(false),
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // Contact Information Section
            Row(
              children: [
                Icon(
                  Icons.contact_phone_outlined,
                  size: 20,
                  color: widget.roleColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Contact Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: widget.roleColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Phone Field
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E1E1E)
                    : widget.roleColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '10-digit mobile number',
                  prefixIcon: Icon(
                    Icons.phone_android,
                    color: widget.roleColor,
                  ),
                  prefixText: '+91 ',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                keyboardType: TextInputType.phone,
                maxLength: 10,
                buildCounter:
                    (
                      context, {
                      required currentLength,
                      required isFocused,
                      maxLength,
                    }) => null,
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
            const SizedBox(height: 16),

            // Password Field
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E1E1E)
                    : widget.roleColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Create a strong password',
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
                  contentPadding: const EdgeInsets.all(16),
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
            const SizedBox(height: 16),

            // Verification Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your profile will be verified within 24-48 hours for quality assurance',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Terms Checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
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
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Worker Guidelines',
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
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Register Button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.roleColor,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
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
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Submit Application',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color: Colors.white,
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 24),

            // Login Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already registered? ', style: theme.textTheme.bodyMedium),
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

  Widget _buildUploadBox({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String? filePath,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final hasFile = filePath != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasFile ? widget.roleColor : Colors.grey.shade300,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: hasFile
            ? Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(filePath),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: widget.roleColor,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to change',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.check_circle, color: widget.roleColor, size: 28),
                ],
              )
            : Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 48,
                    color: widget.roleColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: widget.roleColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Tap to Upload',
                      style: TextStyle(
                        color: widget.roleColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import '../../models/user_role.dart';
// import '../../models/user.dart';
// import '../../providers/user_provider.dart';
// import 'otp_verification_screen.dart';

// class WorkerRegisterTab extends StatefulWidget {
//   final Color roleColor;
//   final VoidCallback onSwitchToLogin;

//   const WorkerRegisterTab({
//     super.key,
//     required this.roleColor,
//     required this.onSwitchToLogin,
//   });

//   @override
//   State<WorkerRegisterTab> createState() => _WorkerRegisterTabState();
// }

// class _WorkerRegisterTabState extends State<WorkerRegisterTab> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _skillsController = TextEditingController();
//   final ImagePicker _imagePicker = ImagePicker();
  
//   String? _photoPath;
//   String? _idProofPath;
//   bool _obscurePassword = true;
//   bool _acceptTerms = false;
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
//     _passwordController.dispose();
//     _skillsController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickDocument(bool isPhoto) async {
//     try {
//       final XFile? file = await _imagePicker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1024,
//         maxHeight: 1024,
//         imageQuality: 85,
//       );

//       if (file != null) {
//         setState(() {
//           if (isPhoto) {
//             _photoPath = file.path;
//           } else {
//             _idProofPath = file.path;
//           }
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error picking file: $e')),
//         );
//       }
//     }
//   }

//   Future<void> _handleRegister() async {
//     if (!_acceptTerms) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please accept the Terms of Service'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     if (_photoPath == null || _idProofPath == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please upload both photo and ID proof'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       // Navigate to OTP verification
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => OTPVerificationScreen(
//             name: _nameController.text.trim(),
//             email: '', // Workers don't need email
//             phone: _phoneController.text.trim(),
//             password: _passwordController.text,
//             role: UserRole.worker,
//           ),
//         ),
//       );

//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const SizedBox(height: 10),

//             // Worker Registration Header
//             Icon(
//               Icons.engineering_rounded,
//               size: 64,
//               color: widget.roleColor,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Join as Professional',
//               style: theme.textTheme.headlineMedium?.copyWith(
//                 color: widget.roleColor,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Register to start offering your professional services',
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 32),

//             // Professional Details Section
//             Row(
//               children: [
//                 Icon(Icons.badge_outlined, size: 20, color: widget.roleColor),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Professional Details',
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: widget.roleColor,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             // Name Field
//             Container(
//               decoration: BoxDecoration(
//                 color: isDark
//                     ? const Color(0xFF1E1E1E)
//                     : widget.roleColor.withOpacity(0.05),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: TextFormField(
//                 controller: _nameController,
//                 decoration: InputDecoration(
//                   labelText: 'Full Name',
//                   hintText: 'Enter your full name',
//                   prefixIcon: Icon(Icons.person_outline, color: widget.roleColor),
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.all(16),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your name';
//                   }
//                   return null;
//                 },
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Skills Field
//             Container(
//               decoration: BoxDecoration(
//                 color: isDark
//                     ? const Color(0xFF1E1E1E)
//                     : widget.roleColor.withOpacity(0.05),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: TextFormField(
//                 controller: _skillsController,
//                 decoration: InputDecoration(
//                   labelText: 'Primary Skills',
//                   hintText: 'e.g., Plumbing, Electrical, Carpentry',
//                   prefixIcon: Icon(Icons.build_outlined, color: widget.roleColor),
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.all(16),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your skills';
//                   }
//                   return null;
//                 },
//               ),
//             ),
//             const SizedBox(height: 24),

//             // Documents Section
//             Row(
//               children: [
//                 Icon(Icons.upload_file_outlined, size: 20, color: widget.roleColor),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Upload Documents',
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: widget.roleColor,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             // Photo Upload Box
//             _buildUploadBox(
//               context: context,
//               title: 'Profile Photo',
//               subtitle: 'Upload a clear photo of yourself',
//               filePath: _photoPath,
//               onTap: () => _pickDocument(true),
//               isDark: isDark,
//             ),
//             const SizedBox(height: 16),

//             // ID Proof Upload Box
//             _buildUploadBox(
//               context: context,
//               title: 'Government ID Proof',
//               subtitle: 'Aadhaar, PAN, Driving License, etc.',
//               filePath: _idProofPath,
//               onTap: () => _pickDocument(false),
//               isDark: isDark,
//             ),
//             const SizedBox(height: 24),

//             // Contact Information Section
//             Row(
//               children: [
//                 Icon(Icons.contact_phone_outlined, size: 20, color: widget.roleColor),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Contact Information',
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: widget.roleColor,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             // Phone Field
//             Container(
//               decoration: BoxDecoration(
//                 color: isDark
//                     ? const Color(0xFF1E1E1E)
//                     : widget.roleColor.withOpacity(0.05),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: TextFormField(
//                 controller: _phoneController,
//                 decoration: InputDecoration(
//                   labelText: 'Phone Number',
//                   hintText: '10-digit mobile number',
//                   prefixIcon: Icon(Icons.phone_android, color: widget.roleColor),
//                   prefixText: '+91 ',
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.all(16),
//                 ),
//                 keyboardType: TextInputType.phone,
//                 maxLength: 10,
//                 buildCounter: (context,
//                         {required currentLength, required isFocused, maxLength}) =>
//                     null,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your phone number';
//                   }
//                   if (value.length != 10) {
//                     return 'Please enter a valid 10-digit number';
//                   }
//                   return null;
//                 },
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Password Field
//             Container(
//               decoration: BoxDecoration(
//                 color: isDark
//                     ? const Color(0xFF1E1E1E)
//                     : widget.roleColor.withOpacity(0.05),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: TextFormField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   hintText: 'Create a strong password',
//                   prefixIcon: Icon(Icons.lock_outline, color: widget.roleColor),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _obscurePassword
//                           ? Icons.visibility_off_outlined
//                           : Icons.visibility_outlined,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _obscurePassword = !_obscurePassword;
//                       });
//                     },
//                   ),
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.all(16),
//                 ),
//                 obscureText: _obscurePassword,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your password';
//                   }
//                   if (value.length < 6) {
//                     return 'Password must be at least 6 characters';
//                   }
//                   return null;
//                 },
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Verification Info Box
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.blue.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.blue.withOpacity(0.3)),
//               ),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Icon(Icons.verified_user_outlined, color: Colors.blue, size: 20),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       'Your profile will be verified within 24-48 hours for quality assurance',
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Terms Checkbox
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Checkbox(
//                   value: _acceptTerms,
//                   onChanged: (value) {
//                     setState(() {
//                       _acceptTerms = value ?? false;
//                     });
//                   },
//                   activeColor: widget.roleColor,
//                 ),
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         _acceptTerms = !_acceptTerms;
//                       });
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.only(top: 12),
//                       child: Text.rich(
//                         TextSpan(
//                           text: 'I agree to the ',
//                           style: theme.textTheme.bodySmall,
//                           children: [
//                             TextSpan(
//                               text: 'Terms of Service',
//                               style: TextStyle(
//                                 color: widget.roleColor,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const TextSpan(text: ' and '),
//                             TextSpan(
//                               text: 'Worker Guidelines',
//                               style: TextStyle(
//                                 color: widget.roleColor,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),

//             // Register Button
//             ElevatedButton(
//               onPressed: _isLoading ? null : _handleRegister,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: widget.roleColor,
//                 padding: const EdgeInsets.symmetric(vertical: 18),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 elevation: 4,
//               ),
//               child: _isLoading
//                   ? const SizedBox(
//                       height: 20,
//                       width: 20,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: Colors.white,
//                       ),
//                     )
//                   : Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: const [
//                         Text(
//                           'Submit Application',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         SizedBox(width: 8),
//                         Icon(Icons.arrow_forward, size: 20, color: Colors.white),
//                       ],
//                     ),
//             ),
//             const SizedBox(height: 24),

//             // Login Link
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   'Already registered? ',
//                   style: theme.textTheme.bodyMedium,
//                 ),
//                 TextButton(
//                   onPressed: widget.onSwitchToLogin,
//                   child: Text(
//                     'Sign In',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: widget.roleColor,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildUploadBox({
//     required BuildContext context,
//     required String title,
//     required String subtitle,
//     required String? filePath,
//     required VoidCallback onTap,
//     required bool isDark,
//   }) {
//     final hasFile = filePath != null;

//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: hasFile ? widget.roleColor : Colors.grey.shade300,
//             width: 2,
//             style: BorderStyle.solid,
//           ),
//         ),
//         child: hasFile
//             ? Row(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.file(
//                       File(filePath),
//                       width: 60,
//                       height: 60,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           title,
//                           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                                 fontWeight: FontWeight.w600,
//                                 color: widget.roleColor,
//                               ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           'Tap to change',
//                           style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                                 color: Colors.grey.shade600,
//                               ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Icon(Icons.check_circle, color: widget.roleColor, size: 28),
//                 ],
//               )
//             : Column(
//                 children: [
//                   Icon(
//                     Icons.cloud_upload_outlined,
//                     size: 48,
//                     color: widget.roleColor.withOpacity(0.5),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     title,
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                           fontWeight: FontWeight.w600,
//                         ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     subtitle,
//                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//                         ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 12),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: widget.roleColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       'Tap to Upload',
//                       style: TextStyle(
//                         color: widget.roleColor,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }



