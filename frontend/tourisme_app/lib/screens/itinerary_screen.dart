import 'package:flutter/material.dart';
import '../services/discover_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
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
      body: SafeArea(
        child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          Text("Ton circuit", style: AppTheme.display(size: 30)),
          const SizedBox(height: 16),
          _form(),
          const SizedBox(height: 24),
          if (isLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.laterite))
          else if (result != null)
            ..._plan(result!),
        ],
      ),
      ),
    );
  }

  Widget _form() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$days jour${days > 1 ? 's' : ''}",
            style: AppTheme.display(size: 24),
          ),
          Slider(
            value: days.toDouble(),
            min: 1,
            max: 7,
            divisions: 6,
            activeColor: AppColors.ink,
            inactiveColor: AppColors.line,
            onChanged: (v) => setState(() => days = v.round()),
          ),
          const Text("Ce qui t'intéresse", style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interests.entries.map((e) {
              final on = selected.contains(e.key);
              return GestureDetector(
                onTap: () => setState(() {
                  on ? selected.remove(e.key) : selected.add(e.key);
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: on ? AppColors.ink : AppColors.field,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: on ? AppColors.ink : AppColors.line),
                  ),
                  child: Text(
                    e.value,
                    style: TextStyle(
                      color: on ? Colors.white : AppColors.ink,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text("Départ", style: TextStyle(fontWeight: FontWeight.w600)),
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
            child: ElevatedButton(
              onPressed: isLoading ? null : generate,
              child: const Text("Générer mon circuit"),
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
        style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600),
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
                  style: AppTheme.display(size: 22),
                ),
              ),
              Text(
                (day["driveHours"] ?? 0) >= 1
                    ? "${day["travelKm"]} km · ${_hours(day["driveHours"])} de route"
                    : "${day["travelKm"]} km",
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...places.map((p) {
            final place = Map<String, dynamic>.from(p);
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(typeIcons[place["type"]] ?? Icons.place_rounded, color: AppColors.ink),
              title: Text(place["name"] ?? ""),
              subtitle: place["visitDuration"] != null ? Text("≈ ${place["visitDuration"]} h") : null,
              subtitleTextStyle: const TextStyle(color: AppColors.muted, fontSize: 12),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
              onTap: () => openItem(context, place),
            );
          }),
          if (hotel != null || restaurant != null) const Divider(color: AppColors.line),
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
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
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
            Icon(icon, size: 18, color: AppColors.muted),
            const SizedBox(width: 8),
            Text("$label : ", style: const TextStyle(fontWeight: FontWeight.w600)),
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
