import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../widgets/detail_layout.dart';
import 'reservation_screen.dart';

class HotelDetailsScreen extends StatelessWidget {
  final Hotel hotel;
  final int userId;
  final String token;
  final String userName;

  const HotelDetailsScreen({
    super.key,
    required this.hotel,
    required this.userId,
    required this.token,
    required this.userName,
  });

  String _price() {
    final p = hotel.price.round().toString();
    final grouped = p.replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (_) => " ");
    return "$grouped FCFA";
  }

  @override
  Widget build(BuildContext context) {
    return DetailLayout(
      type: "hotel",
      id: hotel.id,
      name: hotel.name,
      imageUrl: hotel.imageUrl,
      tags: const ["Hôtel"],
      location: [hotel.address, hotel.city].where((e) => e.isNotEmpty).toSet().join(", "),
      rating: hotel.rating,
      description: hotel.description,
      infos: [
        DetailInfo(Icons.payments_outlined, "Par nuit", _price()),
        DetailInfo(Icons.location_city_outlined, "Ville", hotel.city.isEmpty ? "—" : hotel.city),
      ],
      actionLabel: "Réserver",
      actionIcon: Icons.event_available_rounded,
      onAction: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReservationScreen(hotelId: hotel.id, userId: userId, token: token),
        ),
      ),
    );
  }
}
