import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../screens/hotel_details_screen.dart';
import '../services/favorite_service.dart';

class HotelSwipeCard extends StatelessWidget {
  final Hotel hotel;
  final int userId;
  final String token;
  final String userName;

  const HotelSwipeCard({
    super.key,
    required this.hotel,
    required this.userId,
    required this.token,
    required this.userName,
  });

  static const Color _orange = Color(0xFFE64A19);
  static const Color _orangeDark = Color(0xFFBF360C);
  static const Color _orangeLight = Color(0xFFF57C00);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      // ── LOGIQUE NAVIGATION INCHANGÉE ──
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HotelDetailsScreen(
            hotel: hotel,
            userId: userId,
            token: token,
            userName: userName,
          ),
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
                hotel.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_orangeDark, _orangeLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.hotel_rounded,
                        size: 80, color: Colors.white30),
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
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.88),
                    ],
                    stops: const [0.35, 0.6, 1.0],
                  ),
                ),
              ),

              Positioned(
                top: 20,
                left: 20,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    // prevent parent tap
                    FocusScope.of(context).unfocus();

                    await FavoriteService.addFavorite({
                      "id": hotel.id,
                      "type": "hotel",
                      "title": hotel.name,
                      "image": hotel.imageUrl,
                      "subtitle": hotel.address,
                      "city": hotel.city.isNotEmpty ? hotel.city : "Dakar",
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
                      // Nom
                      Text(
                        hotel.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          letterSpacing: -0.3,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Adresse
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              color: Colors.white.withOpacity(0.7),
                              size: 13),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "${hotel.city} — ${hotel.address}",
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

                      // Tags : prix + note + flèche
                      Row(
                        children: [
                          _tag(
                            icon: Icons.payments_rounded,
                            label: "${_formatPrice(hotel.price)} FCFA",
                            gradient: const LinearGradient(
                              colors: [_orangeDark, _orange],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _tag(
                            icon: Icons.star_rounded,
                            label: hotel.rating.toStringAsFixed(1),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFF57C00),
                                Color(0xFFFFA726)
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Bouton détail compact
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
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  String _formatPrice(dynamic price) {
    final p = price is double ? price.toInt() : (price as int);
    if (p >= 1000) {
      return p.toString().replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]} ',
          );
    }
    return p.toString();
  }
}