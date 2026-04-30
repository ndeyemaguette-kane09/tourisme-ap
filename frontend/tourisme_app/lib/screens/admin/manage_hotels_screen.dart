import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/hotel.dart';
import '../../services/hotel_service.dart';
import 'edit_hotel_screen.dart';

class ManageHotelsScreen extends StatefulWidget {
  final String token;

  const ManageHotelsScreen({super.key, required this.token});

  @override
  State<ManageHotelsScreen> createState() => _ManageHotelsScreenState();
}

class _ManageHotelsScreenState extends State<ManageHotelsScreen>
    with TickerProviderStateMixin {
  late Future<List<Hotel>> hotelsFuture;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // ── Palette Teranga ──
  static const Color _orange = Color(0xFFE64A19);
  static const Color _orangeDark = Color(0xFFBF360C);
  static const Color _orangeLight = Color(0xFFF57C00);
  static const Color _cream = Color(0xFFFFF8F0);
  static const Color _amber = Color(0xFFFFF3E0);

  @override
  void initState() {
    super.initState();
    hotelsFuture = HotelService().getHotels(widget.token);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ── LOGIQUE INCHANGÉE ──
  void _refresh() {
    setState(() {
      hotelsFuture = HotelService().getHotels(widget.token);
    });
  }

  // ── CONFIRMATION SUPPRESSION ──
  Future<void> _confirmDelete(Hotel hotel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône warning
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_outline_rounded,
                    color: Colors.red.shade400, size: 32),
              ),
              const SizedBox(height: 20),

              const Text(
                "Supprimer cet hôtel ?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              Text(
                "Vous êtes sur le point de supprimer\n« ${hotel.name} ».\nCette action est irréversible.",
                style: TextStyle(
                  fontSize: 13.5,
                  color: Colors.grey.shade600,
                  height: 1.55,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Boutons
              Row(
                children: [
                  // Annuler
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx, false),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text(
                            "Annuler",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Supprimer
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx, true),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.red.shade500,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "Supprimer",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await HotelService().deleteHotel(hotel.id, widget.token);
        _refresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("« ${hotel.name} » supprimé avec succès"),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Erreur lors de la suppression"),
              backgroundColor: Colors.grey.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _cream,
      body: Stack(
        children: [
          // ── HEADER GRADIENT ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size.height * 0.22,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_orangeDark, _orange, _orangeLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // ── CERCLES DÉCORATIFS ──
          Positioned(
            top: -30,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 40,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),

          // ── ARRONDI CRÈME ──
          Positioned(
            top: size.height * 0.19,
            left: 0,
            right: 0,
            child: Container(
              height: 36,
              decoration: const BoxDecoration(
                color: _cream,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(36)),
              ),
            ),
          ),

          // ── CONTENU ──
          SafeArea(
            child: Column(
              children: [
                // ── TITRE HEADER ──
                SizedBox(
                  height: size.height * 0.14,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1),
                            ),
                            child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 16),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Gestion",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                "des hôtels 🏨",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Gérez votre catalogue d'hôtels",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── LISTE ──
                Expanded(
                  child: FutureBuilder<List<Hotel>>(
                    future: hotelsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return _buildLoader();
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmpty();
                      }

                      final hotels = snapshot.data!;

                      return ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(20, 8, 20, 32),
                        itemCount: hotels.length,
                        itemBuilder: (context, index) {
                          return _HotelCard(
                            hotel: hotels[index],
                            onEdit: () async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditHotelScreen(
                                    hotel: hotels[index],
                                    token: widget.token,
                                  ),
                                ),
                              );
                              if (updated == true) {
                                _refresh();
                              }
                            },
                            onDelete: () =>
                                _confirmDelete(hotels[index]),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _pulseAnim,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_orange, _orangeLight]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.hotel_rounded,
                  color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Chargement des hôtels…",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hotel_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "Aucun hôtel trouvé",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── CARTE HÔTEL ──
class _HotelCard extends StatelessWidget {
  final Hotel hotel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const Color _orange = Color(0xFFE64A19);
  static const Color _amber = Color(0xFFFFF3E0);

  const _HotelCard({
    required this.hotel,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // ── IMAGE ──
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                hotel.imageUrl ?? '',
                width: 88,
                height: 88,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: _amber,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.hotel_rounded,
                      color: _orange, size: 36),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // ── INFOS ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 3),
                      Text(
                        hotel.city ?? "Ville inconnue",
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Note + prix
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Color(0xFFF57C00), size: 12),
                            const SizedBox(width: 3),
                            Text(
                              hotel.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFBF360C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${hotel.price} FCFA",
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: _orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── ACTIONS ──
            Column(
              children: [
                // Bouton éditer
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.edit_rounded,
                        color: Color(0xFF1565C0), size: 18),
                  ),
                ),
                const SizedBox(height: 8),
                // Bouton supprimer
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.delete_outline_rounded,
                        color: Colors.red.shade400, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}