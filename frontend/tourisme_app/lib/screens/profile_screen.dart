import 'package:flutter/material.dart';
import 'my_reservations_screen.dart';
import 'login_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final String token;
  final int userId;
  final String userName;

  const ProfileScreen({
    super.key,
    required this.token,
    required this.userId,
    required this.userName,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  File? profileImage;
  final ImagePicker picker = ImagePicker();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    loadProfileImage();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    String? path = prefs.getString('profile_image_${widget.userId}');
    if (path != null && mounted) {
      setState(() => profileImage = File(path));
    }
  }

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => profileImage = File(image.path));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_${widget.userId}', image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            // ── AppBar avec fond dégradé ──
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xFFBF360C),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    // Fond dégradé
                    Container(
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
                      ),
                    ),
                    // Pattern africain
                    Positioned.fill(
                      child: CustomPaint(painter: _AfricanPatternPainter()),
                    ),
                    // Cercles déco
                    Positioned(
                      top: -40,
                      right: -40,
                      child: _decorCircle(160, Colors.white.withOpacity(0.06)),
                    ),
                    Positioned(
                      bottom: -20,
                      left: -30,
                      child: _decorCircle(120, Colors.amber.withOpacity(0.08)),
                    ),
                    // Contenu header
                    SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          // Photo de profil
                          GestureDetector(
                            onTap: pickImage,
                            child: Stack(
                              children: [
                                Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 12,
                                      )
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: profileImage != null
                                        ? Image.file(profileImage!,
                                            fit: BoxFit.cover)
                                        : Container(
                                            color: Colors.white.withOpacity(0.2),
                                            child: const Icon(Icons.person,
                                                color: Colors.white, size: 52),
                                          ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4E1B00),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(Icons.camera_alt,
                                        color: Colors.white, size: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.userName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "🇸🇳 Explorateur du Sénégal",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.80),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Stats rapides ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    _statCard("Voyages", "0", Icons.flight_takeoff),
                    const SizedBox(width: 12),
                    _statCard("Favoris", "0", Icons.favorite),
                    const SizedBox(width: 12),
                    _statCard("Avis", "0", Icons.star),
                  ],
                ),
              ),
            ),

            // ── Options ──
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _sectionTitle("Mon espace"),
                  const SizedBox(height: 10),
                  _profileOption(
                    icon: Icons.luggage,
                    title: "Mes réservations",
                    subtitle: "Voir tous vos voyages",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MyReservationsScreen(
                          userId: widget.userId,
                          token: widget.token,
                        ),
                      ),
                    ),
                  ),
                  _profileOption(
                    icon: Icons.favorite_border,
                    title: "Lieux sauvegardés",
                    subtitle: "Vos destinations favorites",
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle("Compte"),
                  const SizedBox(height: 10),
                  _profileOption(
                    icon: Icons.payment,
                    title: "Paiements",
                    subtitle: "Gérer vos moyens de paiement",
                    onTap: () {},
                  ),
                  _profileOption(
                    icon: Icons.settings_outlined,
                    title: "Paramètres",
                    subtitle: "Modifier votre compte",
                    onTap: () {},
                  ),
                  _profileOption(
                    icon: Icons.logout,
                    title: "Déconnexion",
                    subtitle: "À bientôt !",
                    onTap: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    ),
                    isDestructive: true,
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      "🇸🇳  Teranga • Culture • Découverte",
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFE64A19), size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4E1B00))),
            Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF4E1B00),
      ),
    );
  }

  Widget _profileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? const Color(0xFFBF360C) : const Color(0xFFE64A19);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDestructive
                              ? const Color(0xFFBF360C)
                              : const Color(0xFF2D1200))),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _decorCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _AfricanPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    const spacing = 55.0;
    const diagSize = 14.0;
    for (double y = 0; y < size.height + spacing; y += spacing) {
      for (double x = 0; x < size.width + spacing; x += spacing) {
        final path = Path();
        path.moveTo(x, y - diagSize);
        path.lineTo(x + diagSize, y);
        path.lineTo(x, y + diagSize);
        path.lineTo(x - diagSize, y);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_AfricanPatternPainter old) => false;
}