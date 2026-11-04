import 'package:flutter/material.dart';
import '../services/event_service.dart';
import '../widgets/motion.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/net_image.dart';
import 'place_details_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = EventService.getUpcoming();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Calendrier des fêtes")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SkeletonList(count: 3, itemHeight: 240, padding: EdgeInsets.fromLTRB(20, 4, 20, 20));
          }
          if (snapshot.hasError) {
            return Center(
              child: TextButton(
                onPressed: () => setState(() => _future = EventService.getUpcoming()),
                child: const Text("Calendrier indisponible, réessayer", style: TextStyle(color: AppColors.ink)),
              ),
            );
          }
          final events = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            children: [
              const Text(
                "Les grands rassemblements religieux du Sénégal. Les fêtes musulmanes suivent le calendrier lunaire : "
                "leur date exacte n'est fixée qu'à l'observation du croissant, quelques semaines avant.",
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 20),
              if (events.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: Text("Aucun événement à venir", style: TextStyle(color: AppColors.muted))),
                ),
              for (var i = 0; i < events.length; i++) FadeSlideIn(index: i, child: _card(events[i])),
            ],
          );
        },
      ),
    );
  }

  Widget _card(Map<String, dynamic> e) {
    final place = e["place"] as Map<String, dynamic>?;
    final confirmed = e["confirmed"] == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showDetails(e),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    NetImage(
                      url: place?["imageUrl"],
                      seed: e["name"] ?? "",
                      icon: Icons.event_rounded,
                      height: 150,
                      width: double.infinity,
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _pill(EventService.countdown(e), AppColors.ink, Colors.white),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e["name"] ?? "", style: AppTheme.display(size: 20, weight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 15, color: AppColors.laterite),
                          const SizedBox(width: 6),
                          Text(EventService.dateLabel(e), style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          if (!confirmed) _pill("Date estimée", AppColors.lateriteSoft, AppColors.ink),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${e["city"] ?? ""} · ${e["community"] ?? ""}",
                        style: const TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pill(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }

  void _showDetails(Map<String, dynamic> e) {
    final place = e["place"] as Map<String, dynamic>?;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (ctx, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(e["name"] ?? "", style: AppTheme.display(size: 24)),
            const SizedBox(height: 6),
            Text(
              "${EventService.dateLabel(e)}${e["confirmed"] == true ? "" : " (date estimée)"}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Text(e["description"] ?? "", style: const TextStyle(height: 1.5)),
            if ((e["advice"] ?? "").toString().isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.chip, borderRadius: BorderRadius.circular(18)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Bon à savoir", style: AppTheme.display(size: 16, weight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(e["advice"], style: const TextStyle(height: 1.5)),
                  ],
                ),
              ),
            ],
            if (place != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PlaceDetailsScreen(place: place)),
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  side: const BorderSide(color: AppColors.ink),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.place_outlined, color: AppColors.ink),
                label: Text("Voir ${place["name"]}", style: const TextStyle(color: AppColors.ink)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
