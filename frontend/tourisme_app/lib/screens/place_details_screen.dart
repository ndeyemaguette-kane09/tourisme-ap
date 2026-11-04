import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';
import '../services/session.dart';
import '../theme/app_colors.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> place;

  const PlaceDetailsScreen({super.key, required this.place});

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  List reviews = [];
  bool _loadingReviews = true;

  Map<String, dynamic> get place => widget.place;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final data = await ApiService.getReviews(place["id"], "place");
      setState(() {
        reviews = data;
        _loadingReviews = false;
      });
    } catch (_) {
      setState(() => _loadingReviews = false);
    }
  }

  Future<void> _addFavorite() async {
    await FavoriteService.addFavorite({
      "id": place["id"],
      "type": "place",
      "title": place["name"],
      "image": place["imageUrl"],
      "subtitle": place["city"] ?? "",
      "city": place["city"] ?? "",
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ajouté aux favoris")),
    );
  }

  void _openReviewSheet() {
    double rating = 5;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Votre avis",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return IconButton(
                    onPressed: () => setSheetState(() => rating = i + 1.0),
                    icon: Icon(
                      i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: AppColors.accent,
                      size: 32,
                    ),
                  );
                }),
              ),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Racontez votre visite...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    try {
                      await ApiService.addReview({
                        "username": Session.userName ?? "Visiteur",
                        "rating": rating,
                        "comment": commentController.text,
                        "entityId": place["id"],
                        "entityType": "place",
                      });
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      _loadReviews();
                    } catch (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Erreur envoi avis")),
                      );
                    }
                  },
                  child: const Text("Envoyer", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.secondary, size: 20),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = place["category"] is Map ? place["category"]["name"] : place["category"];
    final double rating = (place["rating"] ?? 0).toDouble();
    final duration = place["visitDuration"];
    final price = place["entryPrice"];

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.secondary,
        onPressed: _openReviewSheet,
        icon: const Icon(Icons.rate_review_rounded, color: Colors.white),
        label: const Text("Donner un avis", style: TextStyle(color: Colors.white)),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                onPressed: _addFavorite,
                icon: const Icon(Icons.favorite_border_rounded),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    place["imageUrl"] ?? "",
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.accent),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        place["subType"] != null ? "$category · ${place["subType"]}" : category.toString(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    place["name"] ?? "",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 16, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          [place["city"], place["region"]]
                              .where((e) => e != null && e.toString().isNotEmpty)
                              .toSet()
                              .join(", "),
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ),
                      const Icon(Icons.star_rounded, color: AppColors.accent, size: 18),
                      Text(
                        " ${rating.toStringAsFixed(1)} (${place["reviewCount"] ?? 0})",
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _info(
                        Icons.schedule_rounded,
                        "Durée de visite",
                        duration == null ? "-" : "${(duration as num).toStringAsFixed(duration % 1 == 0 ? 0 : 1)} h",
                      ),
                      const SizedBox(width: 10),
                      _info(
                        Icons.confirmation_number_outlined,
                        "Entrée",
                        price == null ? "—" : price == 0 ? "Libre" : "${(price as num).round()} FCFA",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    place["description"] ?? "",
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                  if ((place["imageUrl"] ?? "").toString().contains("wikimedia"))
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        "Photo : Wikimedia Commons, licence libre",
                        style: TextStyle(fontSize: 11, color: AppColors.muted),
                      ),
                    ),
                  const SizedBox(height: 24),
                  const Text(
                    "Avis des voyageurs",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_loadingReviews)
                    const Center(child: CircularProgressIndicator())
                  else if (reviews.isEmpty)
                    const Text("Pas encore d'avis. Soyez le premier !")
                  else
                    ...reviews.map((r) => Card(
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(r["username"] ?? "Visiteur"),
                            subtitle: Text(r["comment"] ?? ""),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, color: AppColors.accent, size: 16),
                                Text("${r["rating"]}"),
                              ],
                            ),
                          ),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
