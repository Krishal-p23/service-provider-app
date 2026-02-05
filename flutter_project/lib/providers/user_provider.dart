import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter_project/models/user.dart';
import 'package:flutter_project/models/service_booking.dart';
import 'package:flutter_project/models/review.dart';
=======
import '../models/user.dart';
import '../models/user_role.dart';
import '../models/service_booking.dart';
import '../models/review.dart';
>>>>>>> kajal

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  final List<ServiceBooking> _bookingHistory = [];
  final List<Review> _userReviews = [];
<<<<<<< HEAD
  final Map<String, User> _registeredUsers = {}; // Simulated user database
=======
  final List<User> _registeredUsers = []; // In-memory only - clears on app restart

  // Dummy users for demonstration (hardcoded)
  static final List<User> _dummyUsers = [
    User(
      name: 'Demo User',
      email: 'user@demo.com',
      mobile: '9876543210',
      password: 'demo123',
      address: '123 Main Street, Mumbai',
      role: UserRole.customer,
    ),
    User(
      name: 'Test Customer',
      email: 'customer@test.com',
      mobile: '9876543211',
      password: 'test123',
      address: '456 Park Avenue, Delhi',
      role: UserRole.customer,
    ),
    User(
      name: 'Sample User',
      email: 'sample@user.com',
      mobile: '9876543212',
      password: 'sample123',
      address: '789 Lake Road, Bangalore',
      role: UserRole.customer,
    ),
  ];
>>>>>>> kajal

  User? get currentUser => _currentUser;
  List<ServiceBooking> get bookingHistory => List.unmodifiable(_bookingHistory);
  List<Review> get userReviews => List.unmodifiable(_userReviews);
  bool get isLoggedIn => _currentUser != null;
<<<<<<< HEAD
=======
  UserRole? get userRole => _currentUser?.role;
>>>>>>> kajal

  String get displayAddress {
    if (_currentUser == null) {
      return 'Login to select address';
    }
    return _currentUser!.address;
  }

