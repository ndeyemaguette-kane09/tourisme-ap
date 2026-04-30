import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swipe_cards/swipe_cards.dart';
import '../models/hotel.dart';
import '../services/hotel_service.dart';
import '../widgets/hotel_swipe_card.dart';

class HotelSwipeScreen extends StatefulWidget {
  final String token;
  final int userId;
  final String userName;

  const HotelSwipeScreen({
    super.key,
    required this.token,
    required this.userId, 
    required this.userName,
  });

  @override
  State<HotelSwipeScreen> createState() => _HotelSwipeScreenState();
}

class _HotelSwipeScreenState extends State<HotelSwipeScreen>
    with TickerProviderStateMixin {
  final HotelService hotelService = HotelService();
  List<SwipeItem> swipeItems = [];
  MatchEngine? matchEngine;
  List<Hotel> hotels = [];
  bool isLoading = true;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // ── Palette Teranga ──
  static const Color _orange = Color(0xFFE64A19);
  static const Color _orangeDark = Color(0xFFBF360C);
  static const Color _orangeLight = Color(0xFFF57C00);
  static const Color _cream = Color(0xFFFFF8F0);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    loadHotels();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ── LOGIQUE INCHANGÉE ──
  void loadHotels() async {
    try {
      final result = await hotelService.getHotels(widget.token);
      if (!mounted) return;
      hotels = result ?? [];
      swipeItems = hotels.map((hotel) {
        return SwipeItem(
          content: hotel,
          likeAction: () {},
          nopeAction: () {},
        );
      }).toList();

      setState(() {
        if (hotels.isEmpty) {
          matchEngine = null;
        } else {
          matchEngine = MatchEngine(swipeItems: swipeItems);
        }
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _cream,
      body: Stack(
        children: [
          // ── HEADER GRADIENT ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size.height * 0.22,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_orangeDark, _orange, _orangeLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // ── CERCLES DÉCORATIFS ──
          Positioned(
            top: -30,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 40,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),

          // ── ARRONDI CRÈME ──
          Positioned(
            top: size.height * 0.19,
            left: 0,
            right: 0,
            child: Container(
              height: 36,
              decoration: const BoxDecoration(
                color: _cream,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(36)),
              ),
            ),
          ),

          // ── CONTENU PRINCIPAL ──
          SafeArea(
            child: Column(
              children: [
                // ── TITRE HEADER ──
                SizedBox(
                  height: size.height * 0.14,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Bouton retour
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1),
                            ),
                            child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 16),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Titre
                        const Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Découvrir",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                "les hôtels 🏨",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Glissez pour explorer le Sénégal",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── CONTENU SWIPE ──
                Expanded(
                  child: isLoading
                      ? _buildLoader()
                      : hotels.isEmpty
                          ? _buildEmpty()
                          : Column(
                              children: [
                                // Cartes
                                Expanded(
                                  child: matchEngine == null
                                      ? const SizedBox()
                                      : SwipeCards(
                                          matchEngine: matchEngine!,
                                          itemBuilder: (context, index) {
                                            return HotelSwipeCard(
                                              hotel: hotels[index],
                                              userId: widget.userId,
                                              token: widget.token,
                                              userName: widget.userName, 
                                            );
                                          },
                                          onStackFinished: () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                    "Vous avez vu tous les hôtels ! 🎉"),
                                                backgroundColor: _orangeDark,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12)),
                                              ),
                                            );
                                          },
                                          upSwipeAllowed: true,
                                          fillSpace: true,
                                        ),
                                ),

                                // Boutons d'action
                                _buildActionBar(),

                                const SizedBox(height: 24),
                              ],
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── LOADER ──
  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _pulseAnim,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_orange, _orangeLight]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.hotel_rounded,
                  color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Chargement des hôtels…",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ── VIDE ──
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hotel_rounded,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "Aucun hôtel disponible",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── BOUTONS ACTION ──
  Widget _buildActionBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ✕ Ignorer — logique originale
          _actionButton(
            icon: Icons.close_rounded,
            color: const Color(0xFFE53935),
            size: 56,
            tooltip: "Passer",
            onTap: () {
              final hotel =
                  matchEngine?.currentItem?.content as Hotel?;
              if (hotel != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("❌  ${hotel.name} ignoré"),
                    backgroundColor: const Color(0xFF757575),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
              matchEngine?.currentItem?.nope();
            },
          ),

          const SizedBox(width: 16),

          // ⭐ Super like — logique originale
          _actionButton(
            icon: Icons.bolt_rounded,
            color: _orange,
            size: 48,
            tooltip: "Super",
            onTap: () {
              final hotel =
                  matchEngine?.currentItem?.content as Hotel?;
              if (hotel != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text("⭐  ${hotel.name} ajouté aux favoris premium"),
                    backgroundColor: _orangeLight,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
          ),

          const SizedBox(width: 16),

          // ❤️ Like — logique originale
          _actionButton(
            icon: Icons.favorite_rounded,
            color: const Color(0xFF43A047),
            size: 56,
            tooltip: "J'aime",
            onTap: () {
              final hotel =
                  matchEngine?.currentItem?.content as Hotel?;
              if (hotel != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        "❤️  ${hotel.name} ajouté aux favoris !"),
                    backgroundColor: const Color(0xFF2E7D32),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
              matchEngine?.currentItem?.like();
            },
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required double size,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: size * 0.42),
          ),
          const SizedBox(height: 5),
          Text(
            tooltip,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}