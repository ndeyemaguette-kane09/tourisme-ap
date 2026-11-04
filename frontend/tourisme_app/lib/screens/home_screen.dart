import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'hotel_swipe_screen.dart';
import 'restaurant_swipe_screen.dart';
import 'beach_swipe_screen.dart';
import 'profile_screen.dart';
import 'favorites_screen.dart';
import 'map_screen.dart';
import 'search_screen.dart';
import 'itinerary_screen.dart';
import 'events_screen.dart';
import '../services/discover_service.dart';
import '../services/event_service.dart';
import '../services/favorite_service.dart';
import '../widgets/motion.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/item_navigation.dart';
import '../widgets/net_image.dart';
import '../widgets/pill_nav_bar.dart';

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

  static const _navItems = [
    PillNavItem(Icons.home_rounded, "Accueil"),
    PillNavItem(Icons.map_outlined, "Carte"),
    PillNavItem(Icons.route_rounded, "Circuit"),
    PillNavItem(Icons.favorite_border_rounded, "Favoris"),
    PillNavItem(Icons.person_outline_rounded, "Profil"),
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_${widget.userId}');
    if (path != null && mounted) {
      setState(() => profileImage = File(path));
    }
  }

  Widget _page() {
    switch (_currentIndex) {
      case 1:
        return MapScreen(token: widget.token, userId: widget.userId, userName: widget.userName);
      case 2:
        return const ItineraryScreen();
      case 3:
        return const FavoritesScreen();
      case 4:
        return ProfileScreen(token: widget.token, userId: widget.userId, userName: widget.userName);
      default:
        return _HomeTab(
          token: widget.token,
          userId: widget.userId,
          userName: widget.userName,
          profileImage: profileImage,
          onOpenTab: (i) => setState(() => _currentIndex = i),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(bottom: _currentIndex == 0 ? 0 : 96),
              child: _page(),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 22,
            child: SafeArea(
              top: false,
              child: PillNavBar(
                currentIndex: _currentIndex,
                items: _navItems,
                onTap: (i) => setState(() => _currentIndex = i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  final String token;
  final int userId;
  final String userName;
  final File? profileImage;
  final ValueChanged<int> onOpenTab;

  const _HomeTab({
    required this.token,
    required this.userId,
    required this.userName,
    required this.profileImage,
    required this.onOpenTab,
  });

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  static const _filters = [
    ("Tout", null, "À ne pas manquer"),
    ("Histoire", "HISTORIQUE", "Sites historiques"),
    ("Spirituel", "RELIGIEUX", "Lieux religieux"),
    ("Nature", "NATURE", "Grands espaces"),
    ("Culture", "CULTUREL", "Culture et artisanat"),
    ("Aventure", "AVENTURE", "Pour les aventuriers"),
  ];

  int _filter = 0;
  int _slide = 0;
  bool _loading = true;
  List<Map<String, dynamic>> _featured = [];
  List<Map<String, dynamic>> _recommended = [];
  Map<String, dynamic>? _nextEvent;
  final _pageController = PageController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadFeatured();
    _loadRecommended();
    _loadNextEvent();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _nextSlide());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _nextSlide() {
    if (!mounted || _featured.isEmpty || !_pageController.hasClients) return;
    final next = (_slide + 1) % _featured.length;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _loadFeatured() async {
    setState(() => _loading = true);
    try {
      final data = await DiscoverService.search(type: "place", category: _filters[_filter].$2);
      if (!mounted) return;
      setState(() {
        _featured = data.take(5).toList();
        _slide = 0;
        _loading = false;
      });
      if (_pageController.hasClients) _pageController.jumpToPage(0);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadRecommended() async {
    try {
      final data = await DiscoverService.recommendations(limit: 8);
      if (mounted) setState(() => _recommended = data);
    } catch (e) {
      debugPrint("ERREUR RECOMMANDATIONS: $e");
    }
  }

  Future<void> _loadNextEvent() async {
    try {
      final events = await EventService.getUpcoming();
      if (mounted && events.isNotEmpty) setState(() => _nextEvent = events.first);
    } catch (_) {}
  }

  void _open(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  String _initials() {
    final parts = widget.userName.trim().split(RegExp(r"\s+")).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return "?";
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: AppColors.laterite,
        onRefresh: () async {
          await Future.wait([_loadFeatured(), _loadRecommended()]);
        },
        child: ListView(
          padding: const EdgeInsets.only(top: 16, bottom: 120),
          children: [
            FadeSlideIn(index: 0, child: _header()),
            const SizedBox(height: 18),
            FadeSlideIn(index: 1, child: _searchBar()),
            const SizedBox(height: 16),
            FadeSlideIn(index: 2, child: _filterChips()),
            const SizedBox(height: 16),
            FadeSlideIn(index: 3, child: _carousel()),
            const SizedBox(height: 16),
            FadeSlideIn(index: 4, child: _quickLinks()),
            const SizedBox(height: 24),
            if (_recommended.isNotEmpty) ...[
              _sectionTitle("Pour toi", onMore: () => _open(const SearchScreen())),
              const SizedBox(height: 12),
              _recommendedList(),
              const SizedBox(height: 24),
            ],
            if (_nextEvent != null) ...[
              _eventBanner(_nextEvent!),
              const SizedBox(height: 12),
            ],
            _itineraryBanner(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                text: "Cap Teranga",
                style: AppTheme.display(size: 26),
                children: [TextSpan(text: ".", style: AppTheme.display(size: 26, color: AppColors.laterite))],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => widget.onOpenTab(4),
            child: Semantics(
              button: true,
              label: "Mon profil",
              child: CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.laterite,
                backgroundImage: widget.profileImage != null ? FileImage(widget.profileImage!) : null,
                child: widget.profileImage == null
                    ? Text(_initials(), style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink))
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: AppColors.field,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: AppColors.line),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () => _open(const SearchScreen()),
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                const SizedBox(width: 18),
                const Icon(Icons.search_rounded, color: AppColors.ink),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text("Où veux-tu aller ?", style: TextStyle(fontSize: 16, color: AppColors.muted)),
                ),
                Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: const BoxDecoration(color: AppColors.ink, shape: BoxShape.circle),
                  child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final on = i == _filter;
          return GestureDetector(
            onTap: () {
              if (on) return;
              setState(() => _filter = i);
              _loadFeatured();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? AppColors.ink : AppColors.field,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: on ? AppColors.ink : AppColors.line),
              ),
              child: Text(
                _filters[i].$1,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: on ? Colors.white : AppColors.ink,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _carousel() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Skeleton(height: 320, radius: 28),
      );
    }
    if (_featured.isEmpty) {
      return const SizedBox(height: 120, child: Center(child: Text("Aucun lieu pour ce filtre pour le moment")));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(
          height: 320,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: _featured.length,
                onPageChanged: (i) => setState(() => _slide = i),
                itemBuilder: (context, i) => _slideCard(_featured[i]),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 14,
                child: Row(
                  children: List.generate(_featured.length, (i) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _pageController.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                        ),
                        child: Container(
                          height: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: i <= _slide ? Colors.white : Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _slideCard(Map<String, dynamic> item) {
    final category = item["subType"] ?? _label(item["category"]);
    return GestureDetector(
      onTap: () => openItem(context, item),
      child: Stack(
        fit: StackFit.expand,
        children: [
          NetImage(url: item["imageUrl"], seed: item["name"], heroTag: "img-${item["type"]}-${item["id"]}"),
          DecoratedBox(
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.32)),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: _FavoriteButton(item: item),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (category.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(category, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                const SizedBox(height: 8),
                Text(item["name"] ?? "", style: AppTheme.display(size: 30, color: Colors.white)),
                const SizedBox(height: 6),
                Text(
                  _meta(item),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _meta(Map<String, dynamic> item) {
    final parts = <String>[if ((item["city"] ?? "").toString().isNotEmpty) item["city"]];
    final d = item["visitDuration"];
    if (d is num) parts.add("${d % 1 == 0 ? d.toInt() : d} h de visite");
    return parts.join(" · ");
  }

  String _label(dynamic category) {
    if (category == null) return "";
    final c = category.toString();
    return c[0] + c.substring(1).toLowerCase();
  }

  Widget _quickLinks() {
    Widget link(IconData icon, String label, Widget screen) {
      return Expanded(
        child: OutlinedButton.icon(
          onPressed: () => _open(screen),
          icon: Icon(icon, size: 18, color: AppColors.ink),
          label: Text(label, style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 46),
            side: const BorderSide(color: AppColors.line),
            backgroundColor: AppColors.field,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          link(Icons.hotel_rounded, "Hôtels",
              HotelSwipeScreen(token: widget.token, userId: widget.userId, userName: widget.userName)),
          const SizedBox(width: 8),
          link(Icons.beach_access_rounded, "Plages", BeachSwipeScreen(token: widget.token)),
          const SizedBox(width: 8),
          link(Icons.restaurant_rounded, "Restos", RestaurantSwipeScreen(token: widget.token, userId: widget.userId)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, {VoidCallback? onMore}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTheme.display(size: 21, weight: FontWeight.w700))),
          if (onMore != null)
            TextButton(
              onPressed: onMore,
              child: const Text("Tout voir", style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _recommendedList() {
    return SizedBox(
      height: 196,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _recommended.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final item = _recommended[i];
          return FadeSlideIn(
            index: i,
            offset: 0,
            child: GestureDetector(
            onTap: () => openItem(context, item),
            child: SizedBox(
              width: 156,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NetImage(
                    url: item["imageUrl"],
                    seed: item["name"],
                    icon: typeIcons[item["type"]] ?? Icons.place_rounded,
                    radius: BorderRadius.circular(18),
                    width: 156,
                    height: 112,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item["name"] ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  Text(
                    item["reason"] ?? item["city"] ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ),
          );
        },
      ),
    );
  }

  Widget _eventBanner(Map<String, dynamic> event) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _open(const EventsScreen()),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PROCHAIN GRAND RENDEZ-VOUS · ${EventService.countdown(event).toUpperCase()}",
                        style: const TextStyle(color: AppColors.lateriteSoft, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 6),
                      Text(event["name"] ?? "", style: AppTheme.display(size: 19, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(
                        "${EventService.dateLabel(event)} · ${event["city"] ?? ""}",
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.calendar_month_rounded, color: AppColors.laterite, size: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _itineraryBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: AppColors.laterite,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => widget.onOpenTab(2),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Trace ton circuit", style: AppTheme.display(size: 20, color: AppColors.ink)),
                      const SizedBox(height: 4),
                      const Text(
                        "Tes jours, tes envies : on s'occupe des étapes.",
                        style: TextStyle(color: AppColors.ink, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(color: AppColors.ink, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  final Map<String, dynamic> item;

  const _FavoriteButton({required this.item});

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  bool _added = false;

  Future<void> _toggle() async {
    final item = widget.item;
    final fav = {
      "id": item["id"],
      "type": item["type"],
      "title": item["name"],
      "image": item["imageUrl"],
      "subtitle": item["city"] ?? "",
      "city": item["city"] ?? "",
    };
    if (_added) {
      await FavoriteService.removeFavorite(fav);
    } else {
      await FavoriteService.addFavorite(fav);
    }
    if (mounted) setState(() => _added = !_added);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: _added ? "Retirer des favoris" : "Ajouter aux favoris",
      child: GestureDetector(
        onTap: _toggle,
        child: PopOnChange(
          active: _added,
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
            child: Icon(
              _added ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _added ? AppColors.laterite : AppColors.ink,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
