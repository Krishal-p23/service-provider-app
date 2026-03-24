class Job {
  final String id;
  final String title;
  final String customerName;
  final String address;
  final DateTime scheduledTime;
  final String duration;
  final String status;
  final double amount;
  final String description;

  Job({
    required this.id,
    required this.title,
    required this.customerName,
    required this.address,
    required this.scheduledTime,
    required this.duration,
    required this.status,
    required this.amount,
    required this.description,
  });
}