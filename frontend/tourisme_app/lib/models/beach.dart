class Beach {
  final int id;
  final String name;
  final String address;
  final String city;
  final String description;
  final double rating;
  final String imageUrl;
  final double latitude;
  final double longitude;

  Beach({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.description,
    required this.rating,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
  });

  factory Beach.fromJson(Map<String, dynamic> json) {
    return Beach(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      city: json['city'] ?? '',
      description: json['description'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }
}