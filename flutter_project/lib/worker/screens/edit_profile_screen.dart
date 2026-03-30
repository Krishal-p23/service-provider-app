import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/worker_provider.dart';
import '../../theme/app_theme.dart';
import '../../customer/services/location_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _pincodeController;
  late TextEditingController _cityController;
  late TextEditingController _localityController;
  late TextEditingController _landmarkController;
  late TextEditingController _stateController;
  late TextEditingController _countryController;

  bool _isSaving = false;
  bool _isFetchingLocation = false;
  bool _hasLocationData = false;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    final workerProvider = context.read<WorkerProvider>();
    final user = workerProvider.currentUser;

    _nameController = TextEditingController(text: user?.name ?? '');
    _mobileController = TextEditingController(text: user?.phone ?? '');
    _pincodeController = TextEditingController();
    _cityController = TextEditingController();
    _localityController = TextEditingController();
    _landmarkController = TextEditingController();
    _stateController = TextEditingController();
    _countryController = TextEditingController(text: 'India');

    _applyLocationToForm(workerProvider.currentUserLocation?.address);
    _loadSavedLocation();
  }

  Future<void> _loadSavedLocation() async {
    final workerProvider = context.read<WorkerProvider>();

    if (workerProvider.currentUserLocation == null) {
      await workerProvider.fetchUserLocation();
    }

    final location = workerProvider.currentUserLocation;
    if (!mounted || location == null) {
      return;
    }

    setState(() {
      _latitude = location.latitude;
      _longitude = location.longitude;
      _hasLocationData = true;
    });

    _applyLocationToForm(location.address);
  }

  void _applyLocationToForm(String? address) {
    if (address == null || address.trim().isEmpty) {
      return;
    }

    final parts = address
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isNotEmpty) {
      _localityController.text = parts.first;
    }
    if (parts.length > 1) {
      _cityController.text = parts[1];
    }
    if (parts.length > 2) {
      _stateController.text = parts[2];
    }
    if (parts.length > 3) {
      _pincodeController.text = parts[3];
    }
    if (parts.length > 4) {
      _countryController.text = parts[4];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _pincodeController.dispose();
    _cityController.dispose();
    _localityController.dispose();
    _landmarkController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() {
      _isFetchingLocation = true;
    });

    try {
      final locationData = await LocationService.handleLocationRequest(context);
      if (!mounted) {
        return;
      }

      if (locationData != null) {
        final address = (locationData['address'] ?? '').toString();
        setState(() {
          _latitude = (locationData['latitude'] as num).toDouble();
          _longitude = (locationData['longitude'] as num).toDouble();
          _hasLocationData = true;
        });

        _applyLocationToForm(address);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location fetched successfully'),
            backgroundColor: Color(0xFF1976D2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingLocation = false;
        });
      }
    }
  }

  String _composeAddress() {
    final addressParts = [
      _localityController.text.trim(),
      if (_landmarkController.text.trim().isNotEmpty)
        _landmarkController.text.trim(),
      _cityController.text.trim(),
      _stateController.text.trim(),
      _pincodeController.text.trim(),
      _countryController.text.trim(),
    ].where((part) => part.isNotEmpty).toList();

    return addressParts.join(', ');
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final workerProvider = context.read<WorkerProvider>();
    final currentUser = workerProvider.currentUser;

    if (currentUser == null) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Worker is not logged in'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final profileSuccess = await workerProvider.updateUser({
        'name': _nameController.text.trim(),
        'email': currentUser.email,
        'phone': _mobileController.text.trim(),
      });

      bool locationSuccess = true;
      final address = _composeAddress();
      if (_hasLocationData &&
          _latitude != null &&
          _longitude != null &&
          address.isNotEmpty) {
        locationSuccess = await workerProvider.updateUserLocation(
          latitude: _latitude!,
          longitude: _longitude!,
          address: address,
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      if (profileSuccess && locationSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Color(0xFF1976D2),
          ),
        );
        Navigator.pop(context);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(workerProvider.error ?? 'Failed to update profile'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final workerProvider = context.watch<WorkerProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.getTextColor(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: AppTheme.getSurfaceColor(context),
        foregroundColor: AppTheme.getTextColor(context),
        elevation: 0,
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.check, color: AppTheme.workerPrimaryColor),
            onPressed: _isSaving ? null : _saveChanges,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1976D2).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1976D2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to change photo',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildTextField(
                  context: context,
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  context: context,
                  controller: _mobileController,
                  label: 'Mobile Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile number';
                    }
                    if (value.length != 10) {
                      return 'Please enter a valid 10-digit mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppTheme.workerPrimaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Address Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.workerPrimaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isFetchingLocation
                        ? null
                        : _fetchCurrentLocation,
                    icon: _isFetchingLocation
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                    label: Text(
                      _hasLocationData
                          ? 'Refresh Current Location'
                          : 'Use Current Location',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.workerPrimaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  workerProvider.currentUserLocation?.address.isNotEmpty == true
                      ? 'Saved in database: ${workerProvider.currentUserLocation!.address}'
                      : 'No saved location in database',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.getTextColor(context, secondary: true),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  context: context,
                  controller: _pincodeController,
                  label: 'Pincode',
                  icon: Icons.pin_drop,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  context: context,
                  controller: _cityController,
                  label: 'City',
                  icon: Icons.location_city,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  context: context,
                  controller: _localityController,
                  label: 'Locality/Area',
                  icon: Icons.home_work,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  context: context,
                  controller: _landmarkController,
                  label: 'Landmark (Optional)',
                  icon: Icons.place,
                  required: false,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  context: context,
                  controller: _stateController,
                  label: 'State',
                  icon: Icons.map,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  context: context,
                  controller: _countryController,
                  label: 'Country',
                  icon: Icons.public,
                  enabled: false,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.workerPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Save Changes',
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

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool required = true,
    bool enabled = true,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final labelColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final fillColor = isDarkMode
        ? Colors.grey.shade800.withOpacity(0.6)
        : (enabled ? Colors.grey.shade50 : Colors.grey.shade100);
    final borderColor = isDarkMode
        ? Colors.grey.shade700.withOpacity(0.5)
        : Colors.grey.shade300;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      style: TextStyle(
        color: textColor,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: labelColor, fontSize: 13),
        prefixIcon: Icon(icon, size: 20, color: AppTheme.workerPrimaryColor),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
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
      validator: required ? validator : null,
    );
  }
}
