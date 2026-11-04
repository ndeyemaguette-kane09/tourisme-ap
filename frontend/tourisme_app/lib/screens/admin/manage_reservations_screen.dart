import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../theme/app_colors.dart';

class ManageReservationsScreen extends StatefulWidget {
  final String token;
  const ManageReservationsScreen({super.key, required this.token});

  @override
  State<ManageReservationsScreen> createState() => _ManageReservationsScreenState();
}

class _ManageReservationsScreenState extends State<ManageReservationsScreen> {
  List reservations = [];
  bool isLoading = true;
  String filter = "EN_ATTENTE";

  static const labels = {
    "EN_ATTENTE": "En attente",
    "CONFIRMEE": "Confirmées",
    "ANNULEE": "Annulées",
  };

  Map<String, String> get headers => {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${widget.token}",
      };

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/reservations"),
        headers: headers,
      );
      if (response.statusCode != 200) throw Exception();
      setState(() {
        reservations = jsonDecode(utf8.decode(response.bodyBytes));
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateStatus(int id, String action) async {
    final response = await http.put(
      Uri.parse("${ApiConfig.baseUrl}/reservations/$id/$action"),
      headers: headers,
    );
    if (!mounted) return;
    if (response.statusCode == 200) {
      load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Action impossible sur cette réservation")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shown = reservations.where((r) => r["status"] == filter).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Réservations"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: labels.entries.map((e) {
                final count = reservations.where((r) => r["status"] == e.key).length;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text("${e.value} ($count)"),
                    selected: filter == e.key,
                    onSelected: (_) => setState(() => filter = e.key),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : shown.isEmpty
                    ? const Center(child: Text("Rien ici pour le moment"))
                    : RefreshIndicator(
                        onRefresh: load,
                        child: ListView.builder(
                          itemCount: shown.length,
                          itemBuilder: (context, i) {
                            final r = shown[i];
                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r["hotelName"] ?? "Hôtel #${r["hotelId"]}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text("Client #${r["userId"]} · ${r["guests"]} pers."),
                                    Text("Du ${r["checkInDate"]} au ${r["checkOutDate"]}"),
                                    Text("${(r["totalPrice"] ?? 0).round()} FCFA"),
                                    if (filter == "EN_ATTENTE")
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () => updateStatus(r["id"], "cancel"),
                                            child: const Text("Refuser"),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF2E7D32),
                                            ),
                                            onPressed: () => updateStatus(r["id"], "confirm"),
                                            child: const Text("Confirmer",
                                                style: TextStyle(color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
