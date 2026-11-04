import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class PlaceService {
  final String baseUrl = ApiConfig.baseUrl;

  Map<String, String> _headers(String token) => {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };

  Future<List<Map<String, dynamic>>> getPlaces(String token) async {
    final response = await http.get(Uri.parse("$baseUrl/places"), headers: _headers(token));
    if (response.statusCode != 200) throw Exception("Erreur chargement lieux");
    final List data = jsonDecode(utf8.decode(response.bodyBytes));
    return data.cast<Map<String, dynamic>>();
  }

  Future<void> addPlace(Map<String, dynamic> place, String token) async {
    final response = await http.post(
      Uri.parse("$baseUrl/places"),
      headers: _headers(token),
      body: jsonEncode(place),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Erreur ajout lieu");
    }
  }

  Future<void> updatePlace(int id, Map<String, dynamic> place, String token) async {
    final response = await http.put(
      Uri.parse("$baseUrl/places/$id"),
      headers: _headers(token),
      body: jsonEncode(place),
    );
    if (response.statusCode != 200) throw Exception("Erreur mise à jour lieu");
  }

  Future<void> deletePlace(int id, String token) async {
    final response = await http.delete(Uri.parse("$baseUrl/places/$id"), headers: _headers(token));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Erreur suppression lieu");
    }
  }
}
