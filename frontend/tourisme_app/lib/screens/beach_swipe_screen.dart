import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swipe_cards/swipe_cards.dart';
import '../models/beach.dart';
import '../services/beach_service.dart';
import '../widgets/beach_swipe_card.dart';
import '../services/favorite_service.dart';

class BeachSwipeScreen extends StatefulWidget {
  final String token;

  const BeachSwipeScreen({super.key, required this.token});

  @override
  State<BeachSwipeScreen> createState() => _BeachSwipeScreenState();
}

class _BeachSwipeScreenState extends State<BeachSwipeScreen>
    with TickerProviderStateMixin {
  final BeachService service = BeachService();

  List<Beach> beaches = [];
  bool isLoading = true;
  int currentIndex = 0;
  List<SwipeItem> swipeItems = [];
  MatchEngine? matchEngine;

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
    loadBeaches();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void loadBeaches() async {
    try {
      final result = await service.getBeaches(widget.token);

      if (!mounted) return; // 🔥 prevents crash if widget disposed

      beaches = result ?? [];

      swipeItems = beaches.map((beach) {
        return SwipeItem(
          content: beach,
          likeAction: () => _advance(),
          nopeAction: () => _advance(),
        );
      }).toList();

      setState(() {
        matchEngine =
            swipeItems.isEmpty ? null : MatchEngine(swipeItems: swipeItems);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return; // 🔥 prevents crash
      setState(() => isLoading = false);
    }
  }

  void _advance() {
    setState(() {
      if (currentIndex < beaches.length - 1) currentIndex++;
    });
  }

  void _like() {
    matchEngine?.currentItem?.like();
    _advance();
  }

  void _nope() {
    matchEngine?.currentItem?.nope();
    _advance();
  }

  void _superLike() {
    matchEngine?.currentItem?.superLike();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
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

          // ── MOTIF DÉCORATIF (cercles flous) ──
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

          // ── ARRONDI BLANC ──
          Positioned(
            top: size.height * 0.19,
            left: 0,
            right: 0,
            child: Container(
              height: 36,
              decoration: const BoxDecoration(
                color: _cream,
                borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
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
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Découvrir",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const Text(
                                "les plages 🌊",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Glissez pour explorer le Sénégal",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Compteur en haut à droite
                        if (!isLoading && beaches.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Text(
                              "${currentIndex + 1} / ${beaches.length}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ── CARTES SWIPE ──
                Expanded(
                  child: isLoading
                      ? _buildLoader()
                      : beaches.isEmpty
                          ? _buildEmpty()
                          : currentIndex >= beaches.length
                              ? _buildFinished()
                              : SwipeCards(
                                  matchEngine: matchEngine!,
                                  itemBuilder: (context, index) {
                                    return BeachSwipeCard(
                                        beach: beaches[index]);
                                  },
                                  onStackFinished: () {
                                    setState(() {
                                      currentIndex = beaches.length;
                                    });
                                  },
                                  upSwipeAllowed: true,
                                  fillSpace: true,
                                ),
                ),

                // ── BARRE D'ACTIONS ──
                if (!isLoading && beaches.isNotEmpty &&
                    currentIndex < beaches.length)
                  _buildActionBar(),

                // ── BARRE DE PROGRESSION ──
                if (!isLoading && beaches.isNotEmpty &&
                    currentIndex < beaches.length)
                  _buildProgressBar(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
              child: const Icon(Icons.beach_access_rounded,
                  color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Chargement des plages…",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.beach_access_rounded,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "Aucune plage disponible",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildFinished() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [_orange, _orangeLight]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.check_rounded,
                color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),
          const Text(
            "Vous avez tout exploré !",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "🇸🇳 Teranga • Culture • Découverte",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () {
              setState(() {
                currentIndex = 0;
                loadBeaches();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_orangeDark, _orange, _orangeLight]),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: _orange.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Text(
                "Recommencer",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _actionButton(
            icon: Icons.close_rounded,
            color: const Color(0xFFEF5350),
            size: 56,
            onTap: _nope,
            tooltip: "Passer",
          ),
          const SizedBox(width: 16),
          _actionButton(
            icon: Icons.bolt_rounded,
            color: _orange,
            size: 48,
            onTap: _superLike,
            tooltip: "Super",
          ),
          const SizedBox(width: 16),
          _actionButton(
            icon: Icons.favorite_rounded,
            color: const Color(0xFF43A047),
            size: 56,
            onTap: _like,
            tooltip: "J'aime",
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required double size,
    required VoidCallback onTap,
    required String tooltip,
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

  Widget _buildProgressBar() {
    final progress =
        beaches.isEmpty ? 0.0 : (currentIndex + 1) / beaches.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: Colors.grey.shade200,
              valueColor:
                  const AlwaysStoppedAnimation(_orange),
            ),
          ),
        ],
      ),
    );
  }
}