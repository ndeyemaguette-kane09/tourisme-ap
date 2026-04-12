class Hotel {
  final int id;
  final String name;
  final String address;
  final double price;
  final double rating;
  final String imageUrl;
  final String? description;

  Hotel({
    required this.id,
    required this.name,
    required this.address,
    required this.price,
    required this.rating,
    required this.imageUrl,
    this.description,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
  return Hotel(
    id: json['id'],
    name: json['name'] ?? '',
    address: json['address'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
rating: (json['rating'] ?? 0).toDouble(),
    description: json['description'] ?? '',
    imageUrl: json['imageUrl'] ??
        "https://images.unsplash.com/photo-1566073771259-6a8506099945",
  );
}
}