import '../models/user.dart';
import '../models/user_location.dart';
import '../models/worker.dart';
import '../models/service_category.dart';
import '../models/service.dart';
import '../models/worker_service.dart';
import '../models/booking.dart';
import '../models/payment.dart';
import '../models/review.dart';
import '../models/wallet_transaction.dart';

/// Mock Database - In-memory storage for development
/// Replace with real API calls when backend is ready
/// Note: This is kept for reference only. All actual operations should use REST API
class MockDatabase {
  // ============================================================================
  // MOCK DATA STORAGE (Schema-aligned with backend)
  // ============================================================================
  
  static List<User> users = [
    User(
      id: 1,
      name: 'John Doe',
      email: 'john@example.com',
      phone: '9876543210',
      passwordHash: 'hashed_password_123',
      role: 'USER', // Changed from UserRole.customer to match DB schema
    ),
    User(
      id: 2,
      name: 'Jane Worker',
      email: 'jane@example.com',
      phone: '9876543211',
      passwordHash: 'hashed_password_456',
      role: 'WORKER', // Changed from UserRole.worker to match DB schema
    ),
  ];

  static List<UserLocation> userLocations = [
    UserLocation(
      id: 1,
      userId: 1,
      latitude: 28.6139,  // Delhi coordinates
      longitude: 77.2090,
      address: 'Connaught Place, New Delhi, Delhi 110001',
    ),
  ];

  static List<Worker> workers = [
    Worker(
      id: 1,
      userId: 2,
      isVerified: true,
      isAvailable: true,
      experienceYears: 5,
      bio: 'Experienced plumber with 5 years of expertise in residential and commercial plumbing.',
      profilePhoto: null,
    ),
    Worker(
      id: 2,
      userId: 3,
      isVerified: true,
      isAvailable: true,
      experienceYears: 7,
      bio: 'Professional electrician specializing in home wiring and electrical repairs.',
      profilePhoto: null,
    ),
  ];

  static List<ServiceCategory> categories = [
    ServiceCategory(id: 1, categoryName: 'Plumbing', iconName: 'plumbing'),
    ServiceCategory(id: 2, categoryName: 'Electrical', iconName: 'electrical'),
    ServiceCategory(id: 3, categoryName: 'Cleaning', iconName: 'cleaning'),
    ServiceCategory(id: 4, categoryName: 'Carpentry', iconName: 'carpentry'),
    ServiceCategory(id: 5, categoryName: 'Painting', iconName: 'painting'),
    ServiceCategory(id: 6, categoryName: 'AC Repair', iconName: 'ac_repair'),
    ServiceCategory(id: 7, categoryName: 'Pest Control', iconName: 'pest_control'),
    ServiceCategory(id: 8, categoryName: 'Appliance Repair', iconName: 'appliance'),
  ];

  static List<Service> services = [
    Service(id: 1, categoryId: 1, serviceName: 'Pipe Repair', basePrice: 500.0),
    Service(id: 2, categoryId: 1, serviceName: 'Tap Installation', basePrice: 300.0),
    Service(id: 3, categoryId: 2, serviceName: 'Wiring', basePrice: 800.0),
    Service(id: 4, categoryId: 2, serviceName: 'Switch Repair', basePrice: 200.0),
    Service(id: 5, categoryId: 3, serviceName: 'House Cleaning', basePrice: 1000.0),
  ];

  static List<WorkerService> workerServices = [
    WorkerService(id: 1, workerId: 1, serviceId: 1, priceOverride: null),
    WorkerService(id: 2, workerId: 1, serviceId: 2, priceOverride: null),
    WorkerService(id: 3, workerId: 2, serviceId: 3, priceOverride: null),
    WorkerService(id: 4, workerId: 2, serviceId: 4, priceOverride: null),
  ];

  static List<Booking> bookings = [];

  static List<Payment> payments = [];

  static List<Review> reviews = [];

