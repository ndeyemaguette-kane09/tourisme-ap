import 'package:flutter/material.dart';
import '../../models/hotel.dart';
import '../../services/api_service.dart';
import '../../services/hotel_service.dart';
import '../../widgets/admin_kit.dart';

class HotelFormScreen extends StatefulWidget {
  final String token;
  final Hotel? hotel;

  const HotelFormScreen({super.key, required this.token, this.hotel});

  @override
  State<HotelFormScreen> createState() => _HotelFormScreenState();
}

class _HotelFormScreenState extends State<HotelFormScreen> {
  late final name = TextEditingController(text: widget.hotel?.name);
  late final city = TextEditingController(text: widget.hotel?.city);
  late final address = TextEditingController(text: widget.hotel?.address);
  late final price = TextEditingController(text: numberText(widget.hotel?.price));
  late final rating = TextEditingController(text: numberText(widget.hotel?.rating));
  late final image = TextEditingController(text: widget.hotel?.imageUrl);
  late final description = TextEditingController(text: widget.hotel?.description);
  late final latitude = TextEditingController(text: numberText(widget.hotel?.latitude));
  late final longitude = TextEditingController(text: numberText(widget.hotel?.longitude));
  bool saving = false;

  bool get editing => widget.hotel != null;

  @override
  void dispose() {
    for (final c in [name, city, address, price, rating, image, description, latitude, longitude]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    if (name.text.trim().isEmpty || city.text.trim().isEmpty || parseNumber(price.text) == null) {
      showAdminMessage(context, "Le nom, la ville et le prix sont obligatoires");
      return;
    }
    final gpsError = checkGps(latitude.text, longitude.text);
    if (gpsError != null) {
      showAdminMessage(context, gpsError);
      return;
    }

    final data = {
      "name": name.text.trim(),
      "city": city.text.trim(),
      "cityName": city.text.trim(),
      "address": address.text.trim(),
      "price": parseNumber(price.text),
      "rating": parseNumber(rating.text) ?? 0,
      "imageUrl": image.text.trim(),
      "description": description.text.trim(),
      "latitude": parseNumber(latitude.text),
      "longitude": parseNumber(longitude.text),
    };

    setState(() => saving = true);
    try {
      if (editing) {
        await HotelService().updateHotel(widget.hotel!.id, data, widget.token);
      } else {
        await ApiService.addHotel(widget.token, data);
      }
      if (!mounted) return;
      showAdminMessage(context, editing ? "Hôtel modifié" : "Hôtel ajouté");
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() => saving = false);
      showAdminMessage(context, "Enregistrement impossible");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminFormPage(
      title: editing ? "Modifier l'hôtel" : "Nouvel hôtel",
      saving: saving,
      onSave: save,
      children: [
        AdminSection(title: "Infos", children: [
          AdminField(label: "Nom *", controller: name, hint: "Hôtel Terrou-Bi"),
          AdminField(label: "Ville *", controller: city, hint: "Dakar"),
          AdminField(label: "Adresse", controller: address),
          Row(children: [
            Expanded(child: AdminField(label: "Prix / nuit (FCFA) *", controller: price, number: true)),
            const SizedBox(width: 12),
            Expanded(child: AdminField(label: "Note /5", controller: rating, number: true)),
          ]),
        ]),
        AdminSection(title: "Présentation", children: [
          AdminField(label: "URL de la photo", controller: image, hint: "https://…"),
          AdminField(label: "Description", controller: description, maxLines: 4),
        ]),
        AdminSection(title: "Position", children: [
          GpsFields(latitude: latitude, longitude: longitude),
          const SizedBox(height: 12),
        ]),
      ],
    );
  }
}
