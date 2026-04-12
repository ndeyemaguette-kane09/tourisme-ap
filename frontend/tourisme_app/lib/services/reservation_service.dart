import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tourisme_app/services/api_service.dart';

class ReservationService {
  final String baseUrl = ApiService.baseUrl;
Future<List<dynamic>> getUserReservations(int userId, String token) async {
  final response = await http.get(
    Uri.parse("$baseUrl/reservations/user/$userId"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Erreur chargement réservations");
  }
}

  Future<void> createReservation(
    int userId,
    int hotelId,
    DateTime checkInDate,   // ← ajoute
    DateTime checkOutDate,  // ← ajoute
    int guests,             // ← ajoute
    String token,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/reservations"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "userId": userId,
        "hotelId": hotelId,
        "checkInDate": checkInDate.toIso8601String().split('T')[0],  // "2026-04-10"
        "checkOutDate": checkOutDate.toIso8601String().split('T')[0],
        "guests": guests,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Reservation failed");
    }
  }
}