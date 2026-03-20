class ServiceCategory {
  final int id;
  final String categoryName;
  final String? iconName;

  ServiceCategory({
    required this.id,
    required this.categoryName,
    this.iconName,
  });

  ServiceCategory copyWith({
    int? id,
    String? categoryName,
    String? iconName,
  }) {
    return ServiceCategory(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      iconName: iconName ?? this.iconName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_name': categoryName,
      'icon_name': iconName,
    };
  }

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] ?? 0,
      categoryName: json['category_name'] ?? '',
      iconName: json['icon_name'],
    );
  }

  @override
  String toString() => 'ServiceCategory(id: $id, categoryName: $categoryName)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
