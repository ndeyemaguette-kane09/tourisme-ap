import 'package:flutter/material.dart';
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
import '../services/discover_service.dart';
import '../widgets/item_navigation.dart';
import '../widgets/net_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

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
  List<Map<String, dynamic>> places = [];
  Set<Marker> _markers = {};
  bool isLoading = true;

  // ── Filtres actifs ──
  bool _showBeaches = true;
  bool _showHotels = true;
  bool _showRestaurants = true;
  bool _showPlaces = true;

  // ── Item sélectionné ──
  dynamic _selectedItem; // Beach | Hotel | Restaurant | null
  String _selectedType = '';

  // ── Animation bottom sheet ──
  late AnimationController _sheetController;
  late Animation<Offset> _sheetAnim;

  static const _typeColors = {
    'beach': Color(0xFF1F5C78),
    'hotel': Color(0xFFA86A24),
    'restaurant': Color(0xFF5E7D5A),
    'place': AppColors.laterite,
  };

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
        DiscoverService.search(type: "place")
            .catchError((_) => <Map<String, dynamic>>[]),
      ]);

      beaches = (results[0] as List).cast<Beach>();
      hotels = (results[1] as List).cast<Hotel>();
      restaurants = (results[2] as List).cast<Restaurant>();
      places = (results[3] as List).cast<Map<String, dynamic>>();
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
        if (beach.latitude == 0 && beach.longitude == 0) continue;
        markers.add(Marker(
          markerId: MarkerId('beach_${beach.id}'),
          position: LatLng(beach.latitude, beach.longitude),
          icon: await _markerIcon(_typeColors['beach']!),
          infoWindow: InfoWindow(title: beach.name, snippet: beach.city),
          onTap: () => _onMarkerTap(beach, 'beach'),
        ));
      }
    }

    if (_showHotels) {
      for (final hotel in hotels) {
        if (hotel.latitude == 0 && hotel.longitude == 0) continue;
        markers.add(Marker(
          markerId: MarkerId('hotel_${hotel.id}'),
          position: LatLng(hotel.latitude, hotel.longitude),
          icon: await _markerIcon(_typeColors['hotel']!),
          infoWindow: InfoWindow(title: hotel.name, snippet: hotel.city),
          onTap: () => _onMarkerTap(hotel, 'hotel'),
        ));
      }
    }

    if (_showRestaurants) {
      for (final restaurant in restaurants) {
        if (restaurant.latitude == 0 && restaurant.longitude == 0) {
          continue;
        }
        markers.add(Marker(
          markerId: MarkerId('restaurant_${restaurant.id}'),
          position: LatLng(restaurant.latitude, restaurant.longitude),
          icon: await _markerIcon(_typeColors['restaurant']!),
          infoWindow:
              InfoWindow(title: restaurant.name, snippet: restaurant.city),
          onTap: () => _onMarkerTap(restaurant, 'restaurant'),
        ));
      }
    }

    if (_showPlaces) {
      for (final place in places) {
        if (place["latitude"] == null || place["longitude"] == null) continue;
        markers.add(Marker(
          markerId: MarkerId('place_${place["id"]}'),
          position: LatLng(
            (place["latitude"] as num).toDouble(),
            (place["longitude"] as num).toDouble(),
          ),
          icon: await _markerIcon(_typeColors['place']!),
          infoWindow: InfoWindow(
            title: place["name"],
            snippet: "${place["city"]} · voir la fiche",
            onTap: () => openItem(context, place),
          ),
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
      if (type == 'place') _showPlaces = !_showPlaces;
    });
    _buildMarkers();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.laterite))
              : GoogleMap(
                  initialCameraPosition: const CameraPosition(target: _senegalCenter, zoom: 7.0),
                  onMapCreated: (controller) => _mapController = controller,
                  markers: _markers,
                  onTap: (_) => _closeSheet(),
                  padding: EdgeInsets.only(top: top + 110),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: AppColors.background,
              padding: EdgeInsets.only(top: top + 12, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(child: Text("Carte", style: AppTheme.display(size: 30))),
                        IconButton(
                          tooltip: "Recentrer",
                          style: IconButton.styleFrom(backgroundColor: AppColors.chip),
                          onPressed: () => _mapController?.animateCamera(
                            CameraUpdate.newCameraPosition(
                              const CameraPosition(target: _senegalCenter, zoom: 7.0),
                            ),
                          ),
                          icon: const Icon(Icons.my_location_rounded, color: AppColors.ink, size: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _filterChip("Sites", 'place', _showPlaces),
                        _filterChip("Plages", 'beach', _showBeaches),
                        _filterChip("Hôtels", 'hotel', _showHotels),
                        _filterChip("Restaurants", 'restaurant', _showRestaurants),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_selectedItem != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SlideTransition(position: _sheetAnim, child: _buildDetailSheet()),
            ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String type, bool active) {
    final color = _typeColors[type]!;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => _toggleFilter(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: active ? AppColors.ink : AppColors.field,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: active ? AppColors.ink : AppColors.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : AppColors.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSheet() {
    final rating = _getRating();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 110),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            height: 84,
            child: NetImage(
              url: _getImageUrl(),
              seed: _getName(),
              icon: _getTypeIcon(),
              radius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTypeLabel().toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: 1),
                ),
                const SizedBox(height: 2),
                Text(
                  _getName(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.display(size: 18, weight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  rating > 0 ? "${_getCity()} · ${rating.toStringAsFixed(1)}" : _getCity(),
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    onPressed: _navigateToDetail,
                    child: const Text("Voir la fiche"),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: "Fermer",
            onPressed: _closeSheet,
            icon: const Icon(Icons.close_rounded, color: AppColors.muted, size: 20),
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
}
