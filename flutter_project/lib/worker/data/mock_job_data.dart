import '../models/job.dart';

class MockJobData {
  static List<Job> getTodayJobs() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      Job(
        id: 'J001',
        title: 'AC Repair',
        customerName: 'Rajesh Kumar',
        address: '123 MG Road, Bangalore',
        scheduledTime: today.add(const Duration(hours: 9)),
        duration: '2 hours',
        status: 'Upcoming',
        amount: 1500,
        description: 'AC not cooling properly. Need to check gas level and filters.',
      ),
      Job(
        id: 'J002',
        title: 'Plumbing Service',
        customerName: 'Priya Sharma',
        address: '456 Residency Road, Bangalore',
        scheduledTime: today.add(const Duration(hours: 14)),
        duration: '1.5 hours',
        status: 'Upcoming',
        amount: 800,
        description: 'Kitchen sink leaking. Need to replace pipes.',
      ),
      Job(
        id: 'J003',
        title: 'Electrical Work',
        customerName: 'Amit Patel',
        address: '789 Indiranagar, Bangalore',
        scheduledTime: today.add(const Duration(hours: 16, minutes: 30)),
        duration: '1 hour',
        status: 'Upcoming',
        amount: 600,
        description: 'Install new ceiling fan and fix switches.',
      ),
    ];
  }

  static List<Job> getWeekJobs() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      ...getTodayJobs(),
      Job(
        id: 'J004',
        title: 'Painting Service',
        customerName: 'Sneha Reddy',
        address: '101 Koramangala, Bangalore',
        scheduledTime: today.add(const Duration(days: 1, hours: 10)),
        duration: '4 hours',
        status: 'Scheduled',
        amount: 3500,
        description: 'Paint bedroom walls - 2 coats required.',
      ),
      Job(
        id: 'J005',
        title: 'Washing Machine Repair',
        customerName: 'Vikram Singh',
        address: '202 Whitefield, Bangalore',
        scheduledTime: today.add(const Duration(days: 2, hours: 11)),
        duration: '1.5 hours',
        status: 'Scheduled',
        amount: 1200,
        description: 'Machine not spinning. Check motor and belt.',
      ),
      Job(
        id: 'J006',
        title: 'Carpenter Work',
        customerName: 'Lakshmi Iyer',
        address: '303 Jayanagar, Bangalore',
        scheduledTime: today.add(const Duration(days: 3, hours: 9)),
        duration: '3 hours',
        status: 'Scheduled',
        amount: 2500,
        description: 'Repair wardrobe doors and install new handles.',
      ),
      Job(
        id: 'J007',
        title: 'Chimney Cleaning',
        customerName: 'Arjun Mehta',
        address: '404 HSR Layout, Bangalore',
        scheduledTime: today.add(const Duration(days: 4, hours: 15)),
        duration: '1 hour',
        status: 'Scheduled',
        amount: 800,
        description: 'Deep cleaning of kitchen chimney.',
      ),
      Job(
        id: 'J008',
        title: 'Geyser Installation',
        customerName: 'Deepa Rao',
        address: '505 BTM Layout, Bangalore',
        scheduledTime: today.add(const Duration(days: 5, hours: 10)),
        duration: '2 hours',
        status: 'Scheduled',
        amount: 1800,
        description: 'Install new geyser and connect pipes.',
      ),
    ];
  }

  static List<Job> getMonthJobs() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      ...getWeekJobs(),
      Job(
        id: 'J009',
        title: 'Deep Cleaning',
        customerName: 'Ravi Gupta',
        address: '606 Electronic City, Bangalore',
        scheduledTime: today.add(const Duration(days: 8, hours: 9)),
        duration: '5 hours',
        status: 'Scheduled',
        amount: 4000,
        description: 'Complete house deep cleaning including kitchen and bathrooms.',
      ),
      Job(
        id: 'J010',
        title: 'TV Wall Mount',
        customerName: 'Kavita Nair',
        address: '707 Marathahalli, Bangalore',
        scheduledTime: today.add(const Duration(days: 10, hours: 14)),
        duration: '1 hour',
        status: 'Scheduled',
        amount: 500,
        description: 'Mount 55-inch TV on living room wall.',
      ),
      Job(
        id: 'J011',
        title: 'Sofa Cleaning',
        customerName: 'Manoj Joshi',
        address: '808 Bellandur, Bangalore',
        scheduledTime: today.add(const Duration(days: 12, hours: 11)),
        duration: '2 hours',
        status: 'Scheduled',
        amount: 1500,
        description: 'Steam cleaning of 3-seater sofa and 2 armchairs.',
      ),
      Job(
        id: 'J012',
        title: 'RO Service',
        customerName: 'Sunita Desai',
        address: '909 Sarjapur Road, Bangalore',
        scheduledTime: today.add(const Duration(days: 15, hours: 10)),
        duration: '1 hour',
        status: 'Scheduled',
        amount: 600,
        description: 'RO water purifier maintenance and filter change.',
      ),
      Job(
        id: 'J013',
        title: 'Pest Control',
        customerName: 'Karthik Bhat',
        address: '1010 JP Nagar, Bangalore',
        scheduledTime: today.add(const Duration(days: 18, hours: 16)),
        duration: '3 hours',
        status: 'Scheduled',
        amount: 2800,
        description: 'Complete house pest control treatment.',
      ),
      Job(
        id: 'J014',
        title: 'Microwave Repair',
        customerName: 'Anita Roy',
        address: '1111 Rajajinagar, Bangalore',
        scheduledTime: today.add(const Duration(days: 20, hours: 13)),
        duration: '1.5 hours',
        status: 'Scheduled',
        amount: 900,
        description: 'Microwave not heating. Check magnetron.',
      ),
      Job(
        id: 'J015',
        title: 'Curtain Installation',
        customerName: 'Suresh Kamath',
        address: '1212 Malleshwaram, Bangalore',
        scheduledTime: today.add(const Duration(days: 25, hours: 11)),
        duration: '2 hours',
        status: 'Scheduled',
        amount: 1200,
        description: 'Install curtain rods and hang curtains in 3 rooms.',
      ),
    ];
  }
}