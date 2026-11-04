import 'package:flutter/material.dart';
import '../widgets/detail_layout.dart';

class PlaceDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> place;

  const PlaceDetailsScreen({super.key, required this.place});

  String _label(dynamic category) {
    if (category == null) return "";
    final c = category is Map ? category["name"].toString() : category.toString();
    return c.isEmpty ? "" : c[0] + c.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final duration = place["visitDuration"];
    final price = place["entryPrice"];
    final location = [place["address"], place["city"], place["region"]]
        .where((e) => e != null && e.toString().isNotEmpty)
        .map((e) => e.toString())
        .toSet()
        .join(", ");

    return DetailLayout(
      type: "place",
      id: place["id"],
      name: place["name"] ?? "",
      imageUrl: place["imageUrl"],
      tags: [
        _label(place["category"]),
        if (place["subType"] != null) place["subType"].toString(),
      ].where((t) => t.isNotEmpty).toList(),
      location: location,
      rating: ((place["rating"] ?? 0) as num).toDouble(),
      description: place["description"],
      infos: [
        DetailInfo(
          Icons.schedule_rounded,
          "Visite",
          duration is num ? "${duration % 1 == 0 ? duration.toInt() : duration} h" : "—",
        ),
        DetailInfo(
          Icons.confirmation_number_outlined,
          "Entrée",
          price == null ? "—" : price == 0 ? "Libre" : "${(price as num).round()} FCFA",
        ),
      ],
    );
  }
}
