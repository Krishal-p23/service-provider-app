// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../models/user_role.dart';
// import '../../providers/user_provider.dart';
// import '../main_screen.dart';

// class LoginTab extends StatefulWidget {
//   final UserRole role;
//   final Color roleColor;
//   final VoidCallback onSwitchToRegister;

//   const LoginTab({
//     super.key,
//     required this.role,
//     required this.roleColor,
//     required this.onSwitchToRegister,
//   });

//   @override
//   State<LoginTab> createState() => _LoginTabState();
// }

// class _LoginTabState extends State<LoginTab> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailOrPhoneController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _obscurePassword = true;
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _emailOrPhoneController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleLogin() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       final userProvider = context.read<UserProvider>();
//       final success = await userProvider.login(
//         _emailOrPhoneController.text.trim(),
//         _passwordController.text,
//         role: widget.role,
//       );

//       setState(() {
//         _isLoading = false;
//       });

//       if (success && mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const MainScreen()),
//         );
//       } else if (mounted) {
//         // Check if user exists
//         final userExists = userProvider.userExists(
//           _emailOrPhoneController.text.trim(),
//         );

//         if (!userExists) {
//           showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: const Text('No Account Found'),
//               content: const Text(
//                 'No account exists with these credentials. Would you like to register?',
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Cancel'),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                     widget.onSwitchToRegister();
//                   },
//                   child: const Text('Register'),
//                 ),
//               ],
//             ),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Invalid credentials. Please try again.'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     }
//   }

//   Future<void> _handleGoogleSignIn() async {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Google Sign-In - Coming soon!'),
//       ),
//     );
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

//             // Welcome Back Header
//             Text(
//               'Welcome Back!',
//               style: theme.textTheme.headlineMedium?.copyWith(
//                 color: widget.roleColor,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               widget.role == UserRole.customer
//                   ? 'Find trusted home services near you'
//                   : 'Start earning by providing services',
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 32),

//             // Email/Phone Field
//             TextFormField(
//               controller: _emailOrPhoneController,
//               decoration: InputDecoration(
//                 labelText: widget.role == UserRole.customer
//                     ? 'Email or Phone'
//                     : 'Phone Number',
//                 hintText: widget.role == UserRole.customer
//                     ? 'Enter your email or phone'
//                     : 'Enter your phone number',
//                 prefixIcon: Icon(
//                   widget.role == UserRole.customer
//                       ? Icons.person
//                       : Icons.phone,
//                   color: widget.roleColor,
//                 ),
//               ),
//               keyboardType: widget.role == UserRole.customer
//                   ? TextInputType.emailAddress
//                   : TextInputType.phone,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return widget.role == UserRole.customer
//                       ? 'Please enter your email or phone'
//                       : 'Please enter your phone number';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 16),

//             // Password Field
//             TextFormField(
//               controller: _passwordController,
//               decoration: InputDecoration(
//                 labelText: 'Password',
//                 hintText: 'Enter your password',
//                 prefixIcon: Icon(Icons.lock, color: widget.roleColor),
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     _obscurePassword
//                         ? Icons.visibility_off
//                         : Icons.visibility,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       _obscurePassword = !_obscurePassword;
//                     });
//                   },
//                 ),
//               ),
//               obscureText: _obscurePassword,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter your password';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 24),

//             // Login Button
//             ElevatedButton(
//               onPressed: _isLoading ? null : _handleLogin,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: widget.roleColor,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
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
//                   : const Text(
//                       'Login',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//             ),

//             // Google Sign-In (Only for customers)
//             if (widget.role == UserRole.customer) ...[
//               const SizedBox(height: 16),
//               const Row(
//                 children: [
//                   Expanded(child: Divider()),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16),
//                     child: Text('OR'),
//                   ),
//                   Expanded(child: Divider()),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               OutlinedButton.icon(
//                 onPressed: _handleGoogleSignIn,
//                 icon: Image.network(
//                   'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
//                   height: 20,
//                   errorBuilder: (context, error, stackTrace) =>
//                       const Icon(Icons.g_mobiledata),
//                 ),
//                 label: const Text('Continue with Google'),
//                 style: OutlinedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//             ],

//             const SizedBox(height: 24),

//             // Register Link
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   "Don't have an account? ",
//                   style: theme.textTheme.bodyMedium,
//                 ),
//                 TextButton(
//                   onPressed: widget.onSwitchToRegister,
//                   child: Text(
//                     'Register',
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
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_role.dart';
import '../../providers/user_provider.dart';
import '../main_screen.dart';

class LoginTab extends StatefulWidget {
  final Color roleColor;
  final VoidCallback onSwitchToRegister;

  const LoginTab({
    super.key,
    required this.roleColor,
    required this.onSwitchToRegister,
  });

  @override
  State<LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<LoginTab> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final userProvider = context.read<UserProvider>();
      final success = await userProvider.login(
        _emailOrPhoneController.text.trim(),
        _passwordController.text,
        role: UserRole.customer,
      );

      setState(() {
        _isLoading = false;
      });

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else if (mounted) {
        // Check if user exists
        final userExists = userProvider.userExists(
          _emailOrPhoneController.text.trim(),
        );

        if (!userExists) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('No Account Found'),
              content: const Text(
                'No account exists with these credentials. Would you like to register?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onSwitchToRegister();
                  },
                  child: const Text('Register'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid credentials. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Sign-In - Coming soon!'),
      ),
    );
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

            // Welcome Back Header
            Text(
              'Welcome Back!',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: widget.roleColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Find trusted home services near you',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Email/Phone Field
            TextFormField(
              controller: _emailOrPhoneController,
              decoration: InputDecoration(
                labelText: 'Email or Phone',
                hintText: 'Enter your email or phone',
                prefixIcon: Icon(Icons.person, color: widget.roleColor),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email or phone';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password Field
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: Icon(Icons.lock, color: widget.roleColor),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Login Button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.roleColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                      'Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),

            // Google Sign-In
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('OR'),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _handleGoogleSignIn,
              icon: Image.network(
                'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                height: 20,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.g_mobiledata),
              ),
              label: const Text('Continue with Google'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Register Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: theme.textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: widget.onSwitchToRegister,
                  child: Text(
                    'Register',
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