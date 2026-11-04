import 'package:flutter/material.dart';
import '../services/discover_service.dart';
import '../services/hotel_service.dart';
import '../widgets/swipe_deck.dart';
import 'hotel_details_screen.dart';

class HotelSwipeScreen extends StatelessWidget {
  final String token;
  final int userId;
  final String userName;

  const HotelSwipeScreen({
    super.key,
    required this.token,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return SwipeDeck(
      title: "Hôtels",
      subtitle: "Glisse à droite pour garder, à gauche pour passer. Tes choix affinent tes recommandations.",
      icon: Icons.hotel_rounded,
      onSwipe: (entry, liked) => DiscoverService.likeHotel(entry.id, liked),
      load: () async {
        final hotels = await HotelService().getHotels(token);
        return hotels
            .map((h) => SwipeEntry(
                  id: h.id,
                  type: "hotel",
                  name: h.name,
                  imageUrl: h.imageUrl,
                  location: h.city,
                  rating: h.rating,
                  badge: "${h.price.toStringAsFixed(0)} FCFA / nuit",
                  onOpen: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HotelDetailsScreen(
                        hotel: h,
                        userId: userId,
                        token: token,
                        userName: userName,
                      ),
                    ),
                  ),
                ))
            .toList();
      },
    );
  }
}
