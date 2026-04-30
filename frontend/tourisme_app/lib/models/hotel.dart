import 'dart:ffi';

class Hotel {
  final int id;
  final String name;
  final String address;
  final double price;
  final double rating;
  final String imageUrl;
  final String? description;
  final String city;
  final double latitude;
  final double longitude;

  Hotel({
    required this.id,
    required this.name,
    required this.address,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.city,
    this.description,
    required this.latitude,
    required this.longitude,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
  return Hotel(
    id: json['id'],
    name: json['name'] ?? '',
    address: json['address'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
rating: (json['rating'] ?? 0).toDouble(),
city: json['city'] ?? '',
    description: json['description'] ?? '',
    imageUrl: json['imageUrl'] ??
        "https://images.unsplash.com/photo-1566073771259-6a8506099945",
    latitude: (json['latitude'] ?? 0).toDouble(),
    longitude: (json['longitude'] ?? 0).toDouble(),
  );
}
}