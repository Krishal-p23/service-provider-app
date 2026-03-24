// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/worker_provider.dart';
// import '../../models/user.dart';
// import '../../models/user_role.dart';

// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _nameController;
//   late TextEditingController _mobileController;
//   late TextEditingController _pincodeController;
//   late TextEditingController _cityController;
//   late TextEditingController _localityController;
//   late TextEditingController _landmarkController;
//   late TextEditingController _stateController;
//   late TextEditingController _countryController;

//   @override
//   void initState() {
//     super.initState();
//     final worker = context.read<WorkerProvider>().currentWorker;
//     _nameController = TextEditingController(text: worker?.name ?? '');
//     _mobileController = TextEditingController(text: worker?.mobile ?? '');
    
//     // Parse address if available
//     final address = worker?.address ?? '';
//     _pincodeController = TextEditingController();
//     _cityController = TextEditingController();
//     _localityController = TextEditingController();
//     _landmarkController = TextEditingController();
//     _stateController = TextEditingController();
//     _countryController = TextEditingController(text: 'India');
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _mobileController.dispose();
//     _pincodeController.dispose();
//     _cityController.dispose();
//     _localityController.dispose();
//     _landmarkController.dispose();
//     _stateController.dispose();
//     _countryController.dispose();
//     super.dispose();
//   }

//   void _saveChanges() {
//     if (_formKey.currentState!.validate()) {
//       final workerProvider = context.read<WorkerProvider>();
//       final currentWorker = workerProvider.currentWorker;
      
//       if (currentWorker != null) {
//         // Build full address
//         final addressParts = [
//           _localityController.text,
//           _landmarkController.text.isNotEmpty ? _landmarkController.text : null,
//           _cityController.text,
//           _stateController.text,
//           _pincodeController.text,
//           _countryController.text,
//         ].where((part) => part != null && part.isNotEmpty).join(', ');

//         final updatedWorker = User(
//           name: _nameController.text,
//           email: currentWorker.email,
//           mobile: _mobileController.text,
//           password: currentWorker.password,
//           address: addressParts,
//           profilePicture: currentWorker.profilePicture,
//           role: UserRole.worker,
//         );

//         workerProvider.updateWorker(updatedWorker);
        
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Profile updated successfully'),
//             backgroundColor: Color(0xFF00897B),
//           ),
//         );
        
