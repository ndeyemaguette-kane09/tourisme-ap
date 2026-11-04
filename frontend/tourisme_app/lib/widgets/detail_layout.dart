import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';
import '../services/session.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'net_image.dart';

class DetailInfo {
  final IconData icon;
  final String label;
  final String value;

  const DetailInfo(this.icon, this.label, this.value);
}

class DetailLayout extends StatefulWidget {
  final String type;
  final int id;
  final String name;
  final String? imageUrl;
  final List<String> tags;
  final String location;
  final double rating;
  final String? description;
  final List<DetailInfo> infos;
  final String? actionLabel;
  final IconData actionIcon;
  final VoidCallback? onAction;

  const DetailLayout({
    super.key,
    required this.type,
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.location,
    required this.rating,
    this.tags = const [],
    this.description,
    this.infos = const [],
    this.actionLabel,
    this.actionIcon = Icons.add_rounded,
    this.onAction,
  });

  @override
  State<DetailLayout> createState() => _DetailLayoutState();
}

class _DetailLayoutState extends State<DetailLayout> {
  List reviews = [];
  bool _loadingReviews = true;
  bool _favorite = false;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
    _loadFavorite();
  }

  Future<void> _loadReviews() async {
    try {
      final data = await ApiService.getReviews(widget.id, widget.type);
      if (!mounted) return;
      setState(() {
        reviews = data;
        _loadingReviews = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingReviews = false);
    }
  }

  Future<void> _loadFavorite() async {
    final favs = await FavoriteService.getFavorites();
    if (!mounted) return;
    setState(() {
      _favorite = favs.any((f) => f["id"] == widget.id && f["type"] == widget.type);
    });
  }

  Map<String, dynamic> get _favItem => {
        "id": widget.id,
        "type": widget.type,
        "title": widget.name,
        "image": widget.imageUrl,
        "subtitle": widget.location,
        "city": widget.location,
      };

  Future<void> _toggleFavorite() async {
    if (_favorite) {
      await FavoriteService.removeFavorite(_favItem);
    } else {
      await FavoriteService.addFavorite(_favItem);
    }
    if (mounted) setState(() => _favorite = !_favorite);
  }

  double get _average {
    if (reviews.isEmpty) return widget.rating;
    final total = reviews.fold<double>(0, (sum, r) => sum + ((r["rating"] ?? 0) as num).toDouble());
    return total / reviews.length;
  }

  void _openReviewSheet() {
    double rating = 5;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ton avis sur ${widget.name}", style: AppTheme.display(size: 20, weight: FontWeight.w700)),
              const SizedBox(height: 12),
              Row(
                children: List.generate(5, (i) {
                  return IconButton(
                    tooltip: "${i + 1} sur 5",
                    onPressed: () => setSheetState(() => rating = i + 1.0),
                    icon: Icon(
                      i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: AppColors.coral,
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: "Raconte ta visite…"),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await ApiService.addReview({
                        "username": Session.userName ?? "Visiteur",
                        "rating": rating,
                        "comment": commentController.text,
                        "entityId": widget.id,
                        "entityType": widget.type,
                      });
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      _loadReviews();
                    } catch (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Ton avis n'a pas pu être envoyé")),
                      );
                    }
                  },
                  child: const Text("Envoyer"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roundButton(IconData icon, String label, VoidCallback onTap, {Color color = AppColors.ink}) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final description = widget.description ?? "";
    final long = description.length > 180;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    NetImage(
                      url: widget.imageUrl,
                      seed: widget.name,
                      height: 320,
                      width: double.infinity,
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _roundButton(Icons.arrow_back_rounded, "Retour", () => Navigator.pop(context)),
                            _roundButton(
                              _favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              _favorite ? "Retirer des favoris" : "Ajouter aux favoris",
                              _toggleFavorite,
                              color: _favorite ? AppColors.coral : AppColors.ink,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -28),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.tags.isNotEmpty)
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (var i = 0; i < widget.tags.length; i++)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: i == 0 ? AppColors.chip : Colors.transparent,
                                    borderRadius: BorderRadius.circular(14),
                                    border: i == 0 ? null : Border.all(color: AppColors.line),
                                  ),
                                  child: Text(
                                    widget.tags[i],
                                    style: TextStyle(fontSize: 12, fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w500),
                                  ),
                                ),
                            ],
                          ),
                        const SizedBox(height: 12),
                        Text(widget.name, style: AppTheme.display(size: 32)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.place_outlined, size: 16, color: AppColors.muted),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.location,
                                style: const TextStyle(color: AppColors.muted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.star_rounded, size: 18, color: AppColors.coral),
                            const SizedBox(width: 2),
                            Text(
                              "${_average.toStringAsFixed(1).replaceAll('.', ',')} (${reviews.length})",
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        if (widget.infos.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              for (var i = 0; i < widget.infos.length; i++) ...[
                                if (i > 0) const SizedBox(width: 10),
                                Expanded(child: _infoTile(widget.infos[i])),
                              ],
                            ],
                          ),
                        ],
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Text(
                            description,
                            maxLines: _expanded ? null : 4,
                            overflow: _expanded ? null : TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 15, height: 1.55),
                          ),
                          if (long)
                            TextButton(
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              onPressed: () => setState(() => _expanded = !_expanded),
                              child: Text(
                                _expanded ? "Réduire" : "Lire la suite",
                                style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
                              ),
                            ),
                        ],
                        if ((widget.imageUrl ?? "").contains("wikimedia"))
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Text(
                              "Photo : Wikimedia Commons, licence libre",
                              style: TextStyle(fontSize: 11, color: AppColors.muted),
                            ),
                          ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Text("Avis des voyageurs", style: AppTheme.display(size: 20, weight: FontWeight.w700)),
                            ),
                            TextButton.icon(
                              onPressed: _openReviewSheet,
                              icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.ink),
                              label: const Text("Donner un avis", style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_loadingReviews)
                          const Center(child: CircularProgressIndicator(color: AppColors.coral))
                        else if (reviews.isEmpty)
                          const Text("Pas encore d'avis. Sois le premier à partager ton expérience.",
                              style: TextStyle(color: AppColors.muted))
                        else
                          ...reviews.map(_reviewTile),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (widget.actionLabel != null)
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: SafeArea(
                top: false,
                child: ElevatedButton.icon(
                  onPressed: widget.onAction,
                  icon: Icon(widget.actionIcon),
                  label: Text(widget.actionLabel!),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoTile(DetailInfo info) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(info.icon, size: 20, color: AppColors.coral),
          const SizedBox(height: 6),
          Text(info.label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          Text(
            info.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _reviewTile(dynamic r) {
    final name = (r["username"] ?? "Visiteur").toString().trim();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.chip,
            child: Text(
              name.isEmpty ? "?" : name[0].toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700))),
                    const Icon(Icons.star_rounded, size: 16, color: AppColors.coral),
                    Text(" ${r["rating"]}"),
                  ],
                ),
                if ((r["comment"] ?? "").toString().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(r["comment"].toString()),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
