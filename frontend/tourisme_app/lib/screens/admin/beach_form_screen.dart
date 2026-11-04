import 'package:flutter/material.dart';
import '../../models/beach.dart';
import '../../services/api_service.dart';
import '../../services/beach_service.dart';
import '../../widgets/admin_kit.dart';

class BeachFormScreen extends StatefulWidget {
  final String token;
  final Beach? beach;

  const BeachFormScreen({super.key, required this.token, this.beach});

  @override
  State<BeachFormScreen> createState() => _BeachFormScreenState();
}

class _BeachFormScreenState extends State<BeachFormScreen> {
  late final name = TextEditingController(text: widget.beach?.name);
  late final city = TextEditingController(text: widget.beach?.city);
  late final address = TextEditingController(text: widget.beach?.address);
  late final rating = TextEditingController(text: numberText(widget.beach?.rating));
  late final image = TextEditingController(text: widget.beach?.imageUrl);
  late final description = TextEditingController(text: widget.beach?.description);
  late final latitude = TextEditingController(text: numberText(widget.beach?.latitude));
  late final longitude = TextEditingController(text: numberText(widget.beach?.longitude));
  bool saving = false;

  bool get editing => widget.beach != null;

  @override
  void dispose() {
    for (final c in [name, city, address, rating, image, description, latitude, longitude]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    if (name.text.trim().isEmpty || city.text.trim().isEmpty) {
      showAdminMessage(context, "Le nom et la ville sont obligatoires");
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
      "address": address.text.trim(),
      "rating": parseNumber(rating.text) ?? 0,
      "imageUrl": image.text.trim(),
      "description": description.text.trim(),
      "latitude": parseNumber(latitude.text),
      "longitude": parseNumber(longitude.text),
    };

    setState(() => saving = true);
    try {
      if (editing) {
        await BeachService().updateBeach(widget.beach!.id, data, widget.token);
      } else {
        await ApiService.addBeach(widget.token, data);
      }
      if (!mounted) return;
      showAdminMessage(context, editing ? "Plage modifiée" : "Plage ajoutée");
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
      title: editing ? "Modifier la plage" : "Nouvelle plage",
      saving: saving,
      onSave: save,
      children: [
        AdminSection(title: "Infos", children: [
          AdminField(label: "Nom *", controller: name, hint: "Plage de Ngor"),
          AdminField(label: "Ville *", controller: city, hint: "Dakar"),
          AdminField(label: "Adresse", controller: address),
          AdminField(label: "Note /5", controller: rating, number: true),
        ]),
        AdminSection(title: "Présentation", children: [
          AdminField(label: "URL de la photo", controller: image, hint: "https://…"),
          AdminField(label: "Description", controller: description, maxLines: 4, maxLength: 255),
        ]),
        AdminSection(title: "Position", children: [
          GpsFields(latitude: latitude, longitude: longitude),
          const SizedBox(height: 12),
        ]),
      ],
    );
  }
}