//         Navigator.pop(context);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Edit Profile',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         foregroundColor: Colors.black,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.check),
//             onPressed: _saveChanges,
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Profile Photo Section
//                 Center(
//                   child: Column(
//                     children: [
//                       Stack(
//                         children: [
//                           Container(
//                             width: 100,
//                             height: 100,
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF00897B).withOpacity(0.2),
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.person,
//                               size: 50,
//                               color: Color(0xFF00897B),
//                             ),
//                           ),
//                           Positioned(
//                             bottom: 0,
//                             right: 0,
//                             child: Container(
//                               padding: const EdgeInsets.all(8),
//                               decoration: const BoxDecoration(
//                                 color: Color(0xFF00897B),
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(
//                                 Icons.camera_alt,
//                                 size: 20,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Tap to change photo',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 32),

//                 // Full Name
//                 _buildTextField(
//                   controller: _nameController,
//                   label: 'Full Name',
//                   icon: Icons.person,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your name';
//                     }
//                     return null;
//                   },
//                 ),

//                 const SizedBox(height: 16),

//                 // Mobile Number
//                 _buildTextField(
//                   controller: _mobileController,
//                   label: 'Mobile Number',
//                   icon: Icons.phone,
//                   keyboardType: TextInputType.phone,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your mobile number';
//                     }
//                     if (value.length != 10) {
//                       return 'Please enter a valid 10-digit mobile number';
//                     }
//                     return null;
//                   },
//                 ),

//                 const SizedBox(height: 24),

//                 // Address Details Section
//                 const Row(
//                   children: [
//                     Icon(Icons.location_on, color: Color(0xFF00897B), size: 20),
//                     SizedBox(width: 8),
//                     Text(
//                       'Address Details',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF00897B),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 16),

//                 // Pincode
//                 _buildTextField(
//                   controller: _pincodeController,
//                   label: 'Pincode',
//                   icon: Icons.pin_drop,
//                   keyboardType: TextInputType.number,
//                 ),

//                 const SizedBox(height: 16),

//                 // City
//                 _buildTextField(
//                   controller: _cityController,
//                   label: 'City',
//                   icon: Icons.location_city,
//                 ),

//                 const SizedBox(height: 16),

//                 // Locality/Area
//                 _buildTextField(
//                   controller: _localityController,
//                   label: 'Locality/Area',
//                   icon: Icons.home_work,
//                 ),

//                 const SizedBox(height: 16),

//                 // Landmark (Optional)
//                 _buildTextField(
//                   controller: _landmarkController,
//                   label: 'Landmark (Optional)',
//                   icon: Icons.place,
//                   required: false,
//                 ),

//                 const SizedBox(height: 16),

//                 // State
//                 _buildTextField(
//                   controller: _stateController,
//                   label: 'State',
//                   icon: Icons.map,
//                 ),

//                 const SizedBox(height: 16),

//                 // Country
//                 _buildTextField(
//                   controller: _countryController,
//                   label: 'Country',
//                   icon: Icons.public,
//                   enabled: false,
//                 ),

//                 const SizedBox(height: 32),

//                 // Save Changes Button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _saveChanges,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF00897B),
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: const Text(
//                       'Save Changes',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 16),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//     bool required = true,
//     bool enabled = true,
//   }) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       enabled: enabled,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, size: 20),
//         filled: true,
//         fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: Color(0xFF00897B), width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: Colors.red),
//         ),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       ),
//       validator: required ? validator : null,
//     );
//   }
// }








import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/worker_provider.dart';
import '../../customer/models/user.dart';
import '../../customer/models/user_role.dart';

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

  @override
  void initState() {
    super.initState();
    final user = context.read<WorkerProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _mobileController = TextEditingController(text: user?.phone ?? '');
    
    // Parse address if available
    // TODO: Add address parsing when user model has address
    final address = ''; // user?.address ?? '';
    _pincodeController = TextEditingController();
    _cityController = TextEditingController();
    _localityController = TextEditingController();
    _landmarkController = TextEditingController();
    _stateController = TextEditingController();
    _countryController = TextEditingController(text: 'India');
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

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final workerProvider = context.read<WorkerProvider>();
        final currentUser = workerProvider.currentUser;
        
        if (currentUser != null) {
          // Build full address
          final addressParts = [
            _localityController.text,
            _landmarkController.text.isNotEmpty ? _landmarkController.text : null,
            _cityController.text,
            _stateController.text,
            _pincodeController.text,
            _countryController.text,
          ].where((part) => part != null && part.isNotEmpty).join(', ');

          final userData = {
            'name': _nameController.text,
            'email': currentUser.email,
            'phone': _mobileController.text,
            // TODO: Add address to user model if needed
          };

          workerProvider.updateUser(userData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Color(0xFF1976D2),
          ),
        );
        
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _saveChanges,
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
                // Profile Photo Section
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

                // Full Name
                _buildTextField(
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

                // Mobile Number
                _buildTextField(
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

                // Address Details Section
                const Row(
                  children: [
                    Icon(Icons.location_on, color: Color(0xFF1976D2), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Address Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Pincode
                _buildTextField(
                  controller: _pincodeController,
                  label: 'Pincode',
                  icon: Icons.pin_drop,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 16),

                // City
                _buildTextField(
                  controller: _cityController,
                  label: 'City',
                  icon: Icons.location_city,
                ),

                const SizedBox(height: 16),

                // Locality/Area
                _buildTextField(
                  controller: _localityController,
                  label: 'Locality/Area',
                  icon: Icons.home_work,
                ),

                const SizedBox(height: 16),

                // Landmark (Optional)
                _buildTextField(
                  controller: _landmarkController,
                  label: 'Landmark (Optional)',
                  icon: Icons.place,
                  required: false,
                ),

                const SizedBox(height: 16),

                // State
                _buildTextField(
                  controller: _stateController,
                  label: 'State',
                  icon: Icons.map,
                ),

                const SizedBox(height: 16),

                // Country
                _buildTextField(
                  controller: _countryController,
                  label: 'Country',
                  icon: Icons.public,
                  enabled: false,
                ),

                const SizedBox(height: 32),

                // Save Changes Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
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
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool required = true,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      style: const TextStyle(
        color: Colors.black, // Black text for input
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey.shade700,
        ),
        prefixIcon: Icon(
          icon,
          size: 20,
          color: const Color(0xFF1976D2),
        ),
        filled: true,
        fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: required ? validator : null,
    );
  }
}