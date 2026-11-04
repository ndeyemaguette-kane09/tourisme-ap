import 'package:flutter/material.dart';
import '../../services/event_service.dart';
import '../../services/place_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/admin_kit.dart';

class EventFormScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic>? event;

  const EventFormScreen({super.key, required this.token, this.event});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  Map<String, dynamic> get e => widget.event ?? const {};

  late final name = TextEditingController(text: e["name"]);
  late final community = TextEditingController(text: e["community"]);
  late final city = TextEditingController(text: e["city"]);
  late final description = TextEditingController(text: e["description"]);
  late final advice = TextEditingController(text: e["advice"]);
  late DateTime? start = e["startDate"] == null ? null : DateTime.parse(e["startDate"]);
  late DateTime? end = e["endDate"] == null ? null : DateTime.parse(e["endDate"]);
  late bool confirmed = e["confirmed"] == true;
  late int? placeId = (e["place"] as Map?)?["id"];

  List<Map<String, dynamic>> places = [];
  bool saving = false;

  bool get editing => widget.event != null;

  @override
  void initState() {
    super.initState();
    PlaceService().getPlaces(widget.token).then((list) {
      if (mounted) setState(() => places = list);
    }).catchError((_) {});
  }

  @override
  void dispose() {
    for (final c in [name, community, city, description, advice]) {
      c.dispose();
    }
    super.dispose();
  }

  String _iso(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  Future<void> _pick(bool isStart) async {
    final initial = (isStart ? start : end) ?? start ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        start = picked;
        if (end == null || end!.isBefore(picked)) end = picked;
      } else {
        end = picked;
      }
    });
  }

  Future<void> save() async {
    if (name.text.trim().isEmpty || start == null) {
      showAdminMessage(context, "Le nom et la date de début sont obligatoires");
      return;
    }
    final data = {
      "name": name.text.trim(),
      "community": community.text.trim(),
      "city": city.text.trim(),
      "description": description.text.trim(),
      "advice": advice.text.trim(),
      "startDate": _iso(start!),
      "endDate": _iso(end ?? start!),
      "confirmed": confirmed,
      "placeId": placeId,
    };
    setState(() => saving = true);
    try {
      await EventService.save(widget.token, data, id: editing ? e["id"] : null);
      if (!mounted) return;
      showAdminMessage(context, editing ? "Événement modifié" : "Événement ajouté");
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() => saving = false);
      showAdminMessage(context, "Enregistrement impossible");
    }
  }

  Widget _dateButton(String label, DateTime? value, bool isStart) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 6),
          OutlinedButton(
            onPressed: () => _pick(isStart),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: AppColors.field,
              side: const BorderSide(color: AppColors.line),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              value == null ? "Choisir" : "${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}",
              style: const TextStyle(color: AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminFormPage(
      title: editing ? "Modifier l'événement" : "Nouvel événement",
      saving: saving,
      onSave: save,
      children: [
        AdminSection(title: "Événement", children: [
          AdminField(label: "Nom *", controller: name, hint: "Grand Magal de Touba"),
          Row(children: [
            Expanded(child: AdminField(label: "Communauté", controller: community, hint: "Mouride")),
            const SizedBox(width: 12),
            Expanded(child: AdminField(label: "Ville", controller: city, hint: "Touba")),
          ]),
          const Text("Lieu associé", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 6),
          DropdownButtonFormField<int?>(
            value: places.any((p) => p["id"] == placeId) ? placeId : null,
            hint: Text(places.isEmpty ? "Chargement…" : "Aucun"),
            isExpanded: true,
            items: [
              const DropdownMenuItem<int?>(value: null, child: Text("Aucun")),
              ...places.map((p) => DropdownMenuItem<int?>(value: p["id"], child: Text(p["name"] ?? ""))),
            ],
            onChanged: (v) => setState(() => placeId = v),
          ),
          const SizedBox(height: 14),
        ]),
        AdminSection(title: "Dates", children: [
          Row(children: [
            _dateButton("Début *", start, true),
            const SizedBox(width: 12),
            _dateButton("Fin", end, false),
          ]),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.coral,
            title: const Text("Date officielle"),
            subtitle: const Text("À activer une fois la date annoncée (croissant lunaire observé)"),
            value: confirmed,
            onChanged: (v) => setState(() => confirmed = v),
          ),
        ]),
        AdminSection(title: "Présentation", children: [
          AdminField(label: "Description", controller: description, maxLines: 4),
          AdminField(label: "Bon à savoir", controller: advice, maxLines: 4),
        ]),
      ],
    );
  }
}
