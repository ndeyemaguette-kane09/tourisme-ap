import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/beach.dart';

class BeachDetailsScreen extends StatefulWidget {
  final Beach beach;

  const BeachDetailsScreen({
    super.key,
    required this.beach,
  });

  @override
  State<BeachDetailsScreen> createState() => _BeachDetailsScreenState();
}

class _BeachDetailsScreenState extends State<BeachDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool _isFavorite = false;

  // ── Palette Teranga ──
  static const Color _orange = Color(0xFFE64A19);
  static const Color _orangeDark = Color(0xFFBF360C);
  static const Color _orangeLight = Color(0xFFF57C00);
  static const Color _cream = Color(0xFFFFF8F0);
  static const Color _amber = Color(0xFFFFF3E0);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
        parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _slideController, curve: Curves.easeOutCubic));

    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: _cream,
      body: Stack(
        children: [
          // ══════════ IMAGE IMMERSIVE ══════════
          _buildHeroImage(),

          // ══════════ OVERLAY GRADIENT ══════════
          _buildGradientOverlay(),

          // ══════════ BACK + FAVE BUTTONS ══════════
          _buildTopBar(context),

          // ══════════ BADGE FLOTTANT ══════════
          _buildRatingBadge(),

          // ══════════ FEUILLE GLISSANTE ══════════
          _buildDraggableSheet(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  Widget _buildHeroImage() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.52,
      width: double.infinity,
      child: Image.network(
        widget.beach.imageUrl,
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
            child: Icon(Icons.beach_access, size: 80, color: Colors.white30),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.52,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.15),
              Colors.black.withOpacity(0.75),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.2, 0.55, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Bouton retour
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.2), width: 1),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),

            // Bouton favori
            GestureDetector(
              onTap: () => setState(() => _isFavorite = !_isFavorite),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _isFavorite
                      ? _orange.withOpacity(0.9)
                      : Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.2), width: 1),
                ),
                child: Icon(
                  _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBadge() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.52 - 22,
      right: 28,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_orange, _orangeLight],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: _orange.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 5),
            Text(
              widget.beach.rating.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.56,
      minChildSize: 0.56,
      maxChildSize: 0.92,
      builder: (context, controller) {
        return FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Container(
              decoration: const BoxDecoration(
                color: _cream,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  // Contenu scrollable
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── NOM + VILLE ──
                          _buildNameSection(),
                          const SizedBox(height: 24),

                          // ── CHIPS D'AMBIANCE ──
                          _buildChips(),
                          const SizedBox(height: 24),

                          // ── INFOS RAPIDES ──
                          _buildInfoStrip(),
                          const SizedBox(height: 24),

                          // ── DESCRIPTION ──
                          _buildDescription(),
                          const SizedBox(height: 28),

                          // ── DIVIDER DÉCO ──
                          _buildDecoDivider(),
                          const SizedBox(height: 28),

                          // ── BOUTON CTA ──
                          _buildCTA(),
                          const SizedBox(height: 12),

                          // ── FOOTER ──
                          const Center(
                            child: Text(
                              "🇸🇳 Teranga • Culture • Découverte",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                letterSpacing: 0.8,
                              ),
                            ),
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
      },
    );
  }

  Widget _buildNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.beach.name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.1,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: _orange,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "${widget.beach.city} — ${widget.beach.address}",
              style: TextStyle(
                fontSize: 13.5,
                color: Colors.grey.shade600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChips() {
    final tags = ["Baignade", "Coucher de soleil", "Tranquille"];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) => _chip(tag)).toList(),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: _amber,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _orange.withOpacity(0.2), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _orangeDark,
        ),
      ),
    );
  }

  Widget _buildInfoStrip() {
    return Row(
      children: [
        _infoTile(Icons.wb_sunny_rounded, "Météo", "28°C"),
        _dividerLine(),
        _infoTile(Icons.waves_rounded, "Vagues", "Calmes"),
        _dividerLine(),
        _infoTile(Icons.groups_rounded, "Affluence", "Modérée"),
      ],
    );
  }

  Widget _dividerLine() {
    return Container(
      width: 1,
      height: 44,
      color: Colors.grey.shade200,
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: _orange, size: 22),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: Color(0xFF1A1A1A),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                color: _orange,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "À propos",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          widget.beach.description.isNotEmpty
              ? widget.beach.description
              : "Une plage magnifique nichée au cœur du Sénégal, où les eaux turquoises et les sables dorés vous invitent à la contemplation. Idéale pour se ressourcer loin de l'agitation.",
          style: TextStyle(
            fontSize: 14.5,
            color: Colors.grey.shade700,
            height: 1.65,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }

  Widget _buildDecoDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(Icons.waves_rounded,
              color: Colors.grey.shade300, size: 18),
        ),
        Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
      ],
    );
  }

  Widget _buildCTA() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_orangeDark, _orange, _orangeLight],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _orange.withOpacity(0.45),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {},
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.explore_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                "Explorer cette plage",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}