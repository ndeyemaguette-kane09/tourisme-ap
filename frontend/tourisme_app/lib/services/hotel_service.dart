import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hotel.dart';
import 'api_service.dart';
import '../config/api_config.dart';

class HotelService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<List<Hotel>> getHotels(String token) async {
    
    final response = await http.get(
      Uri.parse("$baseUrl/hotels"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      
    );

    print("HOTEL STATUS: ${response.statusCode}");
    print("HOTEL BODY: ${response.body}");

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => Hotel.fromJson(e)).toList();
    } else {
      throw Exception("Erreur chargement hôtels");
    }
  }

  Future<void> deleteHotel(int id, String token) async {
  await http.delete(
    Uri.parse("$baseUrl/hotels/$id"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );
}

  Future<void> addHotel(Map<String, dynamic> hotel, String token) async {
    final response = await http.post(
      Uri.parse("$baseUrl/hotels"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(hotel),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Erreur ajout hôtel");
    }
  }

  Future<void> updateHotel(int id, Map<String, dynamic> hotel, String token) async {
  final response = await http.put(
    Uri.parse("$baseUrl/hotels/$id"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
    body: jsonEncode(hotel),
  );

  print("UPDATE STATUS: ${response.statusCode}");
  print("UPDATE BODY: ${response.body}");

  if (response.statusCode != 200 && response.statusCode != 204) {
    throw Exception("Erreur mise à jour hôtel");
  }
}

  

  
}