import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/reservation_service.dart';

class ReservationScreen extends StatefulWidget {
  final int hotelId;
  final int userId;
  final String token;

  const ReservationScreen({
    super.key,
    required this.hotelId,
    required this.userId,
    required this.token,
  });

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen>
    with TickerProviderStateMixin {
  // ── LOGIQUE INCHANGÉE ──
  DateTime? checkInDate;
  DateTime? checkOutDate;
  int guests = 1;
  String paymentMethod = "Carte";
  bool _isLoading = false;

  final ReservationService reservationService = ReservationService();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  // ── Palette Teranga ──
  static const Color _orange = Color(0xFFE64A19);
  static const Color _orangeDark = Color(0xFFBF360C);
  static const Color _orangeLight = Color(0xFFF57C00);
  static const Color _cream = Color(0xFFFFF8F0);
  static const Color _amber = Color(0xFFFFF3E0);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ── LOGIQUE DATES INCHANGÉE ──
  Future<void> selectDate(bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _orange,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          checkInDate = picked;
        } else {
          checkOutDate = picked;
        }
      });
    }
  }

  // ── LOGIQUE CONFIRMATION INCHANGÉE ──
  void confirmReservation() async {
    if (checkInDate == null || checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Veuillez choisir les dates"),
          backgroundColor: _orangeDark,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await reservationService.createReservation(
        widget.userId,
        widget.hotelId,
        checkInDate!,
        checkOutDate!,
        guests,
        widget.token,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("✅ Réservation confirmée !"),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Erreur lors de la réservation"),
          backgroundColor: Colors.grey.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Calcul du nombre de nuits ──
  int get _nightCount {
    if (checkInDate == null || checkOutDate == null) return 0;
    return checkOutDate!.difference(checkInDate!).inDays.abs();
  }

  String _formatDate(DateTime date) {
    const months = [
      "jan.", "fév.", "mar.", "avr.", "mai", "juin",
      "juil.", "aoû.", "sep.", "oct.", "nov.", "déc."
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _cream,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            // ── HEADER GRADIENT ──
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: size.height * 0.20,
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
                width: 150,
                height: 150,
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
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),

            // ── ARRONDI CRÈME ──
            Positioned(
              top: size.height * 0.17,
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

            // ── CORPS SCROLLABLE ──
            SafeArea(
              child: Column(
                children: [
                  // Barre top
                  SizedBox(
                    height: size.height * 0.12,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
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
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Réservation",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                "Complétez votre séjour 🏨",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Contenu scrollable
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── SECTION DATES ──
                          _sectionTitle(
                              Icons.calendar_month_rounded, "Vos dates"),
                          const SizedBox(height: 14),

                          // Dates côte à côte
                          Row(
                            children: [
                              Expanded(
                                child: _dateTile(
                                  label: "Arrivée",
                                  icon: Icons.flight_land_rounded,
                                  date: checkInDate,
                                  onTap: () => selectDate(true),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _dateTile(
                                  label: "Départ",
                                  icon: Icons.flight_takeoff_rounded,
                                  date: checkOutDate,
                                  onTap: () => selectDate(false),
                                ),
                              ),
                            ],
                          ),

                          // Résumé nuits
                          if (_nightCount > 0) ...[
                            const SizedBox(height: 12),
                            _nightSummary(),
                          ],

                          const SizedBox(height: 28),

                          // ── SECTION VOYAGEURS ──
                          _sectionTitle(
                              Icons.groups_rounded, "Voyageurs"),
                          const SizedBox(height: 14),
                          _guestSelector(),

                          const SizedBox(height: 28),

                          // ── SECTION PAIEMENT ──
                          _sectionTitle(
                              Icons.payment_rounded, "Moyen de paiement"),
                          const SizedBox(height: 14),
                          _paymentSelector(),

                          const SizedBox(height: 28),

                          // ── DIVIDER DÉCO ──
                          Row(
                            children: [
                              Expanded(
                                  child: Divider(
                                      color: Colors.grey.shade200,
                                      thickness: 1)),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12),
                                child: Icon(Icons.hotel_rounded,
                                    color: Colors.grey.shade300, size: 16),
                              ),
                              Expanded(
                                  child: Divider(
                                      color: Colors.grey.shade200,
                                      thickness: 1)),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Footer
                          const Center(
                            child: Text(
                              "🇸🇳 Teranga • Culture • Découverte",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── BOUTON CTA FIXE ──
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                decoration: BoxDecoration(
                  color: _cream,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: Container(
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_orangeDark, _orange, _orangeLight],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: _orange.withOpacity(0.45),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: _isLoading ? null : confirmReservation,
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_rounded,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    "Confirmer la réservation",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── WIDGETS UI ──

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: _orange,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, color: _orange, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }

  Widget _dateTile({
    required String label,
    required IconData icon,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final bool selected = date != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? _amber : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? _orange.withOpacity(0.4) : Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? _orange.withOpacity(0.1)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    size: 16,
                    color: selected ? _orange : Colors.grey.shade400),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected ? _orangeDark : Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              selected ? _formatDate(date!) : "Choisir",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: selected ? const Color(0xFF1A1A1A) : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nightSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_orangeDark, _orange],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.nights_stay_rounded,
              color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            "$_nightCount nuit${_nightCount > 1 ? 's' : ''} sélectionnée${_nightCount > 1 ? 's' : ''}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _guestSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.person_rounded, color: _orange, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "$guests voyageur${guests > 1 ? 's' : ''}",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          // Bouton -
          _counterBtn(
            icon: Icons.remove_rounded,
            onTap: () {
              if (guests > 1) setState(() => guests--);
            },
            enabled: guests > 1,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              "$guests",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: _orange,
              ),
            ),
          ),
          // Bouton +
          _counterBtn(
            icon: Icons.add_rounded,
            onTap: () => setState(() => guests++),
            enabled: true,
          ),
        ],
      ),
    );
  }

  Widget _counterBtn({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: enabled ? _amber : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: enabled ? _orange.withOpacity(0.3) : Colors.grey.shade200),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? _orange : Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _paymentSelector() {
    final methods = [
      {"value": "Carte", "icon": Icons.credit_card_rounded},
      {"value": "Wave", "icon": Icons.waves_rounded},
      {"value": "Orange Money", "icon": Icons.phone_android_rounded},
      {"value": "Paiement sur place", "icon": Icons.storefront_rounded},
    ];

    return Column(
      children: methods.map((m) {
        final val = m["value"] as String;
        final icon = m["icon"] as IconData;
        final selected = paymentMethod == val;
        return GestureDetector(
          onTap: () => setState(() => paymentMethod = val),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: selected ? _amber : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? _orange.withOpacity(0.5)
                    : Colors.grey.shade200,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: selected
                      ? _orange.withOpacity(0.08)
                      : Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: selected ? _orange : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon,
                      color: selected ? Colors.white : Colors.grey.shade400,
                      size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    val,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? const Color(0xFF1A1A1A)
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
                if (selected)
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: _orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 14),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}