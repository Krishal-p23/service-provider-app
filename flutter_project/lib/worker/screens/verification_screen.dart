import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../../customer/services/api_service.dart';
import '../../theme/app_theme.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isStartingSession = false;

  // Verification status and user data
  String? _verificationStatus;
  bool? _isVerified;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVerificationStatus();
  }

  Future<void> _loadVerificationStatus() async {
    try {
      await _apiService.initialize();
      final result = await _apiService.getWorkerProfile();

      if (!mounted) return;

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        setState(() {
          _verificationStatus =
              data['verification_status'] as String? ?? 'not_started';
          _isVerified = data['is_verified'] as bool? ?? false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              result['message'] ?? 'Failed to load verification status';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading verification status: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _startKycSession() async {
    setState(() {
      _isStartingSession = true;
    });

    try {
      await _apiService.initialize();
      final result = await _apiService.startWorkerKycSession();

      if (!mounted) {
        return;
      }

      setState(() {
        _isStartingSession = false;
      });

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        final sessionUrl = (data['session_url'] ?? '').toString();

        if (sessionUrl.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Didit session URL was not returned by server.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiditKycWebViewScreen(sessionUrl: sessionUrl),
          ),
        );

        if (mounted) {
          // Refresh verification status after KYC flow
          _loadVerificationStatus();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'KYC flow finished. Verification status updates automatically within a few seconds.',
              ),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
        return;
      }

      // Check for error message at root level first, then in data
      String message = result['message'] ?? 'Failed to start KYC session.';

      if (message == 'Failed to start KYC session.' &&
          result['data'] is Map<String, dynamic>) {
        final data = result['data'] as Map<String, dynamic>;
        message = (data['message'] ?? data['error'] ?? message).toString();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isStartingSession = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error starting KYC session: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildVerificationUI() {
    // If loading, show loading indicator
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading verification status...',
              style: TextStyle(
                color: AppTheme.getTextColor(context, secondary: true),
              ),
            ),
          ],
        ),
      );
    }

    // If error loading data
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.getTextColor(context)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadVerificationStatus,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // If already verified
    if (_isVerified == true && _verificationStatus == 'approved') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withValues(alpha: 0.2),
            ),
            padding: const EdgeInsets.all(24),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Account Verified',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextColor(context),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your KYC verification has been approved. You can now accept bookings.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.getTextColor(context, secondary: true),
            ),
          ),
          const SizedBox(height: 40),
        ],
      );
    }

    // If verification is pending
    if (_verificationStatus == 'pending') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange.withValues(alpha: 0.2),
            ),
            padding: const EdgeInsets.all(24),
            child: const Icon(Icons.schedule, color: Colors.orange, size: 64),
          ),
          const SizedBox(height: 24),
          Text(
            'Verification Pending',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextColor(context),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your KYC verification is being processed. This usually takes a few seconds.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.getTextColor(context, secondary: true),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadVerificationStatus,
            icon: const Icon(Icons.refresh),
            label: const Text('Check Status'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
        ],
      );
    }

    // If verification was rejected
    if (_verificationStatus == 'rejected') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withValues(alpha: 0.2),
            ),
            padding: const EdgeInsets.all(24),
            child: const Icon(Icons.cancel, color: Colors.red, size: 64),
          ),
          const SizedBox(height: 24),
          Text(
            'Verification Rejected',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextColor(context),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your KYC verification was rejected. Please try again with a clearer image.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.getTextColor(context, secondary: true),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isStartingSession ? null : _startKycSession,
            icon: _isStartingSession
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.open_in_browser),
            label: Text(
              _isStartingSession ? 'Starting KYC Session...' : 'Try Again',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
        ],
      );
    }

    // Default: Not verified - Show start verification button
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.workerPrimaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.workerPrimaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.verified_user,
                    color: AppTheme.workerPrimaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Didit KYC Verification',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.getTextColor(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'To accept bookings, you need to complete KYC (Know Your Customer) verification. Tap the button below to verify your identity securely.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.getTextColor(context, secondary: true),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '⏱️ Takes 1-2 minutes. Verification updates automatically after completion.',
                  style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _isStartingSession ? null : _startKycSession,
          icon: _isStartingSession
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.open_in_browser),
          label: Text(
            _isStartingSession
                ? 'Starting KYC Session...'
                : 'Start KYC Verification',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.workerPrimaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: _isLoading ? null : _loadVerificationStatus,
          icon: const Icon(Icons.refresh),
          label: const Text('Check Status / Refresh'),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.workerPrimaryColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Verify Account',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: AppTheme.getSurfaceColor(context),
        foregroundColor: AppTheme.getTextColor(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadVerificationStatus,
            tooltip: 'Refresh Status',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildVerificationUI(),
        ),
      ),
    );
  }
}

class DiditKycWebViewScreen extends StatefulWidget {
  final String sessionUrl;

  const DiditKycWebViewScreen({super.key, required this.sessionUrl});

  @override
  State<DiditKycWebViewScreen> createState() => _DiditKycWebViewScreenState();
}

class _DiditKycWebViewScreenState extends State<DiditKycWebViewScreen> {
  late final WebViewController _controller;
  bool _isPageLoading = true;

  @override
  void initState() {
    super.initState();

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _isPageLoading = true;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() {
                _isPageLoading = false;
              });
            }
          },
          onNavigationRequest: (request) {
            if (request.url.contains('/api/workers/kyc/callback/')) {
              Navigator.pop(context);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.sessionUrl));

    // Required for Android WebView camera/microphone access in KYC flow.
    if (controller.platform is AndroidWebViewController) {
      final androidController = controller.platform as AndroidWebViewController;
      androidController.setOnPlatformPermissionRequest((request) {
        request.grant();
      });
    }

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KYC Verification')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isPageLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
