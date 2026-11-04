import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/beach.dart';
import '../models/hotel.dart';
import '../models/restaurant.dart';
import '../services/beach_service.dart';
import '../services/hotel_service.dart';
import '../services/restaurant_service.dart';
import 'beach_details_screen.dart';
import 'hotel_details_screen.dart';
import 'restaurant_details_screen.dart';

class MapScreen extends StatefulWidget {
  final String token;
  final int userId;
  final String userName;

  const MapScreen({
    super.key,
    required this.token,
    required this.userId,
    required this.userName,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  GoogleMapController? _mapController;

  // ── Données ──
  List<Beach> beaches = [];
  List<Hotel> hotels = [];
  List<Restaurant> restaurants = [];
  Set<Marker> _markers = {};
  bool isLoading = true;

  // ── Filtres actifs ──
  bool _showBeaches = true;
  bool _showHotels = true;
  bool _showRestaurants = true;

  // ── Item sélectionné ──
  dynamic _selectedItem; // Beach | Hotel | Restaurant | null
  String _selectedType = '';

  // ── Animation bottom sheet ──
  late AnimationController _sheetController;
  late Animation<Offset> _sheetAnim;

  // ── Palette Teranga ──
  static const Color _orange = Color(0xFFE64A19);
  static const Color _orangeDark = Color(0xFFBF360C);
  static const Color _orangeLight = Color(0xFFF57C00);
  static const Color _cream = Color(0xFFFFF8F0);
  static const Color _amber = Color(0xFFFFF3E0);

  // Centre Sénégal (Dakar)
  static const LatLng _senegalCenter = LatLng(14.6928, -17.4467);

  @override
  void initState() {
    super.initState();
    _sheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _sheetAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _sheetController, curve: Curves.easeOutCubic));

    _loadAll();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // ── CHARGEMENT ──
  Future<void> _loadAll() async {
    try {
      final results = await Future.wait([
        BeachService().getBeaches(widget.token).catchError((_) => <Beach>[]),
        HotelService().getHotels(widget.token).catchError((_) => <Hotel>[]),
        RestaurantService()
            .getRestaurants(widget.token)
            .catchError((_) => <Restaurant>[]),
      ]);

      beaches = (results[0] as List).cast<Beach>();
      hotels = (results[1] as List).cast<Hotel>();
      restaurants = (results[2] as List).cast<Restaurant>();
    } catch (_) {}

    if (mounted) {
      setState(() => isLoading = false);
      _buildMarkers();
    }
  }

  // ── CONSTRUCTION DES MARKERS ──
  Future<void> _buildMarkers() async {
    final Set<Marker> markers = {};

    if (_showBeaches) {
      for (final beach in beaches) {
        if (beach.latitude == null || beach.longitude == null) continue;
        markers.add(Marker(
          markerId: MarkerId('beach_${beach.id}'),
          position: LatLng(beach.latitude!, beach.longitude!),
          icon: await _markerIcon(_orange),
          infoWindow: InfoWindow(title: beach.name, snippet: beach.city),
          onTap: () => _onMarkerTap(beach, 'beach'),
        ));
      }
    }

    if (_showHotels) {
      for (final hotel in hotels) {
        if (hotel.latitude == null || hotel.longitude == null) continue;
        markers.add(Marker(
          markerId: MarkerId('hotel_${hotel.id}'),
          position: LatLng(hotel.latitude!, hotel.longitude!),
          icon: await _markerIcon(const Color(0xFF1565C0)),
          infoWindow: InfoWindow(title: hotel.name, snippet: hotel.city),
          onTap: () => _onMarkerTap(hotel, 'hotel'),
        ));
      }
    }

    if (_showRestaurants) {
      for (final restaurant in restaurants) {
        if (restaurant.latitude == null || restaurant.longitude == null) {
          continue;
        }
        markers.add(Marker(
          markerId: MarkerId('restaurant_${restaurant.id}'),
          position: LatLng(restaurant.latitude!, restaurant.longitude!),
          icon: await _markerIcon(const Color(0xFF2E7D32)),
          infoWindow:
              InfoWindow(title: restaurant.name, snippet: restaurant.city),
          onTap: () => _onMarkerTap(restaurant, 'restaurant'),
        ));
      }
    }

    if (mounted) setState(() => _markers = markers);
  }

  // Crée une icône de marker colorée
  Future<BitmapDescriptor> _markerIcon(Color color) async {
    return BitmapDescriptor.defaultMarkerWithHue(
      _colorToHue(color),
    );
  }

  double _colorToHue(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.hue;
  }

  // ── SÉLECTION D'UN MARKER ──
  void _onMarkerTap(dynamic item, String type) {
    setState(() {
      _selectedItem = item;
      _selectedType = type;
    });
    _sheetController.forward();
  }

  void _closeSheet() {
    _sheetController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _selectedItem = null;
          _selectedType = '';
        });
      }
    });
  }

  void _toggleFilter(String type) {
    setState(() {
      if (type == 'beach') _showBeaches = !_showBeaches;
      if (type == 'hotel') _showHotels = !_showHotels;
      if (type == 'restaurant') _showRestaurants = !_showRestaurants;
    });
    _buildMarkers();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: _cream,
      body: Stack(
        children: [
          // ── CARTE GOOGLE MAPS ──
          isLoading
              ? _buildLoader()
              : GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: _senegalCenter,
                    zoom: 7.0,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                    // Style de carte personnalisé (optionnel)
                    // controller.setMapStyle(_mapStyle);
                  },
                  markers: _markers,
                  onTap: (_) => _closeSheet(),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                ),

          // ── HEADER GRADIENT ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _orangeDark,
                    _orange.withOpacity(0.95),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      // Bouton retour
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.2)),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 17),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Titre
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Carte du Sénégal",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              "🇸🇳 Explorez plages, hôtels et restaurants",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Bouton recentrer
                      GestureDetector(
                        onTap: () {
                          _mapController?.animateCamera(
                            CameraUpdate.newCameraPosition(
                              const CameraPosition(
                                  target: _senegalCenter, zoom: 7.0),
                            ),
                          );
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.2)),
                          ),
                          child: const Icon(Icons.my_location_rounded,
                              color: Colors.white, size: 19),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── FILTRES (pills flottantes) ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _filterChip(
                    label: "Plages",
                    icon: Icons.beach_access_rounded,
                    color: _orange,
                    active: _showBeaches,
                    onTap: () => _toggleFilter('beach'),
                  ),
                  const SizedBox(width: 10),
                  _filterChip(
                    label: "Hôtels",
                    icon: Icons.hotel_rounded,
                    color: const Color(0xFF1565C0),
                    active: _showHotels,
                    onTap: () => _toggleFilter('hotel'),
                  ),
                  const SizedBox(width: 10),
                  _filterChip(
                    label: "Restaurants",
                    icon: Icons.restaurant_rounded,
                    color: const Color(0xFF2E7D32),
                    active: _showRestaurants,
                    onTap: () => _toggleFilter('restaurant'),
                  ),
                ],
              ),
            ),
          ),

          // ── BOTTOM SHEET DÉTAIL ──
          if (_selectedItem != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _sheetAnim,
                child: _buildDetailSheet(),
              ),
            ),

          // ── LÉGENDE ──
          Positioned(
            bottom: _selectedItem != null ? 200 : 20,
            right: 16,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _legendItem(_orange, Icons.beach_access_rounded, "Plage"),
                  const SizedBox(height: 8),
                  _legendItem(
                      const Color(0xFF1565C0), Icons.hotel_rounded, "Hôtel"),
                  const SizedBox(height: 8),
                  _legendItem(const Color(0xFF2E7D32),
                      Icons.restaurant_rounded, "Resto"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── CHIP FILTRE ──
  Widget _filterChip({
    required String label,
    required IconData icon,
    required Color color,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? color : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: active
                  ? color.withOpacity(0.35)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: active ? Colors.white : Colors.grey.shade500,
                size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.grey.shade600,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── LÉGENDE ITEM ──
  Widget _legendItem(Color color, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 15),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  // ── BOTTOM SHEET DÉTAIL ──
  Widget _buildDetailSheet() {
    final String name = _getName();
    final String city = _getCity();
    final double rating = _getRating();
    final String imageUrl = _getImageUrl();
    final Color typeColor = _getTypeColor();
    final IconData typeIcon = _getTypeIcon();
    final String typeLabel = _getTypeLabel();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── IMAGE + INFOS ──
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Stack(
              children: [
                SizedBox(
                  height: 130,
                  width: double.infinity,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: _amber,
                      child: Center(
                        child: Icon(typeIcon, color: typeColor, size: 40),
                      ),
                    ),
                  ),
                ),
                // Gradient
                Container(
                  height: 130,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Fermer
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: _closeSheet,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ),
                // Badge type
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: typeColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(typeIcon, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          typeLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Nom en bas de l'image
                Positioned(
                  bottom: 12,
                  left: 16,
                  right: 16,
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // ── INFOS + BOUTON ──
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Row(
              children: [
                // Localisation + note
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              color: Colors.grey.shade400, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            city,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Color(0xFFF57C00), size: 15),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Bouton voir détails
                GestureDetector(
                  onTap: _navigateToDetail,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
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
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          "Voir détails",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── NAVIGATION VERS LE DÉTAIL ──
  void _navigateToDetail() {
    if (_selectedType == 'beach') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BeachDetailsScreen(beach: _selectedItem as Beach),
        ),
      );
    } else if (_selectedType == 'hotel') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HotelDetailsScreen(
            hotel: _selectedItem as Hotel,
            userId: widget.userId,
            token: widget.token,
            userName: widget.userName,
          ),
        ),
      );
    } else if (_selectedType == 'restaurant') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RestaurantDetailsScreen(
              restaurant: _selectedItem as Restaurant),
        ),
      );
    }
  }

  // ── HELPERS ──
  String _getName() {
    if (_selectedType == 'beach') return (_selectedItem as Beach).name;
    if (_selectedType == 'hotel') return (_selectedItem as Hotel).name;
    if (_selectedType == 'restaurant') return (_selectedItem as Restaurant).name;
    return '';
  }

  String _getCity() {
    if (_selectedType == 'beach') return (_selectedItem as Beach).city;
    if (_selectedType == 'hotel') return (_selectedItem as Hotel).city;
    if (_selectedType == 'restaurant') return (_selectedItem as Restaurant).city;
    return '';
  }

  double _getRating() {
    if (_selectedType == 'beach') return (_selectedItem as Beach).rating;
    if (_selectedType == 'hotel') return (_selectedItem as Hotel).rating;
    if (_selectedType == 'restaurant') return (_selectedItem as Restaurant).rating;
    return 0;
  }

  String _getImageUrl() {
    if (_selectedType == 'beach') return (_selectedItem as Beach).imageUrl;
    if (_selectedType == 'hotel') return (_selectedItem as Hotel).imageUrl;
    if (_selectedType == 'restaurant') return (_selectedItem as Restaurant).imageUrl;
    return '';
  }

  Color _getTypeColor() {
    if (_selectedType == 'beach') return _orange;
    if (_selectedType == 'hotel') return const Color(0xFF1565C0);
    if (_selectedType == 'restaurant') return const Color(0xFF2E7D32);
    return _orange;
  }

  IconData _getTypeIcon() {
    if (_selectedType == 'beach') return Icons.beach_access_rounded;
    if (_selectedType == 'hotel') return Icons.hotel_rounded;
    if (_selectedType == 'restaurant') return Icons.restaurant_rounded;
    return Icons.place_rounded;
  }

  String _getTypeLabel() {
    if (_selectedType == 'beach') return 'Plage';
    if (_selectedType == 'hotel') return 'Hôtel';
    if (_selectedType == 'restaurant') return 'Restaurant';
    return '';
  }

  Widget _buildLoader() {
    return Container(
      color: _cream,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(colors: [_orange, _orangeLight]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.map_rounded,
                  color: Colors.white, size: 32),
            ),
            const SizedBox(height: 20),
            const Text(
              "Chargement de la carte…",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}