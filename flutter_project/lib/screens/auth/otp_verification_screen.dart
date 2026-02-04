import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../models/user_role.dart';
import '../../providers/user_provider.dart';
import '../../providers/worker_provider.dart';
import '../main_screen.dart';
import '../../worker/worker_dashboard.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String password;
  final UserRole role;

  const OTPVerificationScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _otpController = TextEditingController();
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    // Simulate OTP verification (in real app, verify with backend)
    await Future.delayed(const Duration(seconds: 1));

    // Dummy OTP for testing: 123456
    if (_otpController.text == '123456') {
      // Register the user
      final user = User(
        name: widget.name,
        email: widget.email.isEmpty ? '${widget.phone}@temp.com' : widget.email,
        mobile: widget.phone,
        password: widget.password,
        address: '', // Will be added later
        role: widget.role,
      );

      bool success = false;

      // Use appropriate provider based on role
      if (widget.role == UserRole.worker) {
        final workerProvider = context.read<WorkerProvider>();
        success = await workerProvider.register(user);
      } else {
        final userProvider = context.read<UserProvider>();
        success = await userProvider.register(user);
      }

      setState(() {
        _isVerifying = false;
      });

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate based on role
        final destination = widget.role == UserRole.worker
            ? const WorkerDashboard()
            : const MainScreen();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => destination),
          (route) => false,
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account already exists with this email/phone'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      setState(() {
        _isVerifying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid OTP. Please try again. (Use 123456 for testing)',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resendOTP() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('OTP sent successfully!')));
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roleColor = widget.role == UserRole.customer
        ? const Color(0xFF00897B)
        : const Color(0xFF1976D2);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: theme.textTheme.headlineSmall,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: roleColor, width: 2),
    );

    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      color: roleColor.withOpacity(0.1),
      border: Border.all(color: roleColor),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Your Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          // Added SingleChildScrollView for scrollability
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            // Ensures minimum height for proper layout
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight -
                  48, // Subtract appbar height and padding
            ),
            child: IntrinsicHeight(
              // Allows Spacer to work inside ScrollView
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Icon
                  Icon(Icons.verified_user, size: 80, color: roleColor),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Verify Your Account',
                    style: theme.textTheme.displaySmall?.copyWith(color: roleColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    'Enter the 6-digit code sent to\n+91 ${widget.phone}',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // OTP Input
                  Pinput(
                    controller: _otpController,
                    length: 6,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: submittedPinTheme,
                    autofocus: true,
                    onCompleted: (_) => _verifyOTP(),
                  ),
                  const SizedBox(height: 24),

                  // Timer and Resend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_secondsRemaining > 0) ...[
                        const Icon(Icons.timer, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          '00:${_secondsRemaining.toString().padLeft(2, '0')}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ] else ...[
                        TextButton(
                          onPressed: _resendOTP,
                          child: Text(
                            'Resend OTP',
                            style: TextStyle(
                              color: roleColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Verify Button
                  ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: roleColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Verify & Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const Spacer(), // Pushes testing info to bottom when space available

                  // Testing Info
                  Container(
                    margin: const EdgeInsets.only(top: 24, bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: const Text(
                      '🧪 Testing: Use OTP 123456',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}




// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:pinput/pinput.dart';
// import 'package:provider/provider.dart';
// import '../../models/user.dart';
// import '../../models/user_role.dart';
// import '../../providers/user_provider.dart';
// import '../main_screen.dart';

// class OTPVerificationScreen extends StatefulWidget {
//   final String name;
//   final String email;
//   final String phone;
//   final String password;
//   final UserRole role;

//   const OTPVerificationScreen({
//     super.key,
//     required this.name,
//     required this.email,
//     required this.phone,
//     required this.password,
//     required this.role,
//   });

//   @override
//   State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
// }

// class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
//   final _otpController = TextEditingController();
//   int _secondsRemaining = 60;
//   Timer? _timer;
//   bool _isVerifying = false;

//   @override
//   void initState() {
//     super.initState();
//     _startTimer();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _otpController.dispose();
//     super.dispose();
//   }

//   void _startTimer() {
//     _secondsRemaining = 60;
//     _timer?.cancel();
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         if (_secondsRemaining > 0) {
//           _secondsRemaining--;
//         } else {
//           timer.cancel();
//         }
//       });
//     });
//   }

//   Future<void> _verifyOTP() async {
//     if (_otpController.text.length != 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter a valid 6-digit OTP'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     setState(() {
//       _isVerifying = true;
//     });

//     // Simulate OTP verification (in real app, verify with backend)
//     await Future.delayed(const Duration(seconds: 1));

//     // Dummy OTP for testing: 123456
//     if (_otpController.text == '123456') {
//       // Register the user
//       final user = User(
//         name: widget.name,
//         email: widget.email.isEmpty ? '${widget.phone}@temp.com' : widget.email,
//         mobile: widget.phone,
//         password: widget.password,
//         address: '', // Will be added later
//         role: widget.role,
//       );

//       final userProvider = context.read<UserProvider>();
//       final success = await userProvider.register(user);

//       setState(() {
//         _isVerifying = false;
//       });

//       if (success && mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Account created successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );

//         // Navigate to main screen
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (context) => const MainScreen()),
//           (route) => false,
//         );
//       } else if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Account already exists with this email/phone'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } else {
//       setState(() {
//         _isVerifying = false;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Invalid OTP. Please try again. (Use 123456 for testing)',
//           ),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   void _resendOTP() {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text('OTP sent successfully!')));
//     _startTimer();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final roleColor = widget.role == UserRole.customer
//         ? const Color(0xFF00897B)
//         : const Color(0xFF1976D2);

//     final defaultPinTheme = PinTheme(
//       width: 56,
//       height: 56,
//       textStyle: theme.textTheme.headlineSmall,
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(12),
//       ),
//     );

//     final focusedPinTheme = defaultPinTheme.copyDecorationWith(
//       border: Border.all(color: roleColor, width: 2),
//     );

//     final submittedPinTheme = defaultPinTheme.copyDecorationWith(
//       color: roleColor.withOpacity(0.1),
//       border: Border.all(color: roleColor),
//     );

//     return Scaffold(
//       appBar: AppBar(title: const Text('Verify Your Account')),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           // Added SingleChildScrollView for scrollability
//           padding: const EdgeInsets.all(24),
//           child: ConstrainedBox(
//             // Ensures minimum height for proper layout
//             constraints: BoxConstraints(
//               minHeight: MediaQuery.of(context).size.height -
//                   MediaQuery.of(context).padding.top -
//                   kToolbarHeight -
//                   48, // Subtract appbar height and padding
//             ),
//             child: IntrinsicHeight(
//               // Allows Spacer to work inside ScrollView
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   const SizedBox(height: 20),

//                   // Icon
//                   Icon(Icons.verified_user, size: 80, color: roleColor),
//                   const SizedBox(height: 24),

//                   // Title
//                   Text(
//                     'Verify Your Account',
//                     style: theme.textTheme.displaySmall?.copyWith(color: roleColor),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 12),

//                   // Description
//                   Text(
//                     'Enter the 6-digit code sent to\n+91 ${widget.phone}',
//                     style: theme.textTheme.bodyMedium,
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 32),

//                   // OTP Input
//                   Pinput(
//                     controller: _otpController,
//                     length: 6,
//                     defaultPinTheme: defaultPinTheme,
//                     focusedPinTheme: focusedPinTheme,
//                     submittedPinTheme: submittedPinTheme,
//                     autofocus: true,
//                     onCompleted: (_) => _verifyOTP(),
//                   ),
//                   const SizedBox(height: 24),

//                   // Timer and Resend
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       if (_secondsRemaining > 0) ...[
//                         const Icon(Icons.timer, size: 18, color: Colors.grey),
//                         const SizedBox(width: 8),
//                         Text(
//                           '00:${_secondsRemaining.toString().padLeft(2, '0')}',
//                           style: theme.textTheme.bodyMedium,
//                         ),
//                       ] else ...[
//                         TextButton(
//                           onPressed: _resendOTP,
//                           child: Text(
//                             'Resend OTP',
//                             style: TextStyle(
//                               color: roleColor,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                   const SizedBox(height: 24),

//                   // Verify Button
//                   ElevatedButton(
//                     onPressed: _isVerifying ? null : _verifyOTP,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: roleColor,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: _isVerifying
//                         ? const SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: Colors.white,
//                             ),
//                           )
//                         : const Text(
//                             'Verify & Continue',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                   ),
//                   const Spacer(), // Pushes testing info to bottom when space available

//                   // Testing Info
//                   Container(
//                     margin: const EdgeInsets.only(top: 24, bottom: 16),
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.orange.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.orange.withOpacity(0.3)),
//                     ),
//                     child: const Text(
//                       '🧪 Testing: Use OTP 123456',
//                       style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }