import 'package:flutter/material.dart';
import 'add_hotel_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  final String token;
  const AdminDashboardScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Administration"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _adminButton(
              context,
              "Ajouter un hôtel",
              Icons.hotel,
              AddHotelScreen(token: token),
            ),
            _adminButton(
              context,
              "Ajouter un restaurant",
              Icons.restaurant,
              const Placeholder(),
            ),
            _adminButton(
              context,
              "Ajouter une plage",
              Icons.beach_access,
              const Placeholder(),
            ),
            _adminButton(
              context,
              "Gérer les hôtels",
              Icons.settings,
              const Placeholder(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _adminButton(
      BuildContext context,
      String title,
      IconData icon,
      Widget screen,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton.icon(
          icon: Icon(icon),
          label: Text(title),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screen),
            );
          },
        ),
      ),
    );
  }
}