import 'package:flutter/material.dart';
import '../../services/beach_service.dart';
import '../../widgets/admin_kit.dart';
import 'beach_form_screen.dart';

class ManageBeachesScreen extends StatelessWidget {
  final String token;

  const ManageBeachesScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return AdminListPage(
      title: "Plages",
      icon: Icons.beach_access_rounded,
      onAdd: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BeachFormScreen(token: token)),
      ),
      load: (refresh) async {
        final beaches = await BeachService().getBeaches(token);
        return beaches
            .map((b) => AdminRow(
                  title: b.name,
                  subtitle: b.city,
                  imageUrl: b.imageUrl,
                  hasGps: b.latitude != 0 && b.longitude != 0,
                  onEdit: () async {
                    final changed = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BeachFormScreen(token: token, beach: b)),
                    );
                    if (changed == true) refresh();
                  },
                  onDelete: () => BeachService().deleteBeach(b.id, token),
                ))
            .toList();
      },
    );
  }
}
