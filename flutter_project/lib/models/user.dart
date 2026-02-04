import 'user_role.dart';

class User {
  final String name;
  final String email;
  final String mobile;
  final String password;
  final String address;
  final String? profilePicture;
  final UserRole role;

  User({
    required this.name,
    required this.email,
    required this.mobile,
    required this.password,
    required this.address,
    this.profilePicture,
    this.role = UserRole.customer,
  });

  User copyWith({
    String? name,
    String? email,
    String? mobile,
    String? password,
    String? address,
    String? profilePicture,
    UserRole? role,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      password: password ?? this.password,
      address: address ?? this.address,
      profilePicture: profilePicture ?? this.profilePicture,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'mobile': mobile,
      'password': password,
      'address': address,
      'profilePicture': profilePicture,
      'role': role.index,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      password: json['password'] ?? '',
      address: json['address'] ?? '',
      profilePicture: json['profilePicture'],
      role: UserRole.values[json['role'] ?? 0],
    );
  }
}


// class User {
//   final String name;
//   final String email;
//   final String mobile;
//   final String password;
//   final String address;
//   final String? profilePicture;

//   User({
//     required this.name,
//     required this.email,
//     required this.mobile,
//     required this.password,
//     required this.address,
//     this.profilePicture,
//   });

//   User copyWith({
//     String? name,
//     String? email,
//     String? mobile,
//     String? password,
//     String? address,
//     String? profilePicture,
//   }) {
//     return User(
//       name: name ?? this.name,
//       email: email ?? this.email,
//       mobile: mobile ?? this.mobile,
//       password: password ?? this.password,
//       address: address ?? this.address,
//       profilePicture: profilePicture ?? this.profilePicture,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'email': email,
//       'mobile': mobile,
//       'password': password,
//       'address': address,
//       'profilePicture': profilePicture,
//     };
//   }

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       name: json['name'] ?? '',
//       email: json['email'] ?? '',
//       mobile: json['mobile'] ?? '',
//       password: json['password'] ?? '',
//       address: json['address'] ?? '',
//       profilePicture: json['profilePicture'],
//     );
//   }
// }
