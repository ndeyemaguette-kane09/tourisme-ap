class Review {
  final String username;
  final double rating;
  final String comment;

  Review({
    required this.username,
    required this.rating,
    required this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      username: json['username'],
      rating: json['rating'],
      comment: json['comment'],
    );
  }
}