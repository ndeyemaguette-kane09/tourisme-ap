import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/hotel.dart';
import '../services/reservation_service.dart';
import 'reservation_screen.dart';
import '../services/api_service.dart';

class HotelDetailsScreen extends StatefulWidget {
  final Hotel hotel;
  final int userId;
  final String token;
  final String userName;

  const HotelDetailsScreen({
    super.key,
    required this.hotel,
    required this.userId,
    required this.token,
    required this.userName,
  });

  @override
  State<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen>
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
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

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
          // ══════════ IMAGE HERO ══════════
          _buildHeroImage(),

          // ══════════ GRADIENT OVERLAY ══════════
          _buildGradientOverlay(),

          // ══════════ BOUTONS HAUT ══════════
          _buildTopBar(context),

          // ══════════ BADGE PRIX FLOTTANT ══════════
          _buildPriceBadge(),

          // ══════════ FEUILLE GLISSANTE ══════════
          _buildDraggableSheet(),

          // ══════════ BOUTON CTA FIXE ══════════
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
        widget.hotel.imageUrl,
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
            child:
                Icon(Icons.hotel_rounded, size: 80, color: Colors.white30),
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

  Widget _buildPriceBadge() {
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
            const Icon(Icons.payments_rounded, color: Colors.white, size: 15),
            const SizedBox(width: 6),
            Text(
              "${_formatPrice(widget.hotel.price)} FCFA",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
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

                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      padding:
                          const EdgeInsets.fromLTRB(24, 12, 24, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── NOM + LOCALISATION ──
                          _buildNameSection(),
                          const SizedBox(height: 20),

                          // ── CHIPS ──
                          _buildChips(),
                          const SizedBox(height: 24),

                          // ── STRIP INFOS ──
                          _buildInfoStrip(),
                          const SizedBox(height: 24),

                          // ── DESCRIPTION ──
                          _buildDescription(),
                          const SizedBox(height: 28),

                          _buildReviewsSection(),
                          const SizedBox(height: 28),


                          

                          // ── DIVIDER DÉCO ──
                          _buildDecoDivider(),
                          const SizedBox(height: 20),

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
          widget.hotel.name,
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
                "${widget.hotel.city} — ${widget.hotel.address}",
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
    final tags = ["Wifi gratuit", "Piscine", "Petit-déjeuner"];
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
        _infoTile(
          Icons.star_rounded,
          "Note",
          widget.hotel.rating.toStringAsFixed(1),
        ),
        _dividerLine(),
        _infoTile(
          Icons.king_bed_rounded,
          "Type",
          "Hôtel",
        ),
        _dividerLine(),
        _infoTile(
          Icons.verified_rounded,
          "Statut",
          "Disponible",
        ),
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
              fontSize: 14,
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
          widget.hotel.description ?? "Pas de description disponible.",
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


  Widget _buildReviewsSection() {
    // For dialog state
    double rating = 5;
    final TextEditingController commentController = TextEditingController();

    void _showAddReviewDialog() {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Votre avis",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  StatefulBuilder(
                    builder: (context, setStateDialog) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final star = index + 1;
                          return GestureDetector(
                            onTap: () {
                              setStateDialog(() {
                                rating = star.toDouble();
                              });
                            },
                            child: Icon(
                              Icons.star_rounded,
                              size: 28,
                              color: star <= rating ? _orange : Colors.grey.shade300,
                            ),
                          );
                        }),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Partage ton expérience...",
                      filled: true,
                      fillColor: _amber,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Annuler"),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            try {
                              await ApiService.addReview({
                                "username": widget.userName,
                                "rating": rating,
                                "comment": commentController.text,
                                "entityId": widget.hotel.id,
                                "entityType": "hotel",
                              });

                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Avis ajouté")),
                              );

                              setState(() {});
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Erreur envoi avis")),
                              );
                            }
                          },
                          child: const Text("Envoyer"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

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
              "Avis",
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
        FutureBuilder(
          future: ApiService.getReviews(widget.hotel.id, "hotel"),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
              return Text(
                "Aucun avis pour le moment",
                style: TextStyle(color: Colors.grey.shade600),
              );
            }

            final reviews = snapshot.data as List;

            return Column(
              children: reviews.map<Widget>((r) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _amber,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.person, color: _orange),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r['username'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              r['comment'],
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "⭐ ${r['rating']}",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 16),
        // New styled button
        SizedBox(
          width: double.infinity,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_orangeDark, _orange, _orangeLight],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _orange.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  _showAddReviewDialog();
                },
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "Ajouter un avis",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
          child: Icon(Icons.hotel_rounded,
              color: Colors.grey.shade300, size: 16),
        ),
        Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
      ],
    );
  }

  // ── CTA FIXE EN BAS ──
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
        child: Row(
          children: [
            // Prix affiché à gauche
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${_formatPrice(widget.hotel.price)} FCFA",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: _orange,
                  ),
                ),
                Text(
                  "par nuit",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            
  

            // Bouton réserver
            Expanded(
              child: Container(
                height: 54,
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReservationScreen(
                            hotelId: widget.hotel.id,
                            userId: widget.userId,
                            token: widget.token,
                          ),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_month_rounded,
                            color: Colors.white, size: 19),
                        SizedBox(width: 8),
                        Text(
                          "Réserver maintenant",
                          style: TextStyle(
                            fontSize: 15,
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
          ],
        ),
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