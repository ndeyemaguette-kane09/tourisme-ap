import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/restaurant.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailsScreen({
    super.key,
    required this.restaurant,
  });

  @override
  State<RestaurantDetailsScreen> createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen>
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
    _fadeAnim =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
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
          _buildHeroImage(),
          _buildGradientOverlay(),
          _buildTopBar(context),
          _buildRatingBadge(),
          _buildDraggableSheet(),
          _buildFixedCTA(context),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildHeroImage() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.52,
      width: double.infinity,
      child: Image.network(
        widget.restaurant.imageUrl,
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
            child: Icon(Icons.restaurant_rounded,
                size: 80, color: Colors.white30),
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
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
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
                  _isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
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
          gradient: const LinearGradient(colors: [_orange, _orangeLight]),
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
              widget.restaurant.rating.toStringAsFixed(1),
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
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
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
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      padding:
                          const EdgeInsets.fromLTRB(24, 12, 24, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildNameSection(),
                          const SizedBox(height: 20),
                          _buildChips(),
                          const SizedBox(height: 24),
                          _buildInfoStrip(),
                          const SizedBox(height: 24),
                          _buildDescription(),
                          const SizedBox(height: 28),
                          _buildDecoDivider(),
                          const SizedBox(height: 20),
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
          widget.restaurant.name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.1,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                  color: _orange, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "${widget.restaurant.city} — ${widget.restaurant.address}",
                style: TextStyle(
                  fontSize: 13.5,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChips() {
    final tags = ["Cuisine locale", "Terrasse", "Sur réservation"];
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
        _infoTile(Icons.schedule_rounded, "Horaires", "12h–23h"),
        _dividerLine(),
        _infoTile(Icons.delivery_dining_rounded, "Livraison", "Disponible"),
        _dividerLine(),
        _infoTile(Icons.table_restaurant_rounded, "Places", "40+"),
      ],
    );
  }

  Widget _dividerLine() {
    return Container(width: 1, height: 44, color: Colors.grey.shade200);
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
              fontSize: 13,
              color: Color(0xFF1A1A1A),
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
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
          widget.restaurant.description ??
              "Un restaurant authentique au cœur du Sénégal, proposant une cuisine locale savoureuse dans une ambiance chaleureuse et conviviale.",
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
          child: Icon(Icons.restaurant_rounded,
              color: Colors.grey.shade300, size: 16),
        ),
        Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
      ],
    );
  }

  Widget _buildFixedCTA(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: _cream,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Container(
          height: 56,
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
                  Icon(Icons.calendar_today_rounded,
                      color: Colors.white, size: 19),
                  SizedBox(width: 10),
                  Text(
                    "Réserver une table",
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
        ),
      ),
    );
  }
}