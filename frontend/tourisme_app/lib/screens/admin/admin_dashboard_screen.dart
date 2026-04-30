import 'package:flutter/material.dart';
import 'package:tourisme_app/screens/admin/AddRestaurantScreen.dart';
import 'package:tourisme_app/screens/admin/manage_restaurants_screen.dart';
import 'add_hotel_screen.dart';
import 'add_beach_screen.dart';
import 'manage_hotels_screen.dart';
import 'manage_beaches_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String token;
  const AdminDashboardScreen({super.key, required this.token});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: Stack(
        children: [
          // Décoration de fond
          Positioned(
            top: -60,
            right: -60,
            child: _decorCircle(200, Colors.orange.withOpacity(0.07)),
          ),
          Positioned(
            top: 150,
            left: -40,
            child: _decorCircle(120, Colors.deepOrange.withOpacity(0.04)),
          ),
          Positioned(
            bottom: 100,
            right: -30,
            child: _decorCircle(160, Colors.orange.withOpacity(0.05)),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Header avec gradient
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
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
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x40BF360C),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.dashboard_customize,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Dashboard Admin",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Gérez votre plateforme touristique",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Statistiques rapides
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Row(
                        children: [
                          Expanded(
                            child: _statCard(
                              icon: Icons.hotel,
                              count: "12",
                              label: "Hôtels",
                              color: const Color(0xFFE64A19),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _statCard(
                              icon: Icons.restaurant,
                              count: "8",
                              label: "Restaurants",
                              color: const Color(0xFFFF6F00),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _statCard(
                              icon: Icons.beach_access,
                              count: "5",
                              label: "Plages",
                              color: const Color(0xFFF57C00),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 22),
                      child: Row(
                        children: [
                          Icon(
                            Icons.flash_on,
                            color: Color(0xFFBF360C),
                            size: 22,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Actions rapides",
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4E1B00),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Boutons d'actions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        children: [
                          _adminActionCard(
                            context,
                            title: "Ajouter un hôtel",
                            subtitle: "Créer un nouvel hébergement",
                            icon: Icons.hotel,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFBF360C), Color(0xFFE64A19)],
                            ),
                            screen: AddHotelScreen(token: widget.token),
                          ),
                          _adminActionCard(
                            context,
                            title: "Ajouter un restaurant",
                            subtitle: "Référencer un établissement",
                            icon: Icons.restaurant,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE64A19), Color(0xFFFF6F00)],
                            ),
                            screen: AddRestaurantScreen(token: widget.token),
                          ),
                          _adminActionCard(
                            context,
                            title: "Ajouter une plage",
                            subtitle: "Enregistrer un site balnéaire",
                            icon: Icons.beach_access,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6F00), Color(0xFFF57C00)],
                            ),
                            screen: AddBeachScreen(token: widget.token),
                          ),
                          _adminActionCard(
                            context,
                            title: "Gérer les hôtels",
                            subtitle: "Modifier ou supprimer",
                            icon: Icons.hotel_class,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF57C00), Color(0xFFFF8A50)],
                            ),
                            screen: ManageHotelsScreen(token: widget.token),
                          ),
                          _adminActionCard(
                            context,
                            title: "Gérer les restaurants",
                            subtitle: "Modifier ou supprimer",
                            icon: Icons.restaurant_menu,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF7043), Color(0xFFFFA726)],
                            ),
                            screen: ManageRestaurantsScreen(token: widget.token)
                          ),
                          _adminActionCard(
                            context,
                            title: "Gérer les plages",
                            subtitle: "Modifier ou supprimer",
                            icon: Icons.beach_access,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF8A65), Color(0xFFFFB74D)],
                            ),
                            screen: ManageBeachesScreen(token: widget.token),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Footer avec branding
                    Center(
                      child: Text(
                        "🇸🇳 Teranga • Culture • Découverte",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            count,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _adminActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required Widget screen,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBF360C).withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screen),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _decorCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}