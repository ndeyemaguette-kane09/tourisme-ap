import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../services/category_service.dart';
import '../../services/place_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/admin_kit.dart';

class PlaceFormScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic>? place;

  const PlaceFormScreen({super.key, required this.token, this.place});

  @override
  State<PlaceFormScreen> createState() => _PlaceFormScreenState();
}

class _PlaceFormScreenState extends State<PlaceFormScreen> {
  static const subTypes = [
    "Monument", "Musée", "Mosquée", "Église", "Lieu de pèlerinage", "Île",
    "Ville historique", "Marché", "Marché artisanal", "Parc national",
    "Réserve naturelle", "Réserve animalière", "Lac", "Cascade", "Désert",
  ];

  Map<String, dynamic> get p => widget.place ?? const {};

  late final name = TextEditingController(text: p["name"]);
  late final subType = TextEditingController(text: p["subType"]);
  late final city = TextEditingController(text: p["city"]);
  late final region = TextEditingController(text: p["region"]);
  late final address = TextEditingController(text: p["address"]);
  late final image = TextEditingController(text: p["imageUrl"]);
  late final description = TextEditingController(text: p["description"]);
  late final duration = TextEditingController(text: numberText((p["visitDuration"] as num?)?.toDouble()));
  late final entry = TextEditingController(text: numberText((p["entryPrice"] as num?)?.toDouble()));
  late final latitude = TextEditingController(text: numberText((p["latitude"] as num?)?.toDouble()));
  late final longitude = TextEditingController(text: numberText((p["longitude"] as num?)?.toDouble()));

  List<Category> categories = [];
  int? categoryId;
  bool saving = false;

  bool get editing => widget.place != null;

  @override
  void initState() {
    super.initState();
    final current = p["category"];
    if (current is Map) categoryId = current["id"];
    subType.addListener(() => setState(() {}));
    CategoryService.getCategories().then((list) {
      if (mounted) setState(() => categories = list);
    }).catchError((_) {});
  }

  @override
  void dispose() {
    for (final c in [name, subType, city, region, address, image, description, duration, entry, latitude, longitude]) {
      c.dispose();
    }
    super.dispose();
  }

  String _label(String raw) => raw.isEmpty ? raw : raw[0] + raw.substring(1).toLowerCase();

  Future<void> save() async {
    if (name.text.trim().isEmpty || city.text.trim().isEmpty || categoryId == null) {
      showAdminMessage(context, "Le nom, la ville et la catégorie sont obligatoires");
      return;
    }
    final gpsError = checkGps(latitude.text, longitude.text);
    if (gpsError != null) {
      showAdminMessage(context, gpsError);
      return;
    }

    final data = {
      "name": name.text.trim(),
      "subType": subType.text.trim(),
      "city": city.text.trim(),
      "region": region.text.trim(),
      "address": address.text.trim(),
      "imageUrl": image.text.trim(),
      "description": description.text.trim(),
      "visitDuration": parseNumber(duration.text),
      "entryPrice": parseNumber(entry.text),
      "latitude": parseNumber(latitude.text),
      "longitude": parseNumber(longitude.text),
      "category": {"id": categoryId},
    };

    setState(() => saving = true);
    try {
      if (editing) {
        await PlaceService().updatePlace(p["id"], data, widget.token);
      } else {
        await PlaceService().addPlace(data, widget.token);
      }
      if (!mounted) return;
      showAdminMessage(context, editing ? "Lieu modifié" : "Lieu ajouté");
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
      title: editing ? "Modifier le lieu" : "Nouveau lieu",
      saving: saving,
      onSave: save,
      children: [
        AdminSection(title: "Infos", children: [
          AdminField(label: "Nom *", controller: name, hint: "Maison des Esclaves"),
          const Text("Catégorie *", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 6),
          DropdownButtonFormField<int>(
            value: categories.any((c) => c.id == categoryId) ? categoryId : null,
            hint: Text(categories.isEmpty ? "Chargement…" : "Choisir"),
            items: categories
                .map((c) => DropdownMenuItem(value: c.id, child: Text(_label(c.name))))
                .toList(),
            onChanged: (v) => setState(() => categoryId = v),
          ),
          const SizedBox(height: 14),
          AdminField(label: "Sous-type", controller: subType, hint: "Musée, Mosquée, Parc national…"),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: subTypes
                .map((t) => ChoiceChip(
                      label: Text(t),
                      selected: subType.text == t,
                      selectedColor: AppColors.coralSoft,
                      backgroundColor: AppColors.chip,
                      side: BorderSide.none,
                      onSelected: (_) => setState(() => subType.text = t),
                    ))
                .toList(),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: AdminField(label: "Ville *", controller: city, hint: "Gorée")),
            const SizedBox(width: 12),
            Expanded(child: AdminField(label: "Région", controller: region, hint: "Dakar")),
          ]),
          AdminField(label: "Adresse", controller: address),
        ]),
        AdminSection(title: "Visite", children: [
          Row(children: [
            Expanded(child: AdminField(label: "Durée (heures)", controller: duration, number: true, hint: "1,5")),
            const SizedBox(width: 12),
            Expanded(child: AdminField(label: "Entrée (FCFA)", controller: entry, number: true, hint: "0 si gratuit")),
          ]),
        ]),
        AdminSection(title: "Présentation", children: [
          AdminField(label: "URL de la photo", controller: image, hint: "https://…"),
          AdminField(label: "Description", controller: description, maxLines: 5),
        ]),
        AdminSection(title: "Position", children: [
          GpsFields(latitude: latitude, longitude: longitude),
          const SizedBox(height: 12),
        ]),
      ],
    );
  }
}