  static List<WalletTransaction> walletTransactions = [
    WalletTransaction(
      id: 1,
      userId: 1,
      amount: 1000.0,
      type: 'credit',
      description: 'Welcome bonus',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  // ============================================================================
  // HELPER METHODS - ID GENERATION
  // ============================================================================
  
  static int generateId(List list) {
    if (list.isEmpty) return 1;
    // Find max ID in the list
    int maxId = 0;
    for (var item in list) {
      int? itemId;
      if (item is User) itemId = item.id;
      else if (item is Worker) itemId = item.id;
      else if (item is Booking) itemId = item.id;
      else if (item is Payment) itemId = item.id;
      else if (item is Review) itemId = item.id;
      else if (item is WalletTransaction) itemId = item.id;
      else if (item is ServiceCategory) itemId = item.id;
      else if (item is Service) itemId = item.id;
      else if (item is WorkerService) itemId = item.id;
      else if (item is UserLocation) itemId = item.id;
      
      if (itemId != null && itemId > maxId) {
        maxId = itemId;
      }
    }
    return maxId + 1;
  }

  // ============================================================================
  // USER METHODS
  // ============================================================================
  
  static void addUser(User user) {
    users.add(user);
  }

  static void removeUser(int userId) {
    users.removeWhere((u) => u.id == userId);
    userLocations.removeWhere((ul) => ul.userId == userId);
  }

  static User? getUserById(int id) {
    try {
      return users.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }

  static User? getUserByEmail(String email) {
    try {
      return users.firstWhere((u) => u.email == email);
    } catch (e) {
      return null;
    }
  }

  static User? getUserByPhone(String phone) {
    try {
      return users.firstWhere((u) => u.phone == phone);
    } catch (e) {
      return null;
    }
  }

  static void updateUser(User user) {
    final index = users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      users[index] = user;
    }
  }

  // ============================================================================
  // WORKER METHODS
  // ============================================================================
  
  static void addWorker(Worker worker) {
    workers.add(worker);
  }

  static void removeWorker(int workerId) {
    workers.removeWhere((w) => w.id == workerId);
  }

  static Worker? getWorkerById(int id) {
    try {
      return workers.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  static Worker? getWorkerByUserId(int userId) {
    try {
      return workers.firstWhere((w) => w.userId == userId);
    } catch (e) {
      return null;
    }
  }

  static List<Worker> getAvailableWorkers() {
    return workers.where((w) => w.isAvailable && w.isVerified).toList();
  }

  static void updateWorker(Worker worker) {
    final index = workers.indexWhere((w) => w.id == worker.id);
    if (index != -1) {
      workers[index] = worker;
    }
  }

  // ============================================================================
  // BOOKING METHODS
  // ============================================================================
  
  static void addBooking(Booking booking) {
    bookings.add(booking);
  }

  static void removeBooking(int bookingId) {
    bookings.removeWhere((b) => b.id == bookingId);
  }

  static Booking? getBookingById(int id) {
    try {
      return bookings.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Booking> getBookingsByUserId(int userId) {
    return bookings.where((b) => b.userId == userId).toList();
  }

  static List<Booking> getBookingsByWorkerId(int workerId) {
    return bookings.where((b) => b.workerId == workerId).toList();
  }

  static void updateBooking(Booking booking) {
    final index = bookings.indexWhere((b) => b.id == booking.id);
    if (index != -1) {
      bookings[index] = booking;
    }
  }

  // ============================================================================
  // SERVICE METHODS
  // ============================================================================
  
  static Service? getServiceById(int id) {
    try {
      return services.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Service> getServicesByCategoryId(int categoryId) {
    return services.where((s) => s.categoryId == categoryId).toList();
  }

  static ServiceCategory? getCategoryById(int id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // ============================================================================
  // REVIEW METHODS
  // ============================================================================
  
  static void addReview(Review review) {
    reviews.add(review);
  }

  static List<Review> getReviewsByUserId(int userId) {
    return reviews.where((r) => r.userId == userId).toList();
  }

  static List<Review> getReviewsByWorkerId(int workerId) {
    return reviews.where((r) => r.workerId == workerId).toList();
  }

  static double getWorkerAverageRating(int workerId) {
    final workerReviews = getReviewsByWorkerId(workerId);
    if (workerReviews.isEmpty) return 0.0;
    
    final sum = workerReviews.fold<int>(0, (sum, review) => sum + review.rating);
    return sum / workerReviews.length;
  }

  // ============================================================================
  // WALLET METHODS
  // ============================================================================
  
  static void addWalletTransaction(WalletTransaction transaction) {
    walletTransactions.add(transaction);
  }

  static List<WalletTransaction> getWalletTransactionsByUserId(int userId) {
    return walletTransactions.where((t) => t.userId == userId).toList();
  }

  static double getUserWalletBalance(int userId) {
    final transactions = getWalletTransactionsByUserId(userId);
    double balance = 0.0;
    
    for (var transaction in transactions) {
      if (transaction.type == 'credit' || transaction.type == 'refund') {
        balance += transaction.amount;
      } else if (transaction.type == 'debit') {
        balance -= transaction.amount;
      }
    }
    
    return balance;
  }

  // ============================================================================
  // PAYMENT METHODS
  // ============================================================================
  
  static void addPayment(Payment payment) {
    payments.add(payment);
  }

  static Payment? getPaymentByBookingId(int bookingId) {
    try {
      return payments.firstWhere((p) => p.bookingId == bookingId);
    } catch (e) {
      return null;
    }
  }

  static void updatePayment(Payment payment) {
    final index = payments.indexWhere((p) => p.id == payment.id);
    if (index != -1) {
      payments[index] = payment;
    }
  }

  // ============================================================================
  // LOCATION METHODS
  // ============================================================================
  
  static UserLocation? getUserLocation(int userId) {
    try {
      return userLocations.firstWhere((ul) => ul.userId == userId);
    } catch (e) {
      return null;
    }
  }

  static void addOrUpdateUserLocation(UserLocation location) {
    final index = userLocations.indexWhere((ul) => ul.userId == location.userId);
    if (index != -1) {
      userLocations[index] = location;
    } else {
      userLocations.add(location);
    }
  }

  static void removeUserLocation(int userId) {
    userLocations.removeWhere((ul) => ul.userId == userId);
  }
}