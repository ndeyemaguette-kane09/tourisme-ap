import 'package:flutter/material.dart';
import '../services/reservation_service.dart';
import '../widgets/motion.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class MyReservationsScreen extends StatefulWidget {
  final int userId;
  final String token;

  const MyReservationsScreen({
    super.key,
    required this.userId,
    required this.token,
  });

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  List reservations = [];
  bool isLoading = true;

  final ReservationService reservationService = ReservationService();

  static const _statusLabels = {
    "EN_ATTENTE": "En attente",
    "CONFIRMEE": "Confirmée",
    "ANNULEE": "Annulée",
    "TERMINEE": "Terminée",
  };

  static const _statusColors = {
    "EN_ATTENTE": Color(0xFFD4876A),
    "CONFIRMEE": Color(0xFF5E7D5A),
    "ANNULEE": Color(0xFF9E9E9E),
    "TERMINEE": Color(0xFF15171C),
  };

  @override
  void initState() {
    super.initState();
    loadReservations();
  }

  Future<void> loadReservations() async {
    try {
      final data = await reservationService.getUserReservations(
        widget.userId,
        widget.token,
      );

      setState(() {
        reservations = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> cancel(Map reservation) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Annuler la réservation ?"),
        content: Text("Séjour à ${reservation['hotelName'] ?? 'cet hôtel'}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Non"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Oui, annuler"),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await reservationService.cancelReservation(reservation['id'], widget.token);
      await loadReservations();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    }
  }

  String formatDate(String? date) {
    if (date == null) return "-";
    final parts = date.split("-");
    if (parts.length != 3) return date;
    return "${parts[2]}/${parts[1]}/${parts[0]}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Mes réservations"),
      ),
      body: isLoading
          ? const SkeletonList(itemHeight: 120)
          : reservations.isEmpty
              ? const Center(child: Text("Aucune réservation pour le moment"))
              : RefreshIndicator(
                  onRefresh: loadReservations,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: reservations.length,
                    itemBuilder: (context, index) {
                      final r = reservations[index];
                      final status = r['status'] ?? "EN_ATTENTE";
                      final color = _statusColors[status] ?? AppColors.accent;
                      final canCancel = status == "EN_ATTENTE" || status == "CONFIRMEE";

                      return FadeSlideIn(index: index, child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.field,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      r['hotelName'] ?? "Hôtel #${r['hotelId']}",
                                      style: AppTheme.display(size: 18, weight: FontWeight.w600),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _statusLabels[status] ?? status,
                                      style: TextStyle(color: color, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Du ${formatDate(r['checkInDate'])} au ${formatDate(r['checkOutDate'])}"
                                " · ${r['guests'] ?? 1} pers.",
                                style: const TextStyle(color: AppColors.muted),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Total : ${(r['totalPrice'] ?? 0).round()} FCFA",
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              if (canCancel)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => cancel(r),
                                    child: const Text("Annuler", style: TextStyle(color: AppColors.laterite, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ));
                    },
                  ),
                ),
    );
  }
}
