import 'package:flutter/material.dart';
import '../services/reservation_service.dart';

class MyReservationsScreen extends StatefulWidget {
  final int userId;
  final String token;

  const MyReservationsScreen({
    super.key,
    required this.userId,
    required this.token,
  });

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  List reservations = [];
  bool isLoading = true;

  final ReservationService reservationService = ReservationService();

  @override
  void initState() {
    super.initState();
    loadReservations();
  }

  void loadReservations() async {
    try {
      final data = await reservationService.getUserReservations(
        widget.userId,
        widget.token,
      );

      setState(() {
        reservations = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes réservations"),
        backgroundColor: Colors.orange,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reservations.isEmpty
              ? const Center(child: Text("Aucune réservation"))
              : ListView.builder(
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = reservations[index];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.hotel),
                        title: Text("Hôtel ID: ${reservation['hotelId']}"),
                        subtitle: Text(
                          "Du ${reservation['checkInDate']} "
                          "au ${reservation['checkOutDate']}\n"
                          "Status: ${reservation['status']}",
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}