import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import '../widgets/motion.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/item_navigation.dart';
import '../widgets/net_image.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> favorites = [];
  bool _loading = true;
  String? _type;

  static const _segments = [
    (null, "Tout"),
    ("place", "Sites"),
    ("beach", "Plages"),
    ("hotel", "Hôtels"),
    ("restaurant", "Restos"),
  ];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final data = await FavoriteService.getFavorites();
    if (!mounted) return;
    setState(() {
      favorites = data;
      _loading = false;
    });
  }

  Future<void> _removeFavorite(Map<String, dynamic> item) async {
    await FavoriteService.removeFavorite(item);
    setState(() => favorites.remove(item));
  }

  List<Map<String, dynamic>> get _shown =>
      _type == null ? favorites : favorites.where((f) => f["type"] == _type).toList();

  @override
  Widget build(BuildContext context) {
    final shown = _shown;
    final left = <Map<String, dynamic>>[];
    final right = <Map<String, dynamic>>[];
    for (var i = 0; i < shown.length; i++) {
      (i.isEven ? left : right).add(shown[i]);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.laterite,
          onRefresh: _loadFavorites,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Text("Tes favoris", style: AppTheme.display(size: 32)),
              const SizedBox(height: 6),
              const Row(
                children: [
                  Icon(Icons.cloud_done_outlined, size: 16, color: Color(0xFF1D7A5F)),
                  SizedBox(width: 6),
                  Text("Disponibles même sans connexion", style: TextStyle(fontSize: 13, color: AppColors.muted)),
                ],
              ),
              const SizedBox(height: 16),
              _segmentBar(),
              const SizedBox(height: 18),
              if (_loading)
                const Column(
                  children: [
                    Skeleton(height: 200, radius: 18),
                    SizedBox(height: 16),
                    Skeleton(height: 140, radius: 18),
                  ],
                )
              else if (shown.isEmpty)
                _empty()
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(children: [
                        for (var i = 0; i < left.length; i++)
                          FadeSlideIn(key: ValueKey("l${left[i]["type"]}${left[i]["id"]}"), index: i * 2, child: _card(left[i], i.isEven)),
                      ]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(children: [
                        for (var i = 0; i < right.length; i++)
                          FadeSlideIn(key: ValueKey("r${right[i]["type"]}${right[i]["id"]}"), index: i * 2 + 1, child: _card(right[i], i.isOdd)),
                      ]),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _segmentBar() {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: AppColors.chip, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: _segments.map((s) {
          final on = s.$1 == _type;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _type = s.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: on ? AppColors.ink : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  s.$2,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: on ? Colors.white : AppColors.ink,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _card(Map<String, dynamic> item, bool tall) {
    final type = item["type"] ?? "place";
    final subtitle = [typeLabels[type], (item["city"] ?? "").toString()]
        .where((e) => e != null && e.isNotEmpty)
        .join(" · ");

    return GestureDetector(
      onTap: () => openItem(context, {"type": type, "id": item["id"]}),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                NetImage(
                  heroTag: "img-$type-${item["id"]}",
                  url: item["image"],
                  seed: item["title"],
                  icon: typeIcons[type] ?? Icons.place_rounded,
                  radius: BorderRadius.circular(18),
                  height: tall ? 200 : 140,
                  width: double.infinity,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Semantics(
                    button: true,
                    label: "Retirer des favoris",
                    child: GestureDetector(
                      onTap: () => _removeFavorite(item),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
                        child: const Icon(Icons.favorite_rounded, color: AppColors.laterite, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item["title"] ?? "",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }

  Widget _empty() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          const Icon(Icons.favorite_border_rounded, size: 48, color: AppColors.laterite),
          const SizedBox(height: 12),
          Text("Rien ici pour l'instant", style: AppTheme.display(size: 20, weight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text(
            "Touche le cœur sur un lieu pour le garder sous la main.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
