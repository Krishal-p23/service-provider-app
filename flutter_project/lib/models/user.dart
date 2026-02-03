class User {
  final String name;
  final String email;
  final String mobile;
  final String password;
  final String address;
  final String? profilePicture;

  User({
    required this.name,
    required this.email,
    required this.mobile,
    required this.password,
    required this.address,
    this.profilePicture,
  });

  User copyWith({
    String? name,
    String? email,
    String? mobile,
    String? password,
    String? address,
    String? profilePicture,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      password: password ?? this.password,
      address: address ?? this.address,
      profilePicture: profilePicture ?? this.profilePicture,
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
    );
  }
}
