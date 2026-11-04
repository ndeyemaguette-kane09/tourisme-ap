import 'package:flutter/material.dart';
import '../../services/place_service.dart';
import '../../widgets/admin_kit.dart';
import 'place_form_screen.dart';

class ManagePlacesScreen extends StatelessWidget {
  final String token;

  const ManagePlacesScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return AdminListPage(
      title: "Lieux à visiter",
      icon: Icons.account_balance_rounded,
      onAdd: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlaceFormScreen(token: token)),
      ),
      load: (refresh) async {
        final places = await PlaceService().getPlaces(token);
        return places
            .map((p) => AdminRow(
                  title: p["name"] ?? "",
                  subtitle: [p["subType"], p["city"]]
                      .where((e) => e != null && e.toString().isNotEmpty)
                      .join(" · "),
                  imageUrl: p["imageUrl"],
                  hasGps: p["latitude"] != null && p["longitude"] != null,
                  onEdit: () async {
                    final changed = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PlaceFormScreen(token: token, place: p)),
                    );
                    if (changed == true) refresh();
                  },
                  onDelete: () => PlaceService().deletePlace(p["id"], token),
                ))
            .toList();
      },
    );
  }
}
