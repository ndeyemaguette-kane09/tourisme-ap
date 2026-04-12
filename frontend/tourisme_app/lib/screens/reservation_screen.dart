import 'package:flutter/material.dart';
import '../services/reservation_service.dart';

class ReservationScreen extends StatefulWidget {
  final int hotelId;
  final int userId;
  final String token;

  const ReservationScreen({
    super.key,
    required this.hotelId,
    required this.userId,
    required this.token,
  });

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  DateTime? checkInDate;
  DateTime? checkOutDate;
  int guests = 1;
  String paymentMethod = "Carte";

  final ReservationService reservationService = ReservationService();

  Future<void> selectDate(bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          checkInDate = picked;
        } else {
          checkOutDate = picked;
        }
      });
    }
  }

  void confirmReservation() async {
    if (checkInDate == null || checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez choisir les dates")),
      );
      return;
    }

    try {
      await reservationService.createReservation(
        widget.userId,
        widget.hotelId,
        checkInDate!,
        checkOutDate!,
        guests,
        widget.token,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Réservation confirmée")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur réservation")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Réservation"),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Choisissez vos dates",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    checkInDate == null
                        ? "Date d'arrivée"
                        : checkInDate!.toLocal().toString().split(' ')[0],
                  ),
                  onTap: () => selectDate(true),
                ),
              ),

              const SizedBox(height: 10),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    checkOutDate == null
                        ? "Date de départ"
                        : checkOutDate!.toLocal().toString().split(' ')[0],
                  ),
                  onTap: () => selectDate(false),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Nombre de personnes",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: const Icon(Icons.people),
                  hintText: "Ex: 2",
                ),
                onChanged: (value) {
                  guests = int.parse(value);
                },
              ),

              const SizedBox(height: 25),

              const Text(
                "Moyen de paiement",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButton<String>(
                  value: paymentMethod,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: ["Carte", "Wave", "Orange Money", "Paiement sur place"]
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      paymentMethod = value!;
                    });
                  },
                ),
              ),

              const SizedBox(height: 40),

              Center(
                child: ElevatedButton(
                  onPressed: confirmReservation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Confirmer la réservation",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}