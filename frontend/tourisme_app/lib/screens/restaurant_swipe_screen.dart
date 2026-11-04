import 'package:flutter/material.dart';
import '../services/restaurant_service.dart';
import '../widgets/swipe_deck.dart';
import 'restaurant_details_screen.dart';

class RestaurantSwipeScreen extends StatelessWidget {
  final String token;
  final int userId;

  const RestaurantSwipeScreen({super.key, required this.token, required this.userId});

  @override
  Widget build(BuildContext context) {
    return SwipeDeck(
      title: "Restaurants",
      subtitle: "Glisse à droite pour garder une adresse sous le coude.",
      icon: Icons.restaurant_rounded,
      load: () async {
        final restaurants = await RestaurantService().getRestaurants(token);
        return restaurants
            .map((r) => SwipeEntry(
                  id: r.id,
                  type: "restaurant",
                  name: r.name,
                  imageUrl: r.imageUrl,
                  location: r.city,
                  rating: r.rating,
                  onOpen: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RestaurantDetailsScreen(restaurant: r)),
                  ),
                ))
            .toList();
      },
    );
  }
}
