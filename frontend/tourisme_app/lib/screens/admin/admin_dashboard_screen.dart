import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../services/beach_service.dart';
import '../../services/hotel_service.dart';
import '../../services/place_service.dart';
import '../../services/restaurant_service.dart';
import '../../services/session.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../login_screen.dart';
import 'manage_beaches_screen.dart';
import 'manage_hotels_screen.dart';
import 'manage_places_screen.dart';
import 'manage_reservations_screen.dart';
import 'manage_restaurants_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String token;
  const AdminDashboardScreen({super.key, required this.token});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final Map<String, int?> counts = {};
  int? pending;

  @override
  void initState() {
    super.initState();
    loadCounts();
  }

  Future<int?> _count(Future<List> Function() load) async {
    try {
      return (await load()).length;
    } catch (_) {
      return null;
    }
  }

  Future<void> loadCounts() async {
    final token = widget.token;
    final results = await Future.wait([
      _count(() => PlaceService().getPlaces(token)),
      _count(() => HotelService().getHotels(token)),
      _count(() => RestaurantService().getRestaurants(token)),
      _count(() => BeachService().getBeaches(token)),
    ]);

    int? waiting;
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/reservations"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        final List all = jsonDecode(utf8.decode(response.bodyBytes));
        waiting = all.where((r) => r["status"] == "EN_ATTENTE").length;
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      counts["places"] = results[0];
      counts["hotels"] = results[1];
      counts["restaurants"] = results[2];
      counts["beaches"] = results[3];
      pending = waiting;
    });
  }

  Future<void> open(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    loadCounts();
  }

  void logout() {
    Session.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final token = widget.token;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.coral,
          onRefresh: loadCounts,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text.rich(TextSpan(
                      text: "Cap Teranga",
                      style: AppTheme.display(size: 26),
                      children: [TextSpan(text: ".", style: AppTheme.display(size: 26, color: AppColors.coral))],
                    )),
                  ),
                  IconButton(
                    tooltip: "Déconnexion",
                    onPressed: logout,
                    icon: const Icon(Icons.logout_rounded, color: AppColors.ink),
                  ),
                ],
              ),
              const Text("Espace administration", style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 20),
              _pendingBanner(token),
              const SizedBox(height: 20),
              Text("Catalogue", style: AppTheme.display(size: 18, weight: FontWeight.w700)),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.25,
                children: [
                  _tile("Lieux", Icons.account_balance_rounded, counts["places"], ManagePlacesScreen(token: token)),
                  _tile("Hôtels", Icons.hotel_rounded, counts["hotels"], ManageHotelsScreen(token: token)),
                  _tile("Restaurants", Icons.restaurant_rounded, counts["restaurants"],
                      ManageRestaurantsScreen(token: token)),
                  _tile("Plages", Icons.beach_access_rounded, counts["beaches"], ManageBeachesScreen(token: token)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pendingBanner(String token) {
    final n = pending;
    final text = n == null
        ? "Réservations"
        : n == 0
            ? "Aucune réservation en attente"
            : "$n réservation${n > 1 ? 's' : ''} en attente";
    return Material(
      color: AppColors.ink,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => open(ManageReservationsScreen(token: token)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: AppColors.coral, shape: BoxShape.circle),
                child: const Icon(Icons.event_note_rounded, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(text, style: AppTheme.display(size: 17, weight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 2),
                    const Text("Confirmer ou annuler les demandes",
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(String label, IconData icon, int? count, Widget screen) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => open(screen),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.coral),
              const Spacer(),
              Text(count?.toString() ?? "–", style: AppTheme.display(size: 28)),
              Text(label, style: const TextStyle(color: AppColors.muted)),
            ],
          ),
        ),
      ),
    );
  }
}
