import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../screens/hotel_details_screen.dart';

class HotelSwipeCard extends StatelessWidget {
  final Hotel hotel;
  final int userId;
  final String token;

  const HotelSwipeCard({
    super.key,
    required this.hotel,
    required this.userId,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              hotel.imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  hotel.address,
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  "${hotel.price} FrCfa • ⭐ ${hotel.rating}",
                  style: const TextStyle(color: Colors.white),
                ),
                Align(
  alignment: Alignment.bottomRight,
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HotelDetailsScreen(
            hotel: hotel,
            userId: userId,
            token: token,
          ),
        ),
      );
    },
    child: const Text("Voir plus"),
  ),
),
              ],
            ),
          ),
        ],
      ),
    );
  }
}