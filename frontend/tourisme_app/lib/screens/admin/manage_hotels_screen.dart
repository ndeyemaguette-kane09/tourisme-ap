import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/hotel_service.dart';
import '../../widgets/admin_kit.dart';
import 'hotel_form_screen.dart';

class ManageHotelsScreen extends StatelessWidget {
  final String token;

  const ManageHotelsScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return AdminListPage(
      title: "Hôtels",
      icon: Icons.hotel_rounded,
      onAdd: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HotelFormScreen(token: token)),
      ),
      load: (refresh) async {
        final hotels = await HotelService().getHotels(token);
        return hotels
            .map((h) => AdminRow(
                  title: h.name,
                  subtitle: "${h.city} · ${h.price.toStringAsFixed(0)} FCFA / nuit",
                  imageUrl: h.imageUrl,
                  hasGps: h.latitude != 0 && h.longitude != 0,
                  onEdit: () async {
                    final changed = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => HotelFormScreen(token: token, hotel: h)),
                    );
                    if (changed == true) refresh();
                  },
                  onDelete: () => ApiService.deleteHotel(token, h.id),
                ))
            .toList();
      },
    );
  }
}
