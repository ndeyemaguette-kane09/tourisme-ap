import 'package:flutter/material.dart';
import '../services/session.dart';
import 'my_reservations_screen.dart';
import 'login_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/favorite_service.dart';
import '../services/reservation_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'favorites_screen.dart';

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
  int? _favoriteCount;
  int? _reservationCount;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    loadProfileImage();
    _loadCounts();
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

  Future<void> _loadCounts() async {
    final favorites = await FavoriteService.getFavorites();
    List<dynamic> reservations = [];
    try {
      reservations = await ReservationService().getUserReservations(widget.userId, widget.token);
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _favoriteCount = favorites.length;
      _reservationCount = reservations.length;
    });
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
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: RefreshIndicator(
            color: AppColors.coral,
            onRefresh: _loadCounts,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              children: [
                Text("Profil", style: AppTheme.display(size: 30)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _avatar(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.userName, style: AppTheme.display(size: 22, weight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          const Text("Touche la photo pour la changer", style: TextStyle(color: AppColors.muted, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _statCard("Favoris", _favoriteCount),
                    const SizedBox(width: 12),
                    _statCard("Réservations", _reservationCount),
                  ],
                ),
                const SizedBox(height: 28),
                _sectionTitle("Mon espace"),
                _profileOption(
                  icon: Icons.luggage_outlined,
                  title: "Mes réservations",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MyReservationsScreen(userId: widget.userId, token: widget.token),
                    ),
                  ).then((_) => _loadCounts()),
                ),
                _profileOption(
                  icon: Icons.favorite_border_rounded,
                  title: "Lieux sauvegardés",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                  ).then((_) => _loadCounts()),
                ),
                const SizedBox(height: 20),
                _sectionTitle("Compte"),
                _profileOption(
                  icon: Icons.logout_rounded,
                  title: "Déconnexion",
                  isDestructive: true,
                  onTap: () {
                    Session.clear();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatar() {
    return Semantics(
      button: true,
      label: "Changer la photo de profil",
      child: GestureDetector(
        onTap: pickImage,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.coralSoft,
              backgroundImage: profileImage != null ? FileImage(profileImage!) : null,
              child: profileImage == null
                  ? Text(
                      widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : "?",
                      style: AppTheme.display(size: 28, color: AppColors.ink),
                    )
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
                child: const Icon(Icons.photo_camera_outlined, color: Colors.white, size: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, int? value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value?.toString() ?? "–", style: AppTheme.display(size: 28)),
            Text(label, style: const TextStyle(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: 1),
      ),
    );
  }

  Widget _profileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.coral : AppColors.ink;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      trailing: isDestructive ? null : const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
      onTap: onTap,
    );
  }
}
