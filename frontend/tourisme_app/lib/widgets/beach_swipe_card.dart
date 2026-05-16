import 'package:flutter/material.dart';
import '../models/beach.dart';
import '../screens/beach_details_screen.dart';
import '../services/favorite_service.dart';

class BeachSwipeCard extends StatelessWidget {
  final Beach beach;

  const BeachSwipeCard({super.key, required this.beach});

  static const Color _red = Color(0xFFD32F2F);
  static const Color _redDark = Color(0xFFC62828);
  static const Color _redLight = Color(0xFFEF5350);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BeachDetailsScreen(beach: beach),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── IMAGE ──
              Image.network(
                beach.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_redDark, _redLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.beach_access_rounded,
                        size: 80, color: Colors.white30),
                  ),
                ),
              ),

              // ── GRADIENT ──  ← déplacé ici, avant les boutons
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.85),
                    ],
                    stops: const [0.35, 0.6, 1.0],
                  ),
                ),
              ),

              // ── BOUTON FAVORI ──  ← même logique que HotelSwipeCard
              Positioned(
                top: 20,
                left: 20,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    FocusScope.of(context).unfocus();

                    await FavoriteService.addFavorite({
                      "id": beach.id,
                      "type": "beach",
                      "title": beach.name,
                      "image": beach.imageUrl,
                      "subtitle": beach.address,
                      "city": beach.city ?? "",
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Ajouté aux favoris")),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),

              // ── BADGE HINT ──
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.2), width: 1),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app_rounded,
                          color: Colors.white70, size: 13),
                      SizedBox(width: 5),
                      Text(
                        "Appuyer pour détails",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── INFOS BAS DE CARTE ──
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        beach.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          letterSpacing: -0.3,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              color: Colors.white.withOpacity(0.7),
                              size: 13),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "${beach.city ?? ''} — ${beach.address}",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          _tag(
                            icon: Icons.place_rounded,
                            label: beach.city ?? "",
                            gradient: const LinearGradient(
                              colors: [_redDark, _red],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _tag(
                            icon: Icons.star_rounded,
                            label: beach.rating.toStringAsFixed(1),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEF5350), Color(0xFFE57373)],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 14,
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
      ),
    );
  }

  Widget _tag({
    required IconData icon,
    required String label,
    required LinearGradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}