import 'package:flutter/material.dart';
import '../services/discover_service.dart';
import '../theme/app_colors.dart';
import '../widgets/item_navigation.dart';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  int days = 3;
  String start = "Dakar";
  final Set<String> selected = {"HISTORIQUE", "NATURE"};

  bool isLoading = false;
  Map<String, dynamic>? result;

  static const interests = {
    "HISTORIQUE": "Histoire",
    "CULTUREL": "Culture",
    "RELIGIEUX": "Religion",
    "NATURE": "Nature",
    "BALNEAIRE": "Plage",
    "AVENTURE": "Aventure",
    "MODERNE": "Ville",
  };

  static const starts = ["Dakar", "Saint-Louis", "Mbour", "Ziguinchor", "Touba"];

  Future<void> generate() async {
    setState(() => isLoading = true);
    try {
      final data = await DiscoverService.itinerary(
        days: days,
        categories: selected.toList(),
        start: start,
      );
      setState(() {
        result = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Ton circuit"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _form(),
          const SizedBox(height: 20),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (result != null)
            ..._plan(result!),
        ],
      ),
    );
  }

  Widget _form() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$days jour${days > 1 ? 's' : ''}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          Slider(
            value: days.toDouble(),
            min: 1,
            max: 7,
            divisions: 6,
            activeColor: AppColors.secondary,
            onChanged: (v) => setState(() => days = v.round()),
          ),
          const Text("Ce qui vous intéresse", style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interests.entries.map((e) {
              final on = selected.contains(e.key);
              return FilterChip(
                label: Text(e.value),
                selected: on,
                selectedColor: AppColors.accent.withValues(alpha: 0.25),
                checkmarkColor: AppColors.primary,
                onSelected: (_) => setState(() {
                  on ? selected.remove(e.key) : selected.add(e.key);
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text("Départ", style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: start,
                items: starts.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => start = v ?? "Dakar"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: isLoading ? null : generate,
              icon: const Icon(Icons.route_rounded, color: Colors.white),
              label: const Text("Générer mon circuit", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _plan(Map<String, dynamic> data) {
    final List planDays = data["days"] ?? [];
    if (planDays.isEmpty) {
      return [const Center(child: Text("Aucun lieu ne correspond, essayez d'autres centres d'intérêt."))];
    }

    return [
      Text(
        "${planDays.length} jour${planDays.length > 1 ? 's' : ''} · ${data["totalKm"]} km · ${(data["cities"] as List).join(", ")}",
        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
      ),
      const SizedBox(height: 12),
      ...planDays.map((d) => _dayCard(Map<String, dynamic>.from(d))),
    ];
  }

  Widget _dayCard(Map<String, dynamic> day) {
    final List places = day["places"] ?? [];
    final hotel = day["hotel"];
    final restaurant = day["restaurant"];

    final isLast = day["day"] == (result?["days"] as List?)?.length;
    final card = Container(
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  day["city"] ?? "",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Text(
                (day["driveHours"] ?? 0) >= 1
                    ? "${day["travelKm"]} km · ${_hours(day["driveHours"])} de route"
                    : "${day["travelKm"]} km",
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...places.map((p) {
            final place = Map<String, dynamic>.from(p);
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(typeIcons[place["type"]] ?? Icons.place_rounded, color: AppColors.accent),
              title: Text(place["name"] ?? ""),
              subtitle: place["visitDuration"] != null ? Text("≈ ${place["visitDuration"]} h") : null,
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => openItem(context, place),
            );
          }),
          if (hotel != null || restaurant != null) const Divider(),
          if (hotel != null)
            _suggestion(Icons.hotel_rounded, "Dormir", Map<String, dynamic>.from(hotel)),
          if (restaurant != null)
            _suggestion(Icons.restaurant_rounded, "Manger", Map<String, dynamic>.from(restaurant)),
        ],
      ),
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: day["day"] == 1 ? AppColors.laterite : AppColors.ink,
                  child: Text(
                    "J${day["day"]}",
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: AppColors.line)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: card,
            ),
          ),
        ],
      ),
    );
  }

  Widget _suggestion(IconData icon, String label, Map<String, dynamic> item) {
    return InkWell(
      onTap: () => openItem(context, item),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text("$label : ", style: const TextStyle(fontWeight: FontWeight.w700)),
            Expanded(child: Text(item["name"] ?? "", overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  String _hours(dynamic h) {
    final v = (h as num).toDouble();
    return v % 1 == 0 ? "${v.toInt()} h" : "${v.floor()} h 30";
  }
}
