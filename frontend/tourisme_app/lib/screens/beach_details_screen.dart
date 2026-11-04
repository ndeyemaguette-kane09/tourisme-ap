import 'package:flutter/material.dart';
import '../models/beach.dart';
import '../widgets/detail_layout.dart';

class BeachDetailsScreen extends StatelessWidget {
  final Beach beach;

  const BeachDetailsScreen({
    super.key,
    required this.beach,
  });

  @override
  Widget build(BuildContext context) {
    return DetailLayout(
      type: "beach",
      id: beach.id,
      name: beach.name,
      imageUrl: beach.imageUrl,
      tags: const ["Plage", "Balnéaire"],
      location: [beach.address, beach.city].where((e) => e.isNotEmpty).toSet().join(", "),
      rating: beach.rating,
      description: beach.description,
      infos: [
        DetailInfo(Icons.location_city_outlined, "Ville", beach.city.isEmpty ? "—" : beach.city),
      ],
    );
  }
}
