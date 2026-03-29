import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/worker_verification_provider.dart';
import '../../theme/app_theme.dart';

/// Screen to show verification result (Verified or Unverified)
class VerificationStatusScreen extends StatefulWidget {
  const VerificationStatusScreen({super.key});

  @override
  State<VerificationStatusScreen> createState() =>
      _VerificationStatusScreenState();
}

class _VerificationStatusScreenState extends State<VerificationStatusScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Verification Status',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: AppTheme.getSurfaceColor(context),
        foregroundColor: AppTheme.getTextColor(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Consumer<WorkerVerificationProvider>(
            builder: (context, verificationProvider, _) {
              final hasSubmittedDocument =
                  verificationProvider.governmentId.trim().isNotEmpty ||
                  verificationProvider.idImagePath.trim().isNotEmpty;

              if (!hasSubmittedDocument) {
                return _buildNoDocumentState(context);
              }

              final isVerified = verificationProvider.isVerified;
              final documentType = verificationProvider.documentType;
              final documentNumber = verificationProvider.governmentId;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isVerified
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      border: Border.all(
                        color: isVerified ? Colors.green : Colors.orange,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      isVerified ? Icons.check_circle : Icons.pending,
                      size: 80,
                      color: isVerified ? Colors.green : Colors.orange,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Status Title
                  Text(
                    isVerified ? 'Verified!' : 'Unverified',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isVerified ? Colors.green : Colors.orange,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Status Message
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isVerified
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isVerified
                            ? Colors.green.withOpacity(0.3)
                            : Colors.orange.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      isVerified
                          ? 'Your identity has been successfully verified. You can now enjoy all features of the platform.'
                          : 'Your identity could not be verified. Please resubmit your document for verification.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.getTextColor(context, secondary: true),
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Document Details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.getSurfaceColor(context).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.getTextColor(
                          context,
                          secondary: true,
                        ).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Document Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          'Document Type',
                          _getDocumentTypeDisplay(documentType),
                          context,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          'Document Number',
                          documentNumber,
                          context,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          'Status',
                          isVerified ? 'Verified ✓' : 'Unverified',
                          context,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Info Note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.workerPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.workerPrimaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.workerPrimaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Note: This is a demo verification. The eKYC system is currently in test mode.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.getTextColor(
                                context,
                                secondary: true,
                              ),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  if (!isVerified)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Could navigate back to verification screen to resubmit
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry Verification'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.workerPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check),
                      label: const Text('Continue'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Build detail row for document info
  Widget _buildDetailRow(String label, String value, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.getTextColor(context, secondary: true),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextColor(context),
          ),
        ),
      ],
    );
  }

  /// Build state when no document submitted
  Widget _buildNoDocumentState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 48),
        Icon(
          Icons.document_scanner_outlined,
          size: 80,
          color: AppTheme.getTextColor(
            context,
            secondary: true,
          ).withOpacity(0.5),
        ),
        const SizedBox(height: 24),
        Text(
          'No Documents Submitted',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.getTextColor(context),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'You haven\'t submitted any documents for verification yet.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.getTextColor(context, secondary: true),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.workerPrimaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
          child: const Text('Submit Document'),
        ),
      ],
    );
  }

  /// Get display name for document type
  String _getDocumentTypeDisplay(String documentType) {
    return switch (documentType) {
      'aadhar' => 'Aadhar Card',
      'pan' => 'PAN Card',
      'driving_license' => 'Driving License',
      'passport' => 'Passport',
      'voter_id' => 'Voter ID',
      _ => 'Government ID',
    };
  }
}
