import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'hotel_swipe_screen.dart';
import 'restaurant_swipe_screen.dart';
import 'my_reservations_screen.dart';
import 'profile_screen.dart';
import '../services/category_service.dart';
import 'beach_swipe_screen.dart';
import 'favorites_screen.dart';
import '../models/category.dart';
import 'map_screen.dart';
import 'search_screen.dart';
import 'itinerary_screen.dart';
import '../services/discover_service.dart';
import '../widgets/item_navigation.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  final int userId;
  final String userName;

  const HomeScreen({
    super.key,
    required this.token,
    required this.userId,
    required this.userName,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _terra = Color(0xFFE64A19);
  static const Color _terraDark = Color(0xFFBF360C);
  static const Color _terraLight = Color(0xFFF57C00);
  static const Color _bg = Color(0xFFFFF8F0);
  static const Color _textDark = Color(0xFF4E1B00);

  int _currentIndex = 0;
  File? profileImage;
  List<Category> categories = [];

  List<Map<String, dynamic>> popular = [];
  List<Map<String, dynamic>> recommended = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProfileImage();
    _loadDiscover();
  }

  Future<void> _loadDiscover() async {
    try {
      final all = await DiscoverService.search(type: "place");
      final recos = await DiscoverService.recommendations(limit: 8);
      if (!mounted) return;
      setState(() {
        popular = all.take(3).toList();
        recommended = recos;
      });
    } catch (e) {
      debugPrint("ERREUR DISCOVER: $e");
    }
  }

  void _openSearch({String? query, String? category}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchScreen(initialQuery: query, initialCategory: category),
      ),
    );
  }

  void _open(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _loadCategories() async {
    try {
      final data = await CategoryService.getCategories();
      setState(() => categories = data);
    } catch (e) {
      debugPrint("ERREUR CATEGORY: $e");
    }
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_${widget.userId}');
    if (path != null && mounted) {
      setState(() => profileImage = File(path));
    }
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return "Bonjour";
    if (h < 18) return "Bon après-midi";
    return "Bonsoir";
  }

  String _firstName() => widget.userName.split(' ').first;

  // ── Icône dynamique par catégorie ──
  IconData _iconForCategory(String name) {
    switch (name.toUpperCase()) {
      case "BALNEAIRE": return Icons.beach_access;
      case "CULTUREL":  return Icons.museum;
      case "RELIGIEUX": return Icons.account_balance;
      case "GASTRONOMIQUE": return Icons.restaurant;
      case "NATURE":    return Icons.park;
      case "HISTORIQUE": return Icons.history_edu;
      case "AVENTURE":  return Icons.hiking;
      case "MODERNE":   return Icons.location_city;
      default:          return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget homeContent = SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [

          // ── HEADER ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_terraDark, _terra, _terraLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Salutation
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: "${_greeting()}, ",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: _firstName(),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              const TextSpan(
                                text: " 👋",
                                style: TextStyle(fontSize: 20),
                              ),
                            ]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Où voulez-vous aller aujourd'hui ?",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.80),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Avatar
                    GestureDetector(
                      onTap: () => setState(() => _currentIndex = 3),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                            )
                          ],
                        ),
                        child: ClipOval(
                          child: profileImage != null
                              ? Image.file(profileImage!, fit: BoxFit.cover)
                              : Container(
                                  color: Colors.white.withOpacity(0.25),
                                  child: const Icon(Icons.person,
                                      color: Colors.white, size: 28),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Barre de recherche
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: TextField(
                    readOnly: true,
                    onTap: () => _openSearch(),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search, color: _terra),
                      hintText: "Rechercher une destination...",
                      hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Stats rapides ──
                Row(
                  children: [
                    _statBadge(Icons.hotel_rounded, "Hôtels", () => _open(HotelSwipeScreen(
                          token: widget.token,
                          userId: widget.userId,
                          userName: widget.userName,
                        ))),
                    const SizedBox(width: 10),
                    _statBadge(Icons.beach_access_rounded, "Plages",
                        () => _open(BeachSwipeScreen(token: widget.token))),
                    const SizedBox(width: 10),
                    _statBadge(Icons.restaurant_rounded, "Restos", () => _open(RestaurantSwipeScreen(
                          token: widget.token,
                          userId: widget.userId,
                        ))),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          

          // ── CATÉGORIES DYNAMIQUES (depuis l'API) ──
          if (categories.isNotEmpty) ...[
            const SizedBox(height: 28),
            _sectionTitle("Catégories", null),
            const SizedBox(height: 12),
            SizedBox(
              height: 95,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: categories
                    .map((c) => _categoryItem(
                          c.name,
                          _iconForCategory(c.name),
                          () => _openSearch(category: c.name),
                        ))
                    .toList(),
              ),
            ),
          ],

          const SizedBox(height: 28),

          // ── ITINÉRAIRE ──
          GestureDetector(
            onTap: () => _open(const ItineraryScreen()),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_terraDark, _terraLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Row(
                children: [
                  Icon(Icons.route_rounded, color: Colors.white, size: 34),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Créer mon itinéraire",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Un circuit jour par jour selon vos envies",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ── DESTINATIONS POPULAIRES ──
          _sectionTitle("Incontournables", "Voir tout", onAction: () => _openSearch()),
          const SizedBox(height: 12),
          ...popular.map((p) => _destinationCard(
                p["name"] ?? "",
                p["imageUrl"] ?? "",
                "${p["city"]} · ${_label(p["category"])}",
                () => openItem(context, p),
              )),

          const SizedBox(height: 28),

          // ── RECOMMANDÉS ──
          if (recommended.isNotEmpty) _sectionTitle("Recommandé pour vous", null),
          const SizedBox(height: 12),
          SizedBox(
            height: 155,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: recommended
                  .map((p) => _smallCard(
                        p["name"] ?? "",
                        p["imageUrl"] ?? "",
                        p["reason"] ?? typeLabels[p["type"]] ?? "",
                        () => openItem(context, p),
                      ))
                  .toList(),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: _bg,
      body: _currentIndex == 0
          ? homeContent
          : _currentIndex == 1
              ? MapScreen(
                  token: widget.token,
                  userId: widget.userId,
                  userName: widget.userName,
                )
              : _currentIndex == 2
                  ? const FavoritesScreen()
                  : ProfileScreen(
                      token: widget.token,
                      userId: widget.userId,
                      userName: widget.userName,
                    ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: BottomNavigationBar(
          selectedItemColor: _terraDark,
          unselectedItemColor: Colors.grey.shade400,
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 11),
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), label: "Accueil"),
            BottomNavigationBarItem(
                icon: Icon(Icons.map_rounded), label: "Carte"),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite_rounded), label: "Favoris"),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded), label: "Profil"),
          ],
        ),
      ),
    );
  }

  // ── WIDGETS HELPER ──

  String _label(dynamic category) {
    if (category == null) return "";
    final c = category.toString();
    return c[0] + c.substring(1).toLowerCase();
  }

  Widget _statBadge(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 15),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _sectionTitle(String title, String? action, {VoidCallback? onAction}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action,
                style: const TextStyle(
                  fontSize: 13,
                  color: _terra,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _categoryItem(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 82,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_terraDark, _terraLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 7),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _destinationCard(String title, String imageUrl, String tag, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: _terraLight)),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _terra.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white, size: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _smallCard(String title, String imageUrl, String tag, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      width: 145,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: _terraLight)),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    tag,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}