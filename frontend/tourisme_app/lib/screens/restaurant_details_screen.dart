import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../widgets/detail_layout.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantDetailsScreen({
    super.key,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    return DetailLayout(
      type: "restaurant",
      id: restaurant.id,
      name: restaurant.name,
      imageUrl: restaurant.imageUrl,
      tags: const ["Restaurant", "Gastronomie"],
      location: [restaurant.address, restaurant.city].where((e) => e.isNotEmpty).toSet().join(", "),
      rating: restaurant.rating,
      description: restaurant.description,
      infos: [
        DetailInfo(Icons.location_city_outlined, "Ville", restaurant.city.isEmpty ? "—" : restaurant.city),
      ],
    );
  }
}
