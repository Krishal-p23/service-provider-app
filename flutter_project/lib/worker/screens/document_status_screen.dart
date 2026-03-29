import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/worker_verification_provider.dart';
import '../../theme/app_theme.dart';

class DocumentStatusScreen extends StatefulWidget {
  const DocumentStatusScreen({super.key});

  @override
  State<DocumentStatusScreen> createState() => _DocumentStatusScreenState();
}

class _DocumentStatusScreenState extends State<DocumentStatusScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVerificationStatus();
  }

  Future<void> _fetchVerificationStatus() async {
    final verificationProvider = context.read<WorkerVerificationProvider>();
    await verificationProvider.fetchVerificationStatusFromAPI();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Consumer<WorkerVerificationProvider>(
                builder: (context, verificationProvider, _) {
                  if (verificationProvider.lastError != null) {
                    return _buildErrorState(verificationProvider);
                  }

                  if (!verificationProvider.isPending &&
                      !verificationProvider.isVerified) {
                    return _buildNoDocumentState();
                  }

                  return _buildStatusBody(verificationProvider);
                },
              ),
      ),
    );
  }

  Widget _buildNoDocumentState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 80,
              color: AppTheme.workerPrimaryColor.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Documents Submitted',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.getTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Upload your government ID to verify your account',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.getTextColor(context, secondary: true),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.workerPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Upload Document',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(WorkerVerificationProvider provider) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Error Loading Status',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.getTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              provider.lastError ?? 'Unknown error occurred',
              style: TextStyle(fontSize: 14, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                  });
                  _fetchVerificationStatus();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.workerPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBody(WorkerVerificationProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document Type Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.getDividerColor(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Document Type',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.getTextColor(context, secondary: true),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getDocumentDisplayName(provider.documentType),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Document Number Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.getDividerColor(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Document Number',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.getTextColor(context, secondary: true),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider.governmentId,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextColor(context),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Verification Status Card
          _buildStatusCard(provider),
          const SizedBox(height: 16),

          // Document Image (if available)
          if (provider.idImagePath.isNotEmpty) _buildImageSection(provider),

          const SizedBox(height: 16),

          // Rejection Reason (if rejected)
          if (provider.isVerified == false && provider.governmentId.isNotEmpty)
            _buildRejectionReasonCard(provider),
        ],
      ),
    );
  }

  Widget _buildStatusCard(WorkerVerificationProvider provider) {
    late Color statusColor;
    late String statusText;
    late IconData statusIcon;

    if (provider.isVerified) {
      statusColor = Colors.green;
      statusText = 'Verified';
      statusIcon = Icons.check_circle;
    } else if (provider.isPending) {
      statusColor = const Color(0xFFFFA500); // Orange
      statusText = 'Pending Review';
      statusIcon = Icons.schedule;
    } else {
      statusColor = Colors.red;
      statusText = 'Rejected';
      statusIcon = Icons.cancel;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(WorkerVerificationProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Uploaded Document',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.getTextColor(context),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.getDividerColor(context)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              provider.idImagePath,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRejectionReasonCard(WorkerVerificationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(
                'Rejection Reason',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            provider.governmentId,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.getTextColor(context),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.refresh),
              label: const Text('Resubmit Document'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.workerPrimaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDocumentDisplayName(String docType) {
    const Map<String, String> nameMap = {
      'aadhar': 'Aadhar Card',
      'pan': 'PAN Card',
      'driving_license': 'Driving License',
      'passport': 'Passport',
      'voter_id': 'Voter ID',
    };
    return nameMap[docType] ?? docType;
  }
}
