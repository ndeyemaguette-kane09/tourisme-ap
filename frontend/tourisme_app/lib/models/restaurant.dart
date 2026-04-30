class Restaurant {
  final int id;
  final String name;
  final String address;
  final double rating;
  final String imageUrl;
  final String? description;
  final String city;
  final double latitude;
  final double longitude;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.imageUrl,
    required this.city,
    this.description,
    required this.latitude,
    required this.longitude,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? 
          "https://images.unsplash.com/photo-1555992336-03a23c7b20ee",
      description: json['description'] ?? '',
      city: json['city'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }
}