<<<<<<< HEAD
  // Register new user
  bool register(User user) {
    // Check if user already exists
    if (_registeredUsers.containsKey(user.email)) {
      return false; // User already exists
    }
    
    _registeredUsers[user.email] = user;
=======
  // Register new user (in-memory only, clears on restart)
  Future<bool> register(User user) async {
    // Check if user already exists in dummy data
    if (_dummyUsers.any((u) => u.email == user.email || u.mobile == user.mobile)) {
      return false; // User already exists in dummy data
    }

    // Check if user already exists in registered users
    if (_registeredUsers.any((u) => u.email == user.email || u.mobile == user.mobile)) {
      return false; // User already exists
    }
    
    // Add to in-memory list (will be cleared on app restart)
    _registeredUsers.add(user);
    
>>>>>>> kajal
    _currentUser = user;
    _loadMockData();
    notifyListeners();
    return true;
  }

<<<<<<< HEAD
  // Login existing user
  bool login(String emailOrMobile, String password) {
    // Try to find user by email or mobile
    User? foundUser;
    
    for (var user in _registeredUsers.values) {
      if ((user.email == emailOrMobile || user.mobile == emailOrMobile) &&
          user.password == password) {
        foundUser = user;
        break;
      }
    }

    if (foundUser != null) {
      _currentUser = foundUser;
      _loadMockData();
      notifyListeners();
      return true;
=======
  // Login existing user (checks both dummy and registered users)
  Future<bool> login(String emailOrMobile, String password, {UserRole? role}) async {
    // First check dummy users
    for (var user in _dummyUsers) {
      if ((user.email == emailOrMobile || user.mobile == emailOrMobile) &&
          user.password == password) {
        // Check role if specified
        if (role != null && user.role != role) {
          continue;
        }
        _currentUser = user;
        _loadMockData();
        notifyListeners();
        return true;
      }
    }

    // Then check registered users
    for (var user in _registeredUsers) {
      if ((user.email == emailOrMobile || user.mobile == emailOrMobile) &&
          user.password == password) {
        // Check role if specified
        if (role != null && user.role != role) {
          continue;
        }
        _currentUser = user;
        _loadMockData();
        notifyListeners();
        return true;
      }
>>>>>>> kajal
    }
    
    return false;
  }

<<<<<<< HEAD
  void logout() {
=======
  Future<void> logout() async {
>>>>>>> kajal
    _currentUser = null;
    _bookingHistory.clear();
    _userReviews.clear();
    notifyListeners();
  }

  void updateUser(User user) {
    if (_currentUser != null) {
<<<<<<< HEAD
      // Update in registered users map
      _registeredUsers[_currentUser!.email] = user;
=======
      // Update in registered users list
      final index = _registeredUsers.indexWhere((u) => u.email == _currentUser!.email);
      if (index != -1) {
        _registeredUsers[index] = user;
      }
>>>>>>> kajal
      _currentUser = user;
      notifyListeners();
    }
  }

  void updateProfilePicture(String? imagePath) {
    if (_currentUser != null) {
      final updatedUser = _currentUser!.copyWith(profilePicture: imagePath);
      updateUser(updatedUser);
    }
  }

<<<<<<< HEAD
=======
  // Check if user exists by email or mobile (checks both dummy and registered)
  bool userExists(String emailOrMobile) {
    // Check dummy users
    if (_dummyUsers.any((user) => user.email == emailOrMobile || user.mobile == emailOrMobile)) {
      return true;
    }
    // Check registered users
    return _registeredUsers.any(
      (user) => user.email == emailOrMobile || user.mobile == emailOrMobile,
    );
  }

>>>>>>> kajal
  void _loadMockData() {
    _loadMockBookings();
    _loadMockReviews();
  }

  void _loadMockBookings() {
    _bookingHistory.clear();
    _bookingHistory.addAll([
      ServiceBooking(
        id: '1',
        serviceName: 'AC Repair & Service',
        providerName: 'Rajesh Kumar',
        providerProfilePicture: '',
        rating: 4.8,
        category: 'AC Repair',
        date: '2024-01-15',
        status: 'Completed',
        price: '₹599',
      ),
      ServiceBooking(
        id: '2',
        serviceName: 'Plumbing Work',
        providerName: 'Amit Singh',
        providerProfilePicture: '',
        rating: 4.5,
        category: 'Plumbing',
        date: '2024-01-10',
        status: 'Completed',
        price: '₹349',
      ),
      ServiceBooking(
        id: '3',
        serviceName: 'Electrical Repair',
        providerName: 'Suresh Patel',
        providerProfilePicture: '',
        rating: 4.7,
        category: 'Electrician',
        date: '2024-01-05',
        status: 'Completed',
        price: '₹299',
      ),
      ServiceBooking(
        id: '4',
        serviceName: 'Home Cleaning',
        providerName: 'Priya Sharma',
        providerProfilePicture: '',
        rating: 4.9,
        category: 'Cleaning',
        date: '2023-12-28',
        status: 'Completed',
        price: '₹499',
      ),
      ServiceBooking(
        id: '5',
        serviceName: 'Carpenter Work',
        providerName: 'Vikram Reddy',
        providerProfilePicture: '',
        rating: 4.6,
        category: 'Carpenter',
        date: '2023-12-20',
        status: 'Completed',
        price: '₹799',
      ),
      ServiceBooking(
        id: '6',
        serviceName: 'Pest Control Service',
        providerName: 'Mohan Verma',
        providerProfilePicture: '',
        rating: 4.4,
        category: 'Pest Control',
        date: '2023-12-15',
        status: 'Completed',
        price: '₹899',
      ),
      ServiceBooking(
        id: '7',
        serviceName: 'Washing Machine Repair',
        providerName: 'Anil Gupta',
        providerProfilePicture: '',
        rating: 4.7,
        category: 'Appliance Repair',
        date: '2023-12-10',
        status: 'Completed',
        price: '₹449',
      ),
      ServiceBooking(
        id: '8',
        serviceName: 'Painting Work',
        providerName: 'Ramesh Joshi',
        providerProfilePicture: '',
        rating: 4.5,
        category: 'Painting',
        date: '2023-12-01',
        status: 'Completed',
        price: '₹1,299',
      ),
    ]);
    notifyListeners();
  }

  void _loadMockReviews() {
    _userReviews.clear();
    _userReviews.addAll([
      Review(
        id: '1',
        providerName: 'Rajesh Kumar',
        providerProfilePicture: '',
        rating: 4.8,
        reviewText: 'Excellent service! Very professional and fixed my AC quickly. Highly recommended.',
        category: 'AC Repair',
        date: '2024-01-15',
      ),
      Review(
        id: '2',
        providerName: 'Amit Singh',
        providerProfilePicture: '',
        rating: 4.5,
        reviewText: 'Good work. Arrived on time and completed the plumbing work efficiently.',
        category: 'Plumbing',
        date: '2024-01-10',
      ),
      Review(
        id: '3',
        providerName: 'Suresh Patel',
        providerProfilePicture: '',
        rating: 4.7,
        reviewText: 'Great electrician! Fixed all the wiring issues. Very knowledgeable.',
        category: 'Electrician',
        date: '2024-01-05',
      ),
      Review(
        id: '4',
        providerName: 'Priya Sharma',
        providerProfilePicture: '',
        rating: 4.9,
        reviewText: 'Outstanding cleaning service! My home looks brand new. Will book again.',
        category: 'Cleaning',
        date: '2023-12-28',
      ),
      Review(
        id: '5',
        providerName: 'Vikram Reddy',
        providerProfilePicture: '',
        rating: 4.6,
        reviewText: 'Skilled carpenter. Made custom furniture exactly as I wanted. Happy with the work.',
        category: 'Carpenter',
        date: '2023-12-20',
      ),
    ]);
    notifyListeners();
  }

  List<ServiceBooking> getFilteredBookings({
    String? category,
    double? minRating,
    String? sortBy,
  }) {
    var filtered = List<ServiceBooking>.from(_bookingHistory);

    if (category != null && category != 'All') {
      filtered = filtered.where((b) => b.category == category).toList();
    }

    if (minRating != null) {
      filtered = filtered.where((b) => b.rating >= minRating).toList();
    }

    if (sortBy == 'Recent') {
      filtered.sort((a, b) => b.date.compareTo(a.date));
    } else if (sortBy == 'Old') {
      filtered.sort((a, b) => a.date.compareTo(b.date));
    } else if (sortBy == 'Rating') {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return filtered;
  }
}