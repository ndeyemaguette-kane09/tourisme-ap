import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../services/reservation_service.dart';
import 'reservation_screen.dart';

class HotelDetailsScreen extends StatelessWidget {
  final Hotel hotel;
  final int userId;
  final String token;



const HotelDetailsScreen({
    super.key,
    required this.hotel,
    required this.userId,
    required this.token,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hotel.name),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // Image
            ClipRRect(
  borderRadius: BorderRadius.circular(20),
  child: Image.network(
    hotel.imageUrl,
    width: double.infinity,
    height: 250,
    fit: BoxFit.cover,
  ),
),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    hotel.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text("📍 ${hotel.address}"),

                  const SizedBox(height: 10),

                  Text("💰 Prix : ${hotel.price} FCFA"),

                  const SizedBox(height: 10),

                  Text("⭐ Note : ${hotel.rating}"),

                  const SizedBox(height: 20),

                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    hotel.description ?? "Pas de description disponible",
                  ),

                  const SizedBox(height: 30),

                  Center(
                    child: ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.orange,
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationScreen(
          hotelId: hotel.id,
          userId: userId,
          token: token,
        ),
      ),
    );
  },
  child: const Text(
    "Réserver",
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  ),
)
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}