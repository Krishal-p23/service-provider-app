import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/user_provider.dart';

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
  
  String? _profileImagePath;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _mobileController = TextEditingController(text: user?.mobile ?? '');
    
    // Parse existing address if available
    final address = user?.address ?? '';
    final addressParts = _parseAddress(address);
    
    _pincodeController = TextEditingController(text: addressParts['pincode'] ?? '');
    _cityController = TextEditingController(text: addressParts['city'] ?? '');
    _localityController = TextEditingController(text: addressParts['locality'] ?? '');
    _landmarkController = TextEditingController(text: addressParts['landmark'] ?? '');
    _stateController = TextEditingController(text: addressParts['state'] ?? '');
    _countryController = TextEditingController(text: addressParts['country'] ?? 'India');
    
    _profileImagePath = user?.profilePicture;
  }

  Map<String, String> _parseAddress(String address) {
    if (address.isEmpty) {
      return {
        'locality': '',
        'city': '',
        'pincode': '',
        'landmark': '',
        'state': '',
        'country': 'India',
      };
    }

    // Split address by comma
    final parts = address.split(',').map((e) => e.trim()).toList();
    
    final Map<String, String> addressMap = {
      'locality': '',
      'city': '',
      'pincode': '',
      'landmark': '',
      'state': '',
      'country': 'India',
    };

    // Try to extract pincode (6 digits)
    final pincodePattern = RegExp(r'\b\d{6}\b');
    final pincodeMatch = pincodePattern.firstMatch(address);
    if (pincodeMatch != null) {
      addressMap['pincode'] = pincodeMatch.group(0)!;
    }

    // Extract landmark (starts with "Near ")
    for (var part in parts) {
      if (part.toLowerCase().startsWith('near ')) {
        addressMap['landmark'] = part.substring(5); // Remove "Near "
        break;
      }
    }

    // Assign remaining parts intelligently
    final filteredParts = parts.where((part) {
      return !part.toLowerCase().startsWith('near ') && 
             !pincodePattern.hasMatch(part);
    }).toList();

    if (filteredParts.isNotEmpty) {
      addressMap['locality'] = filteredParts[0];
    }
    if (filteredParts.length > 1) {
      addressMap['city'] = filteredParts[1];
    }
    if (filteredParts.length > 2) {
      addressMap['state'] = filteredParts[2];
    }
    if (filteredParts.length > 3) {
      addressMap['country'] = filteredParts[3];
    }

    return addressMap;
  }

  String _formatAddress() {
    final parts = <String>[];
    
    if (_localityController.text.trim().isNotEmpty) {
      parts.add(_localityController.text.trim());
    }
    if (_landmarkController.text.trim().isNotEmpty) {
      parts.add('Near ${_landmarkController.text.trim()}');
    }
    if (_cityController.text.trim().isNotEmpty) {
      parts.add(_cityController.text.trim());
    }
    if (_stateController.text.trim().isNotEmpty) {
      parts.add(_stateController.text.trim());
    }
    if (_pincodeController.text.trim().isNotEmpty) {
      parts.add(_pincodeController.text.trim());
    }
    if (_countryController.text.trim().isNotEmpty) {
      parts.add(_countryController.text.trim());
    }
    
    return parts.join(', ');
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        setState(() {
          _profileImagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            if (_profileImagePath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _profileImagePath = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final userProvider = context.read<UserProvider>();
      final currentUser = userProvider.currentUser;

      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          name: _nameController.text.trim(),
          mobile: _mobileController.text.trim(),
          address: _formatAddress(),
          profilePicture: _profileImagePath,
        );

        userProvider.updateUser(updatedUser);

        setState(() {
          _isLoading = false;
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : _handleSave,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Profile Picture
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: theme.primaryColor.withOpacity(0.1),
                        backgroundImage: _profileImagePath != null
                            ? FileImage(File(_profileImagePath!))
                            : null,
                        child: _profileImagePath == null
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: theme.primaryColor,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: _showImageSourceDialog,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Tap to change photo',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Full Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Mobile Number
                TextFormField(
                  controller: _mobileController,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    hintText: 'Enter your mobile number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile number';
                    }
                    if (value.length != 10) {
                      return 'Please enter a valid 10-digit number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Address Section Header
                Row(
                  children: [
                    Icon(Icons.location_on, color: theme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Address Details',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Pincode
                TextFormField(
                  controller: _pincodeController,
                  decoration: const InputDecoration(
                    labelText: 'Pincode',
                    hintText: 'Enter pincode',
                    prefixIcon: Icon(Icons.pin_drop),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter pincode';
                    }
                    if (value.length != 6) {
                      return 'Please enter a valid 6-digit pincode';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // City
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    hintText: 'Enter city name',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter city';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Locality
                TextFormField(
                  controller: _localityController,
                  decoration: const InputDecoration(
                    labelText: 'Locality/Area',
                    hintText: 'Enter locality or area',
                    prefixIcon: Icon(Icons.home_work),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter locality';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Landmark (Optional)
                TextFormField(
                  controller: _landmarkController,
                  decoration: const InputDecoration(
                    labelText: 'Landmark (Optional)',
                    hintText: 'Enter nearby landmark',
                    prefixIcon: Icon(Icons.place),
                  ),
                ),
                const SizedBox(height: 16),
                
                // State
                TextFormField(
                  controller: _stateController,
                  decoration: const InputDecoration(
                    labelText: 'State',
                    hintText: 'Enter state name',
                    prefixIcon: Icon(Icons.map),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter state';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Country
                TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    hintText: 'Enter country name',
                    prefixIcon: Icon(Icons.public),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter country';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                // Save Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}