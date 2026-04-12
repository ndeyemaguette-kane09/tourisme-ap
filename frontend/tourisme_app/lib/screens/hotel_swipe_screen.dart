import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import '../models/hotel.dart';
import '../services/hotel_service.dart';
import '../widgets/hotel_swipe_card.dart';

class HotelSwipeScreen extends StatefulWidget {
  final String token;
  final int userId;

  const HotelSwipeScreen({
    super.key,
    required this.token,
    required this.userId,
  });

  @override
  State<HotelSwipeScreen> createState() => _HotelSwipeScreenState();
}

class _HotelSwipeScreenState extends State<HotelSwipeScreen> {
  final HotelService hotelService = HotelService();
  List<SwipeItem> swipeItems = [];
  MatchEngine? matchEngine;
  List<Hotel> hotels = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHotels();
  }

  void loadHotels() async {
    try {
      hotels = await hotelService.getHotels(widget.token);
      swipeItems = hotels.map((hotel) {
        return SwipeItem(
          content: hotel,
          likeAction: () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("❤️  ${hotel.name} ajouté aux favoris !"),
                  backgroundColor: const Color(0xFF2E7D32),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          },
          nopeAction: () {
            if (mounted) {
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
          },
        );
      }).toList();

      setState(() {
        matchEngine = MatchEngine(swipeItems: swipeItems);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: Stack(
        children: [
          // ── Header dégradé ──
          Container(
            height: 160,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFBF360C),
                  Color(0xFFE64A19),
                  Color(0xFFF57C00),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3), width: 1.2),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Discover Hotels",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Swipez pour explorer 🏨",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Contenu ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 90),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFE64A19),
                      ),
                    )
                  : hotels.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.hotel,
                                  size: 60,
                                  color: const Color(0xFFE64A19).withOpacity(0.3)),
                              const SizedBox(height: 16),
                              Text("Aucun hôtel disponible",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade400,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            // ── Instructions ──
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _swipeHint(
                                    icon: Icons.close,
                                    label: "Passer",
                                    color: const Color(0xFFE53935),
                                    direction: "← Gauche",
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.grey.shade200,
                                  ),
                                  _swipeHint(
                                    icon: Icons.favorite,
                                    label: "Aimer",
                                    color: const Color(0xFF2E7D32),
                                    direction: "Droite →",
                                  ),
                                ],
                              ),
                            ),

                            // ── Cards ──
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
                                        );
                                      },
                                      onStackFinished: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                                "Vous avez vu tous les hôtels ! 🎉"),
                                            backgroundColor:
                                                const Color(0xFFBF360C),
                                            behavior:
                                                SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                          ),
                                        );
                                      },
                                    ),
                            ),

                            // ── Boutons action en bas ──
                            Padding(
                              padding: const EdgeInsets.fromLTRB(40, 8, 40, 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _actionButton(
                                    icon: Icons.close,
                                    color: const Color(0xFFE53935),
                                    onTap: () =>
                                        matchEngine?.currentItem?.nope(),
                                  ),
                                  _actionButton(
                                    icon: Icons.favorite,
                                    color: const Color(0xFF2E7D32),
                                    onTap: () =>
                                        matchEngine?.currentItem?.like(),
                                    large: true,
                                  ),
                                  _actionButton(
                                    icon: Icons.star,
                                    color: const Color(0xFFF57C00),
                                    onTap: () {},
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _swipeHint({
    required IconData icon,
    required String label,
    required Color color,
    required String direction,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4),
            Text(direction,
                style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label,
            style:
                TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool large = false,
  }) {
    final size = large ? 62.0 : 50.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Icon(icon, color: color, size: large ? 28 : 22),
      ),
    );
  }
}