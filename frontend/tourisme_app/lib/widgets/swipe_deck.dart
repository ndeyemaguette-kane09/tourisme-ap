import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import '../services/favorite_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'net_image.dart';

class SwipeEntry {
  final int id;
  final String type;
  final String name;
  final String? imageUrl;
  final String location;
  final double rating;
  final String? badge;
  final VoidCallback onOpen;

  const SwipeEntry({
    required this.id,
    required this.type,
    required this.name,
    required this.imageUrl,
    required this.location,
    required this.rating,
    required this.onOpen,
    this.badge,
  });

  Map<String, dynamic> get favorite => {
        "id": id,
        "type": type,
        "title": name,
        "image": imageUrl,
        "subtitle": location,
        "city": location,
      };
}

class SwipeDeck extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Future<List<SwipeEntry>> Function() load;
  final void Function(SwipeEntry entry, bool liked)? onSwipe;

  const SwipeDeck({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.load,
    this.onSwipe,
  });

  @override
  State<SwipeDeck> createState() => _SwipeDeckState();
}

class _SwipeDeckState extends State<SwipeDeck> {
  MatchEngine? _engine;
  List<SwipeEntry> _entries = [];
  bool _loading = true;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _finished = false;
    });
    try {
      final entries = await widget.load();
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _engine = entries.isEmpty
            ? null
            : MatchEngine(
                swipeItems: entries
                    .map((e) => SwipeItem(
                          content: e,
                          likeAction: () => _onLike(e),
                          nopeAction: () => widget.onSwipe?.call(e, false),
                        ))
                    .toList(),
              );
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onLike(SwipeEntry e) async {
    widget.onSwipe?.call(e, true);
    await FavoriteService.addFavorite(e.favorite);
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${e.name} ajouté à tes favoris"), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted),
              ),
            ),
            Expanded(child: _deck()),
            if (_engine != null && !_finished) _actions(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _deck() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.laterite));
    }
    if (_engine == null || _finished) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 48, color: AppColors.laterite),
              const SizedBox(height: 12),
              Text(
                _entries.isEmpty ? "Rien à afficher pour le moment" : "Tu as tout vu",
                style: AppTheme.display(size: 20, weight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              if (_entries.isNotEmpty)
                OutlinedButton(
                  onPressed: _load,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.ink),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Recommencer", style: TextStyle(color: AppColors.ink)),
                ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SwipeCards(
        matchEngine: _engine!,
        upSwipeAllowed: false,
        fillSpace: true,
        onStackFinished: () => setState(() => _finished = true),
        itemBuilder: (context, index) => _card(_entries[index]),
      ),
    );
  }

  Widget _card(SwipeEntry e) {
    return GestureDetector(
      onTap: e.onOpen,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            NetImage(url: e.imageUrl, seed: e.name, icon: widget.icon, heroTag: "img-${e.type}-${e.id}"),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
                ),
              ),
            ),
            if (e.badge != null)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16)),
                  child: Text(e.badge!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.name, style: AppTheme.display(size: 28, color: Colors.white)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          e.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const Icon(Icons.star_rounded, size: 16, color: AppColors.lateriteSoft),
                      Text(
                        " ${e.rating.toStringAsFixed(1).replaceAll('.', ',')}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text("Touche pour voir la fiche", style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actions() {
    Widget button(IconData icon, String label, Color bg, Color fg, double size, VoidCallback onTap) {
      return Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: bg == AppColors.field ? Border.all(color: AppColors.line) : null,
            ),
            child: Icon(icon, color: fg, size: size * 0.42),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          button(Icons.close_rounded, "Passer", AppColors.field, AppColors.ink, 60,
              () => _engine?.currentItem?.nope()),
          const SizedBox(width: 24),
          button(Icons.favorite_rounded, "J'aime", AppColors.laterite, Colors.white, 72,
              () => _engine?.currentItem?.like()),
        ],
      ),
    );
  }
}
