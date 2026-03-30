import 'package:flutter/material.dart';
import '../../customer/services/api_service.dart';
import '../../theme/app_theme.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({super.key});

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  final TextEditingController _accountHolderController =
      TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _upiController = TextEditingController();
  final FocusNode _ifscFocusNode = FocusNode();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isVerified = false;
  bool _isValidatingIfsc = false;
  String? _ifscBankName;
  String? _ifscError;

  @override
  void initState() {
    super.initState();
    _ifscFocusNode.addListener(() {
      if (!_ifscFocusNode.hasFocus) {
        _validateIfsc();
      }
    });
    _loadBankDetails();
  }

  @override
  void dispose() {
    _accountHolderController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _upiController.dispose();
    _ifscFocusNode.dispose();
    super.dispose();
  }

  Future<void> _validateIfsc() async {
    // TODO: Replace IFSC-only validation with Cashfree penny drop for production.
    // Cashfree sandbox: https://dev.cashfree.com/bank-account-verification
    // Requires CASHFREE_APP_ID and CASHFREE_SECRET_KEY in .env
    final ifsc = _ifscController.text.trim().toUpperCase();
    if (ifsc.isEmpty) return;

    setState(() {
      _isValidatingIfsc = true;
      _ifscError = null;
      _ifscBankName = null;
    });

    try {
      await _apiService.initialize();
      final result = await _apiService.validateIfsc(ifsc);

      if (!mounted) return;

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        final bank = data['bank']?.toString() ?? '';
        final branch = data['branch']?.toString() ?? '';
        setState(() {
          _ifscBankName = branch.isNotEmpty ? '$bank, $branch' : bank;
          _ifscError = null;
          _isValidatingIfsc = false;
        });

        if (bank.isNotEmpty) {
          _bankNameController.text = bank;
        }
        return;
      }

      setState(() {
        _ifscError = (result['data']?['message'] ?? 'Invalid IFSC code')
            .toString();
        _isValidatingIfsc = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _ifscError = 'Unable to validate IFSC right now';
        _isValidatingIfsc = false;
      });
    }
  }

  Future<void> _loadBankDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.initialize();
      final result = await _apiService.getWorkerBankDetails();

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        _accountHolderController.text =
            data['account_holder_name']?.toString() ?? '';
        _bankNameController.text = data['bank_name']?.toString() ?? '';
        _accountNumberController.text =
            data['account_number']?.toString() ?? '';
        _ifscController.text = data['ifsc_code']?.toString() ?? '';
        _upiController.text = data['upi_id']?.toString() ?? '';
        _isVerified = data['is_verified'] == true;
      }
    } catch (_) {
      // Keep fields empty on failure.
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveBankDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final result = await _apiService.saveWorkerBankDetails(
        accountHolderName: _accountHolderController.text.trim(),
        bankName: _bankNameController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        ifscCode: _ifscController.text.trim().toUpperCase(),
        upiId: _upiController.text.trim(),
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bank details saved successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save bank details')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save bank details')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppTheme.getTextColor(context);
    final textSecondary = AppTheme.getTextColor(context, secondary: true);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Bank Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: textPrimary,
          ),
        ),
        backgroundColor: AppTheme.getSurfaceColor(context),
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: (_isVerified ? Colors.green : Colors.orange)
                            .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (_isVerified ? Colors.green : Colors.orange)
                              .withOpacity(0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isVerified ? Icons.verified : Icons.info_outline,
                            color: _isVerified ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _isVerified
                                  ? 'Bank account verified'
                                  : 'Bank account not verified yet',
                              style: TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Payout Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'All worker earnings will be transferred to this account.',
                      style: TextStyle(fontSize: 13, color: textSecondary),
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _accountHolderController,
                      label: 'Account Holder Name',
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Enter account holder name'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      controller: _bankNameController,
                      label: 'Bank Name',
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Enter bank name'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      controller: _accountNumberController,
                      label: 'Account Number',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return 'Enter account number';
                        if (v.length < 8)
                          return 'Account number looks too short';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      controller: _ifscController,
                      label: 'IFSC Code',
                      focusNode: _ifscFocusNode,
                      textCapitalization: TextCapitalization.characters,
                      onChanged: (_) {
                        setState(() {
                          _ifscError = null;
                          _ifscBankName = null;
                        });
                      },
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return 'Enter IFSC code';
                        if (v.length < 8) return 'Enter a valid IFSC code';
                        return null;
                      },
                    ),
                    if (_isValidatingIfsc)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                    if (_ifscBankName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _ifscBankName!,
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                    if (_ifscError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _ifscError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 12),
                    _buildField(
                      controller: _upiController,
                      label: 'UPI ID (Optional)',
                      validator: (_) => null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveBankDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Save Bank Details',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      validator: validator,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
