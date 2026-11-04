import 'package:flutter/material.dart';
import '../services/reservation_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

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

class _ReservationScreenState extends State<ReservationScreen> {
  DateTime? checkInDate;
  DateTime? checkOutDate;
  int guests = 1;
  String paymentMethod = "Carte";
  bool _isLoading = false;

  final ReservationService reservationService = ReservationService();

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
              primary: AppColors.ink,
              onPrimary: Colors.white,
              surface: AppColors.background,
              onSurface: AppColors.ink,
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

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void confirmReservation() async {
    if (checkInDate == null || checkOutDate == null) {
      _message("Veuillez choisir les dates");
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
      _message("Demande de réservation envoyée");
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _message(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Réservation")),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text("Tes dates", style: AppTheme.display(size: 26)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _dateTile(
                  label: "Arrivée",
                  date: checkInDate,
                  onTap: () => selectDate(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dateTile(
                  label: "Départ",
                  date: checkOutDate,
                  onTap: () => selectDate(false),
                ),
              ),
            ],
          ),
          if (_nightCount > 0) ...[
            const SizedBox(height: 10),
            Text(
              "$_nightCount nuit${_nightCount > 1 ? 's' : ''}",
              style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 28),
          _sectionTitle("Voyageurs"),
          _guestSelector(),
          const SizedBox(height: 28),
          _sectionTitle("Moyen de paiement"),
          _paymentSelector(),
          const SizedBox(height: 4),
          const Text(
            "Paiement fictif : aucune somme n'est débitée.",
            style: TextStyle(color: AppColors.muted, fontSize: 13),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: ElevatedButton(
            onPressed: _isLoading ? null : confirmReservation,
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : const Text("Confirmer la réservation"),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: 1),
      ),
    );
  }

  BoxDecoration _tile(bool selected) {
    return BoxDecoration(
      color: AppColors.field,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: selected ? AppColors.ink : AppColors.line,
        width: selected ? 1.5 : 1,
      ),
    );
  }

  Widget _dateTile({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final selected = date != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: _tile(selected),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            const SizedBox(height: 6),
            Text(
              selected ? _formatDate(date) : "Choisir",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.ink : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _guestSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: _tile(false),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$guests voyageur${guests > 1 ? 's' : ''}",
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          _counterBtn(
            icon: Icons.remove_rounded,
            onTap: () {
              if (guests > 1) setState(() => guests--);
            },
            enabled: guests > 1,
          ),
          const SizedBox(width: 10),
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? AppColors.chip : AppColors.background,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: enabled ? AppColors.ink : AppColors.line),
      ),
    );
  }

  Widget _paymentSelector() {
    final methods = [
      {"value": "Carte", "icon": Icons.credit_card_rounded},
      {"value": "Wave", "icon": Icons.waves_rounded, "logo": "assets/payments/wave.png"},
      {"value": "Orange Money", "icon": Icons.phone_android_rounded, "logo": "assets/payments/orange_money.png"},
      {"value": "Paiement sur place", "icon": Icons.storefront_rounded},
    ];

    return Column(
      children: methods.map((m) {
        final val = m["value"] as String;
        final icon = m["icon"] as IconData;
        final logo = m["logo"] as String?;
        final selected = paymentMethod == val;
        return GestureDetector(
          onTap: () => setState(() => paymentMethod = val),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: _tile(selected),
            child: Row(
              children: [
                logo != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          logo,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _methodIcon(icon),
                        ),
                      )
                    : _methodIcon(icon),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(val, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
                Icon(
                  selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  color: selected ? AppColors.ink : AppColors.line,
                  size: 22,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _methodIcon(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.chip,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppColors.ink, size: 20),
    );
  }
}
