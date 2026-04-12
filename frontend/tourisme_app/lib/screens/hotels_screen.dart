import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../services/hotel_service.dart';

class HotelsScreen extends StatefulWidget {
  final String token;

  HotelsScreen({required this.token});

  @override
  _HotelsScreenState createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> {
  final HotelService hotelService = HotelService();
  List<Hotel> hotels = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHotels();
  }

  void loadHotels() async {
    final data = await hotelService.getHotels(widget.token);
    setState(() {
      hotels = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hotels")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: hotels.length,
              itemBuilder: (context, index) {
                final hotel = hotels[index];
                return Card(
  margin: EdgeInsets.all(10),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // IMAGE HOTEL
      ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        child: Image.network(
          hotel.imageUrl,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),

      // INFOS HOTEL
      Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hotel.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(hotel.address),
            SizedBox(height: 5),
            Text(
              "${hotel.price} €",
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);
              },
            ),
    );
  }
}