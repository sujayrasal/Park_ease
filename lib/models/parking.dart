class Parking {
  final String title;
  final String description;
  final double price;
  final bool available;
  final String userId;

  Parking({
    required this.title,
    required this.description,
    required this.price,
    required this.available,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'available': available,
      'userId': userId,
    };
  }

  factory Parking.fromMap(Map<String, dynamic> data) {
    return Parking(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      available: data['available'] ?? false,
      userId: data['userId'] ?? '',
    );
  }
}