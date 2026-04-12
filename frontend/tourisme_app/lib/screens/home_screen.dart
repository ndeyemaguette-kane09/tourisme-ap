import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'hotel_swipe_screen.dart';
import 'my_reservations_screen.dart';
import 'profile_screen.dart';

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
  int _currentIndex = 0;
  File? profileImage;

  final List<Map<String, dynamic>> places = const [
    {"title": "Dakar", "image": "https://picsum.photos/400/300?1", "tag": "Capitale"},
    {"title": "Saly", "image": "https://picsum.photos/400/300?2", "tag": "Plage"},
    {"title": "Gorée", "image": "https://picsum.photos/400/300?3", "tag": "Histoire"},
    {"title": "Lac Rose", "image": "https://picsum.photos/400/300?4", "tag": "Nature"},
    {"title": "Saint-Louis", "image": "https://picsum.photos/400/300?5", "tag": "Culture"},
    {"title": "Casamance", "image": "https://picsum.photos/400/300?6", "tag": "Aventure"},
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    String? path = prefs.getString('profile_image_${widget.userId}');
    if (path != null && mounted) {
      setState(() => profileImage = File(path));
    }
  }

  List<Map<String, dynamic>> getRandomPlaces() {
    final shuffled = List<Map<String, dynamic>>.from(places);
    shuffled.shuffle();
    return shuffled.take(3).toList();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Bonjour";
    if (hour < 18) return "Bon après-midi";
    return "Bonsoir";
  }

  String _firstName() {
    return widget.userName.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final recommended = getRandomPlaces();

    Widget homeContent = SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Header avec dégradé ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFBF360C), Color(0xFFE64A19), Color(0xFFF57C00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
  text: TextSpan(
    children: [
      TextSpan(
        text: "${_greeting()}, ",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
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
    ],
  ),
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
                    GestureDetector(
                      onTap: () => setState(() => _currentIndex = 3),
                      child: Container(
                        width: 48,
                        height: 48,
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
                // Barre de recherche dans le header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.search, color: Color(0xFFE64A19)),
                      hintText: "Rechercher une destination...",
                      hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Catégories ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Text(
              "Catégories",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4E1B00)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _categoryItem("Hôtels", Icons.hotel, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HotelSwipeScreen(
                        token: widget.token,
                        userId: widget.userId,
                      ),
                    ),
                  );
                }),
                _categoryItem("Plages", Icons.beach_access, () {}),
                _categoryItem("Restos", Icons.restaurant, () {}),
                _categoryItem("Culture", Icons.museum, () {}),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Destinations populaires ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Populaire",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4E1B00)),
                ),
                Text("Voir tout",
                    style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFFE64A19),
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _destinationCard("Dakar", "https://picsum.photos/500/300?10", "Capitale"),
          _destinationCard("Saly", "https://picsum.photos/500/300?11", "Plage"),
          _destinationCard("Île de Gorée", "https://picsum.photos/500/300?12", "Patrimoine"),

          const SizedBox(height: 24),

          // ── Recommandés ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Text(
              "Recommandé pour vous",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4E1B00)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: recommended
                  .map((p) => _smallCard(p["title"]!, p["image"]!, p["tag"]!))
                  .toList(),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: _currentIndex == 0
          ? homeContent
          : _currentIndex == 1
              ? _placeholderScreen("Carte", Icons.map)
              : _currentIndex == 2
                  ? _placeholderScreen("Favoris", Icons.favorite)
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
          selectedItemColor: const Color(0xFFBF360C),
          unselectedItemColor: Colors.grey.shade400,
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 11),
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Accueil"),
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "Carte"),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Favoris"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profil"),
          ],
        ),
      ),
    );
  }

  Widget _categoryItem(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 78,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE64A19).withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFE64A19), size: 22),
            ),
            const SizedBox(height: 6),
            Text(title,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4E1B00))),
          ],
        ),
      ),
    );
  }

  Widget _destinationCard(String title, String imageUrl, String tag) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      height: 175,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE64A19).withOpacity(0.85),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(tag,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
            // Titre + favoris
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_border,
                      color: Colors.white, size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallCard(String title, String imageUrl, String tag) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
            Text(tag,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.80), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _placeholderScreen(String label, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Color(0xFFE64A19).withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(label,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade400)),
          Text("Bientôt disponible",
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}