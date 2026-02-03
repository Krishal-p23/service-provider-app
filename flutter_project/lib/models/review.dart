class Review {
  final String id;
  final String providerName;
  final String providerProfilePicture;
  final double rating;
  final String reviewText;
  final String category;
  final String date;

  Review({
    required this.id,
    required this.providerName,
    required this.providerProfilePicture,
    required this.rating,
    required this.reviewText,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'providerName': providerName,
      'providerProfilePicture': providerProfilePicture,
      'rating': rating,
      'reviewText': reviewText,
      'category': category,
      'date': date,
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      providerName: json['providerName'] ?? '',
      providerProfilePicture: json['providerProfilePicture'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewText: json['reviewText'] ?? '',
      category: json['category'] ?? '',
      date: json['date'] ?? '',
    );
  }
}