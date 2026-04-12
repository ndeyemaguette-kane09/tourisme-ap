import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AddHotelScreen extends StatefulWidget {
  final String token;
  const AddHotelScreen({super.key, required this.token});

  @override
  State<AddHotelScreen> createState() => _AddHotelScreenState();
}

class _AddHotelScreenState extends State<AddHotelScreen> {
  final nameController = TextEditingController();
  final cityController = TextEditingController();
  final priceController = TextEditingController();
  final ratingController = TextEditingController();
  final imageController = TextEditingController();
  final descriptionController = TextEditingController();

  void addHotel() async {
    await ApiService.addHotel(widget.token, {
      "name": nameController.text,
      "city": cityController.text,
      "price": double.parse(priceController.text),
      "rating": double.parse(ratingController.text),
      "imageUrl": imageController.text,
      "description": descriptionController.text,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter Hôtel")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _input(nameController, "Nom"),
            _input(cityController, "Ville"),
            _input(priceController, "Prix"),
            _input(ratingController, "Note"),
            _input(imageController, "Image URL"),
            _input(descriptionController, "Description"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addHotel,
              child: const Text("Ajouter"),
            )
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}