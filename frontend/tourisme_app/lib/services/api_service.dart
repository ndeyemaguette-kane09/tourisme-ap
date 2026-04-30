import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.1.105:8080";

  static Map<String, String> headers(String token) {
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };
  }

  static Future<void> addHotel(String token, Map<String, dynamic> hotel) async {
    final response = await http.post(
      Uri.parse("$baseUrl/hotels"),
      headers: headers(token),
      body: jsonEncode(hotel),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Erreur ajout hôtel");
    }
  }

static Future<void> deleteHotel(String token, int id) async {
  final response = await http.delete(
    Uri.parse("$baseUrl/hotels/$id"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  if (response.statusCode != 200) {
    throw Exception("Erreur suppression hôtel");
  }
}

  static Future<void> addRestaurant(String token, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/restaurants"),
      headers: headers(token),
      body: jsonEncode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Erreur ajout restaurant");
    }
  }

  static Future<void> addBeach(String token, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/beaches"),
      headers: headers(token),
      body: jsonEncode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Erreur ajout plage");
    }
  }

  static Future<List<dynamic>> getRestaurants(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/restaurants"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Erreur chargement restaurants");
    }
  }
  static Future<List<dynamic>> getReviews(int id, String type) async {
  final response = await http.get(
    Uri.parse("$baseUrl/reviews?entityId=$id&entityType=$type"),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception("Erreur reviews");
  }
}
static Future<void> addReview(Map<String, dynamic> data) async {
  final response = await http.post(
    Uri.parse("$baseUrl/reviews"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(data),
  );

  print("STATUS REVIEW: ${response.statusCode}");
  print("BODY REVIEW: ${response.body}");

  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception("Erreur ajout review");
  }
}
}