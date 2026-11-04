import 'package:flutter/material.dart';
import '../../services/event_service.dart';
import '../../widgets/admin_kit.dart';
import 'event_form_screen.dart';

class ManageEventsScreen extends StatelessWidget {
  final String token;

  const ManageEventsScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return AdminListPage(
      title: "Calendrier",
      icon: Icons.event_rounded,
      onAdd: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EventFormScreen(token: token)),
      ),
      load: (refresh) async {
        final events = await EventService.getAll(token);
        return events.reversed
            .map((e) => AdminRow(
                  title: e["name"] ?? "",
                  subtitle: "${EventService.dateLabel(e)}${e["confirmed"] == true ? "" : " · estimée"}",
                  imageUrl: (e["place"] as Map?)?["imageUrl"],
                  hasGps: true,
                  onEdit: () async {
                    final changed = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EventFormScreen(token: token, event: e)),
                    );
                    if (changed == true) refresh();
                  },
                  onDelete: () => EventService.delete(token, e["id"]),
                ))
            .toList();
      },
    );
  }
}
