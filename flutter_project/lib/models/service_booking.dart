class ServiceBooking {
  final String id;
  final String serviceName;
  final String providerName;
  final String providerProfilePicture;
  final double rating;
  final String category;
  final String date;
  final String status;
  final String price;

  ServiceBooking({
    required this.id,
    required this.serviceName,
    required this.providerName,
    required this.providerProfilePicture,
    required this.rating,
    required this.category,
    required this.date,
    required this.status,
    required this.price,
  });
}
