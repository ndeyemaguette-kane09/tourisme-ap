import 'package:flutter/material.dart';
import '../models/beach.dart';
import '../models/hotel.dart';
import '../models/restaurant.dart';
import '../screens/beach_details_screen.dart';
import '../screens/hotel_details_screen.dart';
import '../screens/place_details_screen.dart';
import '../screens/restaurant_details_screen.dart';
import '../services/discover_service.dart';
import '../services/session.dart';

const typeLabels = {
  "hotel": "Hôtel",
  "restaurant": "Restaurant",
  "beach": "Plage",
  "place": "Lieu",
};

const typeIcons = {
  "hotel": Icons.hotel_rounded,
  "restaurant": Icons.restaurant_rounded,
  "beach": Icons.beach_access_rounded,
  "place": Icons.place_rounded,
};

Future<void> openItem(BuildContext context, Map<String, dynamic> item) async {
  final String type = item["type"];
  final int id = item["id"];

  try {
    final data = await DiscoverService.getItem(type, id);
    if (!context.mounted) return;

    final Widget screen;
    switch (type) {
      case "hotel":
        screen = HotelDetailsScreen(
          hotel: Hotel.fromJson(data),
          userId: Session.userId ?? 0,
          token: Session.token ?? "",
          userName: Session.userName ?? "",
        );
        break;
      case "restaurant":
        screen = RestaurantDetailsScreen(restaurant: Restaurant.fromJson(data));
        break;
      case "beach":
        screen = BeachDetailsScreen(beach: Beach.fromJson(data));
        break;
      default:
        screen = PlaceDetailsScreen(place: data);
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Impossible d'ouvrir ce lieu")),
    );
  }
}
