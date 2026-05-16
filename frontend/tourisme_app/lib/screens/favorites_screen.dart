import 'package:flutter/material.dart';
import '../services/favorite_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  static const Color _terra = Color(0xFFE64A19);
  static const Color _terraDark = Color(0xFFBF360C);
  static const Color _terraLight = Color(0xFFF57C00);
  static const Color _bg = Color(0xFFFFF8F0);
  static const Color _textDark = Color(0xFF4E1B00);

  List<Map<String, dynamic>> favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final data = await FavoriteService.getFavorites();
    setState(() {
      favorites = data;
      _loading = false;
    });
  }

  Future<void> _removeFavorite(int index) async {
    await FavoriteService.removeFavorite(favorites[index]["id"]);
    setState(() => favorites.removeAt(index));
  }

  // Badge couleur selon le type
  Color _badgeColor(String type) {
    switch (type) {
      case 'hotel':
        return const Color(0xFFE64A19);
      case 'beach':
        return const Color(0xFF0288D1);
      case 'restaurant':
        return const Color(0xFF388E3C);
      default:
        return const Color(0xFF757575);
    }
  }

  IconData _badgeIcon(String type) {
    switch (type) {
      case 'hotel':
        return Icons.hotel_rounded;
      case 'beach':
        return Icons.beach_access_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  String _badgeLabel(String type) {
    switch (type) {
      case 'hotel':
        return 'Hôtel';
      case 'beach':
        return 'Plage';
      case 'restaurant':
        return 'Restaurant';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_terraDark, _terra, _terraLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Mes Favoris",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _loading
                        ? "Chargement..."
                        : "${favorites.length} lieu${favorites.length > 1 ? 'x' : ''} sauvegardé${favorites.length > 1 ? 's' : ''}",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // ── LISTE ──
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: _terra),
                    )
                  : favorites.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          color: _terra,
                          onRefresh: _loadFavorites,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                            itemCount: favorites.length,
                            itemBuilder: (context, index) {
                              return _buildCard(favorites[index], index);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item, int index) {
    final type = item["type"] ?? "autre";
    final badgeColor = _badgeColor(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── IMAGE ──
            Image.network(
              item["image"] ?? "",
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_terraDark, _terraLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  _badgeIcon(type),
                  size: 60,
                  color: Colors.white30,
                ),
              ),
            ),

            // ── GRADIENT ──
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.82),
                  ],
                  stops: const [0.3, 0.55, 1.0],
                ),
              ),
            ),

            // ── BADGE TYPE (coin haut gauche) ──
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: badgeColor.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_badgeIcon(type),
                        color: Colors.white, size: 12),
                    const SizedBox(width: 5),
                    Text(
                      _badgeLabel(type),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── BOUTON SUPPRIMER (coin haut droit) ──
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _removeFavorite(index),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.red,
                    size: 16,
                  ),
                ),
              ),
            ),

            // ── INFOS BAS ──
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["title"] ?? "",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: Colors.white.withOpacity(0.7),
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item["city"] != null &&
                                    item["city"].toString().isNotEmpty
                                ? item["city"]
                                : item["subtitle"] ?? "",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: _terra.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: 64,
              color: _terra.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Aucun favori pour l'instant",
            style: TextStyle(
              color: _textDark,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Appuie sur ♡ pour sauvegarder\nun hôtel ou une plage",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textDark.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}