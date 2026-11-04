import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ReservationService {
  final String baseUrl = ApiConfig.baseUrl;

  Map<String, String> _headers(String token) => {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

  String _errorMessage(http.Response response, String fallback) {
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      return body["message"] ?? body["error"] ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  Future<List<dynamic>> getUserReservations(int userId, String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/reservations/user/$userId"),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception("Erreur chargement réservations");
    }
  }

  Future<void> createReservation(
    int userId,
    int hotelId,
    DateTime checkInDate,
    DateTime checkOutDate,
    int guests,
    String token,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/reservations"),
      headers: _headers(token),
      body: jsonEncode({
        "userId": userId,
        "hotelId": hotelId,
        "checkInDate": checkInDate.toIso8601String().split('T')[0],
        "checkOutDate": checkOutDate.toIso8601String().split('T')[0],
        "guests": guests,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_errorMessage(response, "Erreur lors de la réservation"));
    }
  }

  Future<void> cancelReservation(int id, String token) async {
    final response = await http.put(
      Uri.parse("$baseUrl/reservations/$id/cancel"),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response, "Annulation impossible"));
    }
  }
}
