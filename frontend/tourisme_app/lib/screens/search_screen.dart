import 'dart:async';
import 'package:flutter/material.dart';
import '../services/discover_service.dart';
import '../widgets/motion.dart';
import '../theme/app_colors.dart';
import '../widgets/item_navigation.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  final String? initialCategory;

  const SearchScreen({super.key, this.initialQuery, this.initialCategory});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final queryController = TextEditingController();
  Timer? _debounce;

  List<Map<String, dynamic>> results = [];
  bool isLoading = true;

  String? type;
  String? category;
  String? city;
  double minRating = 0;

  static const cities = ["Dakar", "Saint-Louis", "Mbour", "Touba", "Ziguinchor", "Kaolack", "Thiès", "Fatick"];
  static const categories = [
    "HISTORIQUE", "CULTUREL", "RELIGIEUX", "NATURE",
    "BALNEAIRE", "AVENTURE", "GASTRONOMIQUE", "MODERNE",
  ];

  @override
  void initState() {
    super.initState();
    queryController.text = widget.initialQuery ?? "";
    category = widget.initialCategory;
    _search();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    queryController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() => isLoading = true);
    try {
      final data = await DiscoverService.search(
        query: queryController.text,
        type: type,
        city: city,
        category: category,
        minRating: minRating > 0 ? minRating : null,
      );
      if (!mounted) return;
      setState(() {
        results = data;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        results = [];
        isLoading = false;
      });
    }
  }

  void _onQueryChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _search);
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.ink,
        backgroundColor: AppColors.field,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.textDark,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        showCheckmark: false,
      ),
    );
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Ville", style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: cities
                    .map((c) => ChoiceChip(
                          label: Text(c),
                          selected: city == c,
                          onSelected: (_) => setSheetState(() => city = city == c ? null : c),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 18),
              Text(
                "Note minimale : ${minRating == 0 ? 'toutes' : minRating.toStringAsFixed(1)}",
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Slider(
                value: minRating,
                min: 0,
                max: 5,
                divisions: 10,
                activeColor: AppColors.secondary,
                onChanged: (v) => setSheetState(() => minRating = v),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                  onPressed: () {
                    Navigator.pop(context);
                    _search();
                  },
                  child: const Text("Appliquer", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeFilters = (city != null ? 1 : 0) + (minRating > 0 ? 1 : 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: queryController,
          autofocus: widget.initialQuery == null && widget.initialCategory == null,
          onChanged: _onQueryChanged,
          cursorColor: AppColors.ink,
          decoration: const InputDecoration(
            hintText: "Gorée, une mosquée, une plage…",
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.ink),
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _openFilters,
            icon: Badge(
              isLabelVisible: activeFilters > 0,
              label: Text("$activeFilters"),
              child: const Icon(Icons.tune_rounded),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              children: [
                _chip("Tout", type == null, () {
                  setState(() => type = null);
                  _search();
                }),
                ...typeLabels.entries.map((e) => _chip(e.value, type == e.key, () {
                      setState(() => type = type == e.key ? null : e.key);
                      _search();
                    })),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: categories
                  .map((c) => _chip(c[0] + c.substring(1).toLowerCase(), category == c, () {
                        setState(() => category = category == c ? null : c);
                        _search();
                      }))
                  .toList(),
            ),
          ),
          Expanded(
            child: isLoading
                ? const SkeletonList(itemHeight: 76)
                : results.isEmpty
                    ? const Center(child: Text("Aucun résultat"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: results.length,
                        itemBuilder: (context, i) => FadeSlideIn(key: ValueKey("${results[i]["type"]}-${results[i]["id"]}"), index: i, child: _resultTile(results[i])),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _resultTile(Map<String, dynamic> item) {
    final double rating = (item["rating"] ?? 0).toDouble();
    return GestureDetector(
      onTap: () => openItem(context, item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
              child: Image.network(
                item["imageUrl"] ?? "",
                width: 96,
                height: 96,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 96,
                  height: 96,
                  color: AppColors.card,
                  child: Icon(typeIcons[item["type"]], color: AppColors.accent),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["name"] ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${item["subType"] ?? typeLabels[item["type"]] ?? ""} · ${item["city"] ?? ""}",
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: AppColors.accent),
                      Text(" ${rating.toStringAsFixed(1)}",
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                      if (item["price"] != null && item["type"] == "hotel") ...[
                        const SizedBox(width: 10),
                        Text(
                          "${(item["price"] as num).round()} FCFA / nuit",
                          style: const TextStyle(fontSize: 12, color: AppColors.primary),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black26),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}
