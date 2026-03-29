import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/worker_verification_provider.dart';
import 'verification_status_screen.dart';
import '../../theme/app_theme.dart';
import '../../providers/worker_provider.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _govIdController = TextEditingController();
  String? _selectedImagePath;
  String? _selectedDocumentType = 'aadhar';
  bool _isSubmitting = false;

  // Document type options and their display names
  static const Map<String, String> documentTypeMap = {
    'aadhar': 'Aadhar Card',
    'pan': 'PAN Card',
    'driving_license': 'Driving License',
    'passport': 'Passport',
    'voter_id': 'Voter ID',
  };

  @override
  void dispose() {
    _govIdController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitVerification() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImagePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload your Government ID image'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      final verificationProvider = context.read<WorkerVerificationProvider>();
      final success = await verificationProvider.submitVerificationViaAPI(
        documentType: _selectedDocumentType!,
        govId: _govIdController.text,
        imagePath: _selectedImagePath!,
      );

      setState(() {
        _isSubmitting = false;
      });

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to verification status screen
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VerificationStatusScreen(),
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              verificationProvider.lastError ??
                  'Failed to submit verification. Please try again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
          'Verify Account',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: AppTheme.getSurfaceColor(context),
        foregroundColor: AppTheme.getTextColor(context),
        // foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Card - Now mentions demo verification
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.workerPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.workerPrimaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.workerPrimaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verify your account',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.getTextColor(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Demo verification - Submit your ID to see instant verification result',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.getTextColor(
                                  context,
                                  secondary: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Document Type Dropdown
                Text(
                  'Select Document Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.getSurfaceColor(context).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.getTextColor(
                        context,
                        secondary: true,
                      ).withOpacity(0.3),
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedDocumentType,
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: AppTheme.getSurfaceColor(context),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: AppTheme.workerPrimaryColor,
                    ),
                    items: documentTypeMap.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            color: AppTheme.getTextColor(context),
                            fontSize: 15,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDocumentType = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Government ID Number Field
                Text(
                  'Government ID Number',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                Builder(
                  builder: (context) {
                    String hintText = 'Enter your Government ID number';
                    if (_selectedDocumentType != null) {
                      hintText = switch (_selectedDocumentType) {
                        'aadhar' => 'Enter 12-digit Aadhaar number',
                        'pan' => 'Enter 10-character PAN',
                        'driving_license' => 'Enter Driving License number',
                        'passport' => 'Enter Passport number',
                        'voter_id' => 'Enter Voter ID number',
                        _ => 'Enter your Government ID number',
                      };
                    }
                    return TextFormField(
                      controller: _govIdController,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: TextStyle(
                          color: AppTheme.getTextColor(
                            context,
                            secondary: true,
                          ),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.badge_outlined,
                          size: 20,
                          color: AppTheme.workerPrimaryColor,
                        ),
                        filled: true,
                        fillColor: AppTheme.getSurfaceColor(
                          context,
                        ).withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppTheme.getTextColor(
                              context,
                              secondary: true,
                            ).withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppTheme.getTextColor(
                              context,
                              secondary: true,
                            ).withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppTheme.workerPrimaryColor,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Government ID number is required';
                        }
                        if (value.length < 6) {
                          return 'Please enter a valid ID number';
                        }
                        return null;
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Upload ID Image
                const Text(
                  'Government ID Image',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedImagePath != null
                            ? const Color(0xFF1976D2)
                            : Colors.grey.shade300,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: _selectedImagePath != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(_selectedImagePath!),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF1976D2),
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tap to upload ID image',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'JPG, PNG (Max 5MB)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                if (_selectedImagePath != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Image selected: ${_selectedImagePath!.split('/').last}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.green,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: _pickImage,
                        child: const Text('Change'),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 32),

                // Guidelines
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info,
                            color: Colors.amber.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Demo Verification',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Upload any clear ID image\n'
                        '• Verification is instant (demo mode)\n'
                        '• Result will be random (verified/unverified)\n'
                        '• Real eKYC will be enabled later',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